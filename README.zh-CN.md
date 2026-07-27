<p align="center">
  <img src="assets/logo.svg" alt="BOMBAR — Bounded Orchestration Method for Building with Agents, Reliably" width="720">
</p>

<p align="center">
  <a href="README.md">English</a> | <strong>简体中文</strong>
</p>

<p align="center">
  <a href="https://github.com/JBombar/BOMBAR/actions/workflows/test.yml"><img src="https://github.com/JBombar/BOMBAR/actions/workflows/test.yml/badge.svg" alt="Test status"></a>
  <a href="https://github.com/JBombar/BOMBAR/releases/tag/v0.1.0"><img src="https://img.shields.io/badge/release-v0.1.0-blue" alt="Release v0.1.0"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache%202.0-informational" alt="License: Apache 2.0"></a>
</p>

# BOMBAR

**B.O.M.B.A.R. — 有边界的智能体协同构建方法（Bounded Orchestration Method for Building with Agents, Reliably）。**

BOMBAR 将经过人类批准的产品意图，转化为有边界的实现任务，交由全新的编码智能体会话去执行并验证。它**不会**取代产品判断的人工决策。架构师（Architect）与项目负责人以交互方式确定意图；只有在合同与规格获得批准并冻结之后，自治的 Builder 才会开始工作。

## 边界

```text
交互式（INTERACTIVE）                     自治式（AUTONOMOUS）
负责人 <-> 架构师                         每份规格对应一个全新 Builder
  发现意图                                 实现有边界的范围
  勘察现状                                 运行项目验收关卡
  决定架构                                 产出证据
  冻结验收标准                             提交并停止
  编写规格
          |                                      |
          +---------- 已批准的摘要 --------------+
                                                 |
交互式 / 独立评审                                v
负责人 + 架构师 <--- 验证包 <--- Verifier
```

治理规则很简单：

> 人类与架构师确定意图。自治的 Builder 执行已编译的意图。

## 五分钟上手

前置要求：Git、Bash 与 Python 3.11+。

```bash
git clone https://github.com/JBombar/BOMBAR bombar
cd bombar
bash bin/bombar.sh doctor
bash bin/bombar.sh init /path/to/your-project
cd /path/to/your-project
bash .bombar/prepare-architect.sh
```

最后一条命令会准备一个用于**全新交互式架构会话**的初始化提示词。它不会启动无人值守的会话。请与架构师持续协作，直到产品简报、架构、不变量、验收合同、计划与规格准确反映了预期的产品。

然后：

```bash
# 校验产物。这一步不代表批准。
bash .bombar/validate-plan.sh

# 负责人的明确操作：冻结其确切内容。
bash .bombar/validate-plan.sh --freeze --approved-by "Your Name"

# 启动全新的、有边界的 Builder 会话。
bash .bombar/run_bombar.sh

# 为独立评审会话整理一份干净的资料包。
bash .bombar/prepare-verification.sh
```

完整的首次运行流程请参阅 [Getting started](docs/getting-started.md)（英文）。

如果你想评估这套方法本身是否成功迁移，请使用 [methodology-transfer evaluation](docs/transfer-evaluation.md)（英文），而不要仅凭主观印象判断。

## BOMBAR 安装了什么

`bombar init` 会向目标仓库添加一个自包含的 `.bombar/` 控制套件，以及一份可见的 `__development/bombar/` 决策留痕。该套件包含：

- 一个交互式架构师初始化提示词；
- 产品、架构、不变量、验收与 ADR 模板；
- 一份经机器校验的 Markdown 规格合同；
- 一份包含验收关卡与智能体适配器选择的项目档案；
- 将自治执行锁定到已评审意图的批准摘要；
- 一个可恢复的、每份规格对应全新会话的执行器；
- 范围、受保护路径、空操作、证据与验收关卡检查；
- 一个独立的验证资料包生成器。

## 绿地与棕地

BOMBAR 对**变更**本身分类，而不仅仅是对仓库分类。一旦出现真实用户、持久数据、资金、外部集成或运营依赖，一个新项目就可能变为棕地（brownfield）。成熟系统中的一个新的、隔离的模块可能类似绿地（greenfield），而将其接入生产环境则属于棕地。

棕地规格需要兼容性、无中断、可回滚与实时灰度处理。参见 [Greenfield](docs/greenfield.md) 与 [Brownfield](docs/brownfield.md)（均为英文）。

## 智能体中立性

该合同与具体供应商无关。适配器只有一个职责：接收一个提示词文件路径，并启动一个全新的编码智能体会话。BOMBAR 提供了示例适配器，以及用于自身测试的伪适配器（fake adapter）。请显式配置适配器；执行器绝不会猜测凭证或悄悄选择某个供应商。

## BOMBAR 能保证什么、不能保证什么

BOMBAR 无法让每个模型的能力都变得同样强，也没有任何框架能保证软件一定正确。但它可以让意图变得明确、约束模型的变异性、阻止未经批准的重新设计、暴露薄弱或不完整的产出，并区分以下三层：

1. **关卡正确（Gate-correct）**——测试、检查与构建通过。
2. **意图正确（Intent-correct）**——结果满足已批准的产品合同。
3. **世界正确（World-correct）**——预期结果确实在外部边界上发生。

三者缺一不可。测试全绿从来都不是最终结论。

## 仓库结构

```text
bin/          操作入口
scripts/      确定性的控制机制
templates/    安装到目标项目中的产物
prompts/      架构师、规划者、Builder、Verifier 与审计员角色
schemas/      机器可读的合同
docs/         方法与落地指南
examples/     已填充的绿地与棕地示例
tests/        无实时智能体、网络或花费的确定性测试
```

## 状态

本仓库是从多次真实产品构建中提炼出的方法论的首个公开发布版本。请将 `v0.1` 视为一个可执行的假设：使用它、保留证据、反馈迁移成功或失败之处，并根据实际暴露出的问题持续改进这套护栏。

## 许可证

Apache License 2.0。详见 [LICENSE](LICENSE)。
