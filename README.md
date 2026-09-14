<div align="center">

<img src="assets/logo.png" width="120" alt="SLGJ Finance Engine"/>

# 丝路e投财务模型引擎 · SLGJ Finance Engine

**投融资项目全寿命财务模型 MCP 服务 | Full-life financial modeling MCP for investment projects**

[![MCP](https://img.shields.io/badge/MCP-Remote%20Server-0f8a4d)](https://modelcontextprotocol.io)
[![Protocol](https://img.shields.io/badge/protocol-streamableHttp-blue)]()
[![Auth](https://img.shields.io/badge/auth-Bearer%20Token-orange)]()
[![Tools](https://img.shields.io/badge/tools-21-9333ea)]()

[官网](https://www.slgj.cn) · [用户接入说明](docs/onboarding.md) · [工具契约目录](docs/tool-catalog.md) · [令牌获取](https://www.slgj.cn/payment/mcp_access)

</div>

---

## 简介 | Introduction

**中文**：面向投融资项目的全寿命财务测算引擎。五类输入（项目基础信息 / 建设投资 / 收入 / 成本 / 融资）直算 11 张 E投 原生财务报表与 IRR/MIRR/NPV 指标，一键产出 12 表全公式 Excel、财务可视化看板、可研 / 经济评价 / 国民经济评价 Word 报告。内置六段 73 项报表勾稽体检、收入费用 16 项合理性审查与指标秒级反算。行业唯一支持不整年、非年初、任意月现金流的精确建模，按年粗算 + 按月精算双口径指标，适用于任何投融资项目（不限行业与类型）。数字全部由引擎计算，AI 只组织叙述。

**English**: A full-life financial modeling engine for investment projects. Feed five input files (basic info / construction investment / revenue / cost / financing) and get 11 native financial statements plus IRR/MIRR/NPV indicators, a 12-sheet formula Excel, a financial dashboard, and Word reports (feasibility study / economic evaluation / national economic evaluation) — with a 73-item consistency check, a 16-item revenue/expense review, and second-level goal-seeking. Uniquely supports exact modeling of arbitrary-month cash flows (non-full-year, non-January start) with dual annual/monthly indicator sets. All numbers are computed by the engine; the AI only narrates.

## 核心能力 | Tools (21)

> 🔑 = 首次调用前需先执行一次 `get_protocol_instructions`（72 小时内免重复握手）。完整参数契约见 [docs/tool-catalog.md](docs/tool-catalog.md)，或匿名 `tools/list` 实时查看。

| 类别 | 工具 | 说明 |
|---|---|---|
| 接入门禁 | `get_protocol_instructions` | 接入总则（目录结构 / 文件命名 / 成品规范） |
| | `get_skill_instructions` | 技能工作流指令模板（测算 / 估算 / 演示 / 定价 / 报告等 8 类） |
| 测算 | `fast_calc_reports` | 五类输入 → 11 张报表 + 指标 + IRR/MIRR 诊断 + 资金缺口（JSON 取数） |
| | `fast_calc_excel` 🔑 | 12 表全公式 Excel（E投口径 + 勾稽自检页），72h 下载短链 |
| | `run_delivery_bundle` 🔑 | 一键四件套：Excel + 看板 + 敏感性 + 可选 Word（25-30s） |
| | `fast_calc_solve` | 指标反算：给定目标值（如全投资税后 IRR=8%），秒级反推收入 / 成本 / 建设投资调整幅度 |
| 分析与体检 | `run_model_check` | 报表勾稽体检：E/A/F/B/C/D 六段 73 项校验 |
| | `run_revenue_review` | 收入费用合理性审查：R/C/X 三模块 16 项 |
| | `run_uncertainty` 🔑 | 敏感性 / 情景 / 蒙特卡洛 + 总报告 |
| 报告与演示 | `generate_word_report` | Word 报告：公文 / 可研 8 章 / 经济评价 6 章 / 国民经济专项，附表自动组装 + 数字防伪 |
| | `generate_dashboard` | 财务看板：动态资金流演绎 + 双口径偿债能力，单文件 HTML 可离线 |
| | `get_chapter_data` | 可研 / 经济评价报告按章节取数（引擎值直供占位符） |
| | `ppt_extract_data` 🔑 | 演示文稿取数：报表 → 结构化 JSON |
| | `generate_ppt_html` 🔑 | 演示封装：内容 HTML → 自包含 HTML（Plotly 内联离线可用） |
| 估算 / 定价 / 国民经济 | `match_cost_indicators` | 造价指标匹配：子项描述 → 平台指标库候选 |
| | `estimate_excel` 🔑 | 投资估算：估算 JSON → 三表全公式 Excel |
| | `estimate_etou_json` 🔑 | 估算转 E投 格式 `construction_data.json` |
| | `permitted_cost_excel` 🔑 | 准许成本 + 合理收益定价全公式 Excel |
| | `run_national_econ` | 国民经济评价：ENPV / EIRR / BCR + 可行判定 + 敏感性 |
| 用量与反馈 | `query_usage` | 查询自己当月调用量 / 流量 / 耗时统计 |
| | `submit_feedback` | 用户反馈直达平台 |

**两种数据入口（通用）**：① `files` 直接传 5 类输入 txt（`project_basic_info.txt` / `construction_data.txt` / `revenue_data.txt` / `cost_data.txt` / `financing_data.txt`）；② `p_id` 传平台项目号（只能访问令牌归属账号自己的项目）。

## 快速开始 | Quick Start

**1. 获取令牌**：注册 [www.slgj.cn](https://www.slgj.cn) → [个人中心 → AI接入](https://www.slgj.cn/payment/mcp_access) → 生成 MCP 令牌（`sk-mcp-` 开头，30/90 天，每账号 3 把，可随时吊销）

**2. 配置客户端**（Claude Desktop / Cursor / VS Code / Cherry Studio / CodeBuddy / WorkBuddy / 通义灵码等通用）：

```json
{
  "mcpServers": {
    "slgj-finance": {
      "type": "streamableHttp",
      "url": "https://www.slgj.cn/skills-api/api/v1/mcp",
      "headers": { "Authorization": "Bearer <YOUR_TOKEN>" },
      "timeout": 120000
    }
  }
}
```

**3. 首次调用**（三步验证流）：

```
你：请阅读丝路E投接入总则          → 过 72h 协议门禁
你：用这份五类输入数据做快速测算    → fast_calc_reports 返回 11 张报表
你：生成经济评价报告               → 返回 72h 下载短链的 .docx
```

也可用 curl 直测（免客户端）：[docs/onboarding.md §七](docs/onboarding.md)。

> 报告生成类工具耗时 30-90 秒（含版式排版与数字防伪校验），已配 120 秒超时；`run_uncertainty` 完整模式建议 ≥300 秒。

## 客户端兼容 | Client Compatibility

| 客户端 | 接入方式 |
|---|---|
| Claude Desktop / Claude Code | 自定义连接器 / `claude mcp add --transport http` |
| Cursor · VS Code (Copilot) · Cline | mcp.json（`url` + `headers`） |
| Cherry Studio · DeepChat · 5ire 等 | 表单填 URL + 鉴权头 |
| CodeBuddy · 通义灵码 / Qoder · WorkBuddy | MCP 扩展 / 官方连接器（已上架） |

完整接入说明（令牌规则、握手流程、报错对照、计费）：**[docs/onboarding.md](docs/onboarding.md)**

## 配额与合规 | Quota & Compliance

- 新用户 MCP 试用 7 天；VIP 公测期不限量；全部调用计量与审计，执行失败自动退款
- 免责：测算结果基于用户输入与现行财税口径，仅供参考，不构成投资承诺
- 数据隔离：用户项目数据互不可见；`files` 直传为无状态计算，平台不留存输入数据
- 成品短链 72 小时有效；令牌仅存于客户端本机，可随时在平台吊销
- 令牌即账户凭证，请勿提交至公开代码仓库

## 适用人群 | Who is it for

工程咨询机构 · 投资咨询顾问 · 项目投融资分析人员 · 财经专业师生

---

© 丝路E投 SLGJ · [www.slgj.cn](https://www.slgj.cn) · 服务持续在产运行，计算全部在服务端完成（本仓库为接入文档，不含引擎源码）
