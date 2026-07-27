from __future__ import annotations

import importlib.util
import json
import pathlib
import tempfile
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("bombar_core", ROOT / "scripts/lib/bombar.py")
assert SPEC and SPEC.loader
bombar = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(bombar)


class BombarCoreTests(unittest.TestCase):
    def test_path_match_directory_glob(self) -> None:
        self.assertTrue(bombar.path_matches("src/a/b.py", "src/**"))
        self.assertTrue(bombar.path_matches("src", "src/**"))
        self.assertFalse(bombar.path_matches("tests/a.py", "src/**"))

    def test_topological_order(self) -> None:
        specs = [
            {"id": "S02", "depends_on": ["S01"]},
            {"id": "S01", "depends_on": []},
        ]
        self.assertEqual([item["id"] for item in bombar.topological_specs(specs)], ["S01", "S02"])

    def test_cycle_refuses(self) -> None:
        specs = [
            {"id": "S01", "depends_on": ["S02"]},
            {"id": "S02", "depends_on": ["S01"]},
        ]
        with self.assertRaisesRegex(bombar.BombarError, "cycle"):
            bombar.topological_specs(specs)

    def test_parse_spec_metadata(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = pathlib.Path(directory) / "S01.md"
            path.write_text(
                '# S01\n\n<!-- BOMBAR_SPEC\n{"id":"S01","depends_on":[]}\n-->\n',
                encoding="utf-8",
            )
            parsed = bombar.parse_spec(path)
            self.assertEqual(parsed["id"], "S01")
            self.assertEqual(len(parsed["_digest"]), 64)

    def test_approval_detects_drift(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            governed = root / "governed.md"
            governed.write_text("first", encoding="utf-8")
            approval = {
                "status": "approved",
                "artifacts": [{"path": "governed.md", "sha256": bombar.sha256(governed)}],
            }
            (root / "approval.json").write_text(json.dumps(approval), encoding="utf-8")
            governed.write_text("changed", encoding="utf-8")
            self.assertNotEqual(approval["artifacts"][0]["sha256"], bombar.sha256(governed))


if __name__ == "__main__":
    unittest.main()
