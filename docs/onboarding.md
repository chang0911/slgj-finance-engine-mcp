# 丝路e投财务模型引擎 MCP 用户接入说明

> 版本：v1.2（2026-09-17 同步生产 23 工具）　适用对象：希望通过 AI 客户端（Claude / Cursor / VS Code / CodeBuddy / Cherry Studio 等）调用丝路E投财务引擎的用户

丝路e投财务模型引擎把全寿命财务模型能力开放为标准 MCP 服务：**23 个工具**覆盖结构化数据采集（intake 宽进）、财务测算、指标反算、借款还本付息计算、Excel/看板/Word/PPT 成品生成、投资估算、准许成本定价、国民经济评价、不确定性分析、报表勾稽体检与收入费用审查。接入后，在 AI 客户端里直接用自然语言描述需求即可完成建模、测算与成品交付。

---

## 一、快速开始（三步）

### 第 1 步：申请专用令牌

1. 打开 [https://www.slgj.cn](https://www.slgj.cn) **注册/登录**（游客账号不支持 AI 接入）；
2. 进入 **个人中心 → AI接入** 页；
3. 点击 **「生成专用令牌」**，复制保存。

令牌规则：

| 项目 | 说明 |
|---|---|
| 形态 | `sk-mcp-` 开头 |
| 数量 | 每账号最多 **3 把** |
| 有效期 | **30 / 90 天**（生成时自选），不随网页登录过期 |
| 安全 | 新令牌**仅生成时完整显示一次**，请立即保存 |
| 吊销 | 同一页面可随时吊销；疑似泄露请立即吊销并重新生成 |

### 第 2 步：配置 AI 客户端

在客户端的 MCP 设置中添加（各端 mcp.json / mcp_config.json 路径按官方惯例）：

```json
{
  "mcpServers": {
    "slgj-finance-engine": {
      "url": "https://www.slgj.cn/skills-api/api/v1/mcp",
      "headers": { "Authorization": "Bearer sk-mcp-您的令牌" }
    }
  }
}
```

保存后客户端会自动发现全部 23 个工具。

### 第 3 步：首次使用先握手

成品类工具（见下方清单中标 🔑 者）**首次调用前**，需先调用一次 `get_protocol_instructions` 阅读 Agent 接入总则，**72 小时内免重复握手**。主流客户端的模型会按工具描述自动完成，一般无需人工干预。

**结构化宽进 intake（2026-09-17 新增，推荐）**：不必手工组装 5 类 txt——直接把项目信息按业务语义传 `intake` 参数（fast_calc_reports / fast_calc_excel / run_delivery_bundle / generate_dashboard / run_uncertainty / generate_word_report 均支持）：

- 中英文字段名、万元/元/亿元、月/年、`9%`/`0.09` 均宽容识别，自动归一化为引擎原生格式
- 关键数据缺失 → 返回 `INTAKE_INCOMPLETE` + gaps 问话清单（照着问用户即可）；非关键缺失 → 自动代行业默认值并记入 assumptions 账本随交付返回（交付时向用户说明）
- 字段可传置信度包裹 `{"value": 300, "source": "可研P8", "confidence": "low"}`，低置信自动升级为「请与用户确认」问话
- 首次成功自动存草稿；改参数只需 `{"draft_id": "...", "patch": {"融资": {"资本金比例": 40}}}` 秒级重算
- 固定表单采集的宿主：先调 `get_intake_template` 拿 6 节 41 字段问卷模板，填完天然合规
- 字段结构详见 `get_skill_instructions(skill=nlmodel)` 的「结构化直传 intake」节

之后直接对话即可，例如：

> 「帮我测算一个污水处理厂项目：总投资 2.3 亿，资本金 20%，处理费 1.8 元/吨，运营期 15 年，出一份全公式 Excel 和偿债能力分析。」

---

## 二、接入信息速查

| 项目 | 值 |
|---|---|
| 服务端点 | `https://www.slgj.cn/skills-api/api/v1/mcp` |
| 协议 | MCP（JSON-RPC 2.0），**Streamable HTTP 的 POST/JSON 档**（不提供 SSE；仅支持 POST，GET 返回 405） |
| 鉴权 | 请求头 `Authorization: Bearer <令牌>`（`Bearer ` 前缀可省略） |
| 会话 | 无状态，无需维持会话连接 |
| 工具目录 | 可凭 `tools/list` 免鉴权查看 |
| 计费 | 按次从平台**会员余额**扣除（详见第四节） |

---

## 三、工具清单（23 个）

**接入准备**

| 工具 | 说明 | 握手 |
|---|---|---|
| get_intake_template | 结构化采集问卷模板：6 节 41 字段（🔴必填/🟡默认值/类型/单位/枚举/业务解释），填完天然合规 | — |
| get_protocol_instructions | 读取 Agent 接入总则（目录结构/文件命名/成品规范） | — |
| get_skill_instructions | 读取技能工作流指令模板（快速测算/估算/演示/定价/可研/经济评价等） | — |

**财务测算与交付**

| 工具 | 说明 | 握手 |
|---|---|---|
| fast_calc_reports | 5类输入 → 11张标准报表+财务指标+IRR/MIRR诊断（JSON 取数） | — |
| fast_calc_excel 🔑 | 5类输入 → 12表全公式 Excel（E投口径），返回 72h 下载短链 | 需 |
| run_delivery_bundle 🔑 | 一键四件套：Excel+看板+敏感性+可选 Word（25-30s） | 需 |
| fast_calc_solve | 指标反算：给定目标值（如全投资税后 IRR=8%），秒级反推收入/成本/建设投资调整幅度 | — |
| run_debt_calculator | 借款还本付息计算：十一种还款方式、分段方式/分段利率、宽限期、罚息模拟、多笔组合；双计息口径（月对月E投口径/银行算息到日） | — |

**分析与体检**

| 工具 | 说明 | 握手 |
|---|---|---|
| run_model_check | 报表勾稽体检：E/A/F/B/C/D 六段 73 项校验 | — |
| run_revenue_review | 收入费用合理性审查：R/C/X 三模块 16 项 | — |
| run_uncertainty 🔑 | 敏感性/情景/蒙特卡洛+总报告（quick≈20-25s，完整 1-3 分钟） | 需 |

**报告与演示**

| 工具 | 说明 | 握手 |
|---|---|---|
| generate_word_report | Word 报告：公文格式 / 可研8章 / 经济评价6章 / 国民经济专项，附表自动组装+数字防伪 | — |
| generate_dashboard | 财务看板：动态资金流演绎+双口径偿债能力，单文件 HTML 可离线 | — |
| get_chapter_data | 可研/经济评价报告按章节取数（含数字占位符清单） | — |
| ppt_extract_data 🔑 | 演示文稿取数：报表 → 结构化 JSON | 需 |
| generate_ppt_html 🔑 | 演示封装：内容 HTML → 自包含 HTML（Plotly 内联离线可用） | 需 |

**估算、定价与国民经济**

| 工具 | 说明 | 握手 |
|---|---|---|
| match_cost_indicators | 造价指标匹配：子项描述 → 平台指标库候选 | — |
| estimate_excel 🔑 | 投资估算：估算 JSON → 三表全公式 Excel | 需 |
| estimate_etou_json 🔑 | 估算转 E投格式 construction_data.json | 需 |
| permitted_cost_excel 🔑 | 准许成本+合理收益定价全公式 Excel | 需 |
| run_national_econ | 国民经济评价：ENPV/EIRR/BCR+可行判定+敏感性 | — |

**用量与反馈**

| 工具 | 说明 | 握手 |
|---|---|---|
| query_usage | 查询自己当月调用量/流量/耗时统计 | — |
| submit_feedback | 向平台提交使用反馈 | — |

> 每个工具的参数以客户端 `tools/list` 返回的 inputSchema 为准。两种数据入口通用：①`files` 直接传 5 类输入 txt（project_basic_info / construction_data / revenue_data / cost_data / financing_data）；②`p_id` 传平台项目号（**只能访问令牌归属账号自己的项目**）。

---

## 四、计费说明

- 成品类工具**按次计费**，从丝路E投**会员余额**预扣；调用执行失败**自动退款**；
- **公测活动期内 VIP 会员不限量使用**；新用户试用政策以平台公示为准；
- 余额不足时调用会被拒绝并提示充值；
- 价目以平台公示为准。

---

## 五、常见报错对照

| 报错（关键词） | 含义 | 处置 |
|---|---|---|
| `AUTH` / 401 | 令牌缺失、错误、已吊销或过期 | 个人中心 → AI接入 重新生成令牌 |
| `PROTOCOL` / 428 | 成品类工具首次调用未读总则 | 先调用 `get_protocol_instructions`（72h 内有效）后重试 |
| `BAD_PARAM` / 422 | 参数不合规（如 files 缺文件） | 按工具 schema 补齐：files 必须且仅含 5 类输入文件 |
| `UNBALANCED` / 422 | 资产负债表勾稽不平，系统拒绝出表/出稿（引擎自检+交付物双层校验） | 按提示修正输入数据后重算；提示「渲染层校验/系统缺陷」时属平台侧问题，稍后重试或联系排查 |
| 账户余额不足 | 会员余额低于本次价格 | 前往平台充值后重试 |
| 游客账号不支持 AI 接入 | 当前为游客身份 | 注册/登录正式账号 |
| MCP 试用期已结束 | 试用到期 | 开通 VIP 会员（公测活动期内不限量） |
| `-32700` / `-32600` | 请求体不是合法 JSON-RPC | 检查 Content-Type 与请求体格式 |

---

## 六、注意事项

1. **令牌即账户凭证**：请妥善保管，勿提交至公开代码仓库；疑似泄露立即吊销并重新生成；
2. **数据隔离**：`p_id` 模式只能访问令牌归属账号自己的项目；`files` 直传为无状态计算，平台不留存输入数据；
3. **成品短链 72 小时有效**：Excel/看板/Word 等成品默认返回 72h 下载短链，请及时下载；也可要 base64 回传；
4. **超时设置**：`run_uncertainty` 完整模式 1-3 分钟（建议客户端超时 ≥300 秒）、`run_delivery_bundle` 25-30 秒（建议 ≥60 秒）、可研/经济评价 Word 报告建议 ≥120 秒；
5. **数字严谨性**：报表数字一律引用工具返回值，禁止自行换算——这是与平台口径一致的保证；
6. 引擎只返回计算结果与成品文件，不提供源码。

---

## 七、最小调用示例（curl）

```bash
# ① 初始化（常规客户端自动完成）
curl -s -X POST https://www.slgj.cn/skills-api/api/v1/mcp \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer sk-mcp-您的令牌' \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"demo","version":"1.0"}}}'

# ② 查看工具目录（免鉴权）
curl -s -X POST https://www.slgj.cn/skills-api/api/v1/mcp \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'

# ③ 调用工具（示例：造价指标匹配，免握手）
curl -s -X POST https://www.slgj.cn/skills-api/api/v1/mcp \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer sk-mcp-您的令牌' \
  -d '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"match_cost_indicators","arguments":{"query":"污水处理厂 5万吨/日"}}}'
```

---

## 八、免责声明与支持

- 引擎输出为财务测算参考结果，不构成任何投资承诺或担保，最终决策请自行判断；
- 使用问题与商务合作请通过丝路E投平台（www.slgj.cn）联系客服，或通过 `submit_feedback` 工具提交反馈。

丝路E投 · 全寿命财务模型与 AI 双引擎驱动
