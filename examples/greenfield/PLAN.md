# Plan

```text
LINK-01 pure parser + result model
    ↓
LINK-02 adapter + CLI + JSON report
    ↓
awake live fixture probe
```

The pure parser lands first because every later behavior depends on its stable result vocabulary. The network adapter remains injected so tests are hermetic.
