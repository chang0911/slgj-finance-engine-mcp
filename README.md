<div align="center">

<img src="assets/logo.png" width="120" alt="SLGJ Finance Engine"/>

# 丝路E投财务引擎 · SLGJ Finance Engine

**投融资项目全寿命财务模型 MCP 服务 | Full-life financial modeling MCP for investment projects**

[![MCP](https://img.shields.io/badge/MCP-Remote%20Server-0f8a4d)](https://modelcontextprotocol.io)
[![Protocol](https://img.shields.io/badge/protocol-streamableHttp-blue)]()
[![Auth](https://img.shields.io/badge/auth-Bearer%20Token-orange)]()

[官网](https://www.slgj.cn) · [令牌获取](https://www.slgj.cn/payment/mcp_access)

</div>

---

## 简介 | Introduction

**中文**：面向投融资项目的全寿命财务测算引擎。五类输入（项目基础信息/建设投资/收入/成本/融资）直算 11 张 E投 原生财务报表与 IRR/MIRR/NPV 指标，一键产出 12 表全公式 Excel、财务可视化看板、可研/经济评价/国民经济评价 Word 报告。内置 72 项报表勾稽体检与指标反算。数字全部由引擎计算，AI 只组织叙述。

**English**: A full-life financial modeling engine for investment projects. Feed five input files (basic info / construction investment / revenue / cost / financing) and get 11 native financial statements plus IRR/MIRR/NPV indicators, a 12-sheet formula Excel, a financial dashboard, and Word reports (feasibility study / economic evaluation / national economic evaluation) — with 72-item consistency checks and goal-seeking. All numbers are computed by the engine; the AI only narrates.

## 核心能力 | Tools (21)

| 类别 | 工具 | 说明 |
|---|---|---|
| 接入门禁 | `get_protocol_instructions` | 接入总则（首次调用必读，72h 有效） |
| | `get_skill_instructions` | 9 类技能契约模板 |
| 测算 | `fast_calc_reports` | 五类输入 → 11 张报表 + 指标 + IRR 诊断 + 缺口扫描 |
| | `fast_calc_excel` | 12 表全公式 Excel（E投版式 + 勾稽自检页） |
| | `run_natural_language_model` | 自然语言 → 五类输入 → 测算 → Excel 全链 |
| | `fast_calc_solve` | 指标反算（IRR/NPV/回收期等 14 项目标） |
| | `run_uncertainty` | 单因素敏感性 + 多情景对比 |
| | `run_national_econ` | 国民经济评价（ENPV/EIRR/BCR，影子价格口径） |
| | `run_delivery_bundle` | 一键四件套（Excel+看板+敏感性+Word） |
| 报告 | `generate_word_report` | Word 报告（可研 8 章 / 经济评价 6 章 / 国民经济 10 章标准目录，版式/附表/数字防伪全自动） |
| | `generate_dashboard` | 财务可视化看板 HTML |
| | `generate_ppt_html` | 分析维度 PPT |
| | `get_chapter_data` | 报告章节取数（引擎值直供占位符） |
| 质量 | `run_model_check` | 报表勾稽体检（六段 72 项） |
| | `run_revenue_review` | 收入费用审查（三模块 16 项） |
| 估算 | `estimate_match` / `estimate_excel` / `estimate_etou_json` | 造价指标匹配 / 投资估算表 / 格式转换 |
| 其他 | `permitted_cost_excel` | 定价成本测算 |
| | `submit_feedback` | 用户反馈直达平台 |

## 快速开始 | Quick Start

**1. 获取令牌**：注册 [www.slgj.cn](https://www.slgj.cn) → [个人中心 → AI接入](https://www.slgj.cn/payment/mcp_access) → 生成 MCP 令牌（`sk-mcp-` 开头，30/90 天，可随时吊销）

**2. 配置客户端**（Claude Desktop / Cursor / VS Code / WorkBuddy 等通用）：

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
你：用这份五类输入数据做快速测算     → fast_calc_reports 返回 11 张报表
你：生成经济评价报告               → 返回 72h 下载短链的 .docx
```

> 报告生成类工具耗时 30-90 秒（含版式排版与数字防伪校验），已配 120 秒超时。

## 配额与合规 | Quota & Compliance

- 新用户 MCP 试用 7 天；VIP 公测期不限量；全部调用计量与审计
- 免责：测算结果基于用户输入与现行财税口径，仅供参考，不构成投资承诺
- 数据隔离：用户项目数据互不可见；成品短链 72 小时有效
- 令牌仅存于客户端本机，可随时在平台吊销

## 适用人群 | Who is it for

工程咨询机构 · 投资咨询顾问 · 项目投融资分析人员 · 财经专业师生

---

© 丝路E投 SLGJ · [www.slgj.cn](https://www.slgj.cn) · 服务持续在产运行，计算全部在服务端完成（本仓库为接入文档，不含引擎源码）
