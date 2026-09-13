# 丝路E投财务引擎 MCP 用户接入指南

> 版本 v1.1（2026-09-13）　适用：希望通过 AI 客户端（Claude / Cursor / VS Code / CodeBuddy / Cherry Studio 等）调用丝路E投财务引擎的用户

## 一、申请专用令牌

1. 打开 [https://www.slgj.cn](https://www.slgj.cn) 注册/登录（游客账号不支持 AI 接入）；
2. 进入 **个人中心 → AI接入** 页；
3. 点击 **「生成专用令牌」**，复制保存。

| 项目 | 说明 |
|---|---|
| 形态 | `sk-mcp-` 开头 |
| 数量 | 每账号最多 3 把 |
| 有效期 | 30 / 90 天（生成时自选），不随网页登录过期 |
| 安全 | 新令牌仅生成时完整显示一次，请立即保存 |
| 吊销 | 同一页面可随时吊销；疑似泄露立即吊销并重新生成 |

## 二、配置客户端

在客户端 MCP 设置中添加（各端 mcp.json / mcp_config.json 路径按官方惯例）：

```json
{
  "mcpServers": {
    "slgj-finance": {
      "url": "https://www.slgj.cn/skills-api/api/v1/mcp",
      "headers": { "Authorization": "***" }
    }
  }
}
```

Claude Desktop 等不支持远程自定义请求头的客户端，用 `npx mcp-remote` 桥接，见 [examples/client-configs.md](../examples/client-configs.md)。

## 三、首次握手

成品类工具（见工具清单标 🔑 者）首次调用前，先调用一次 `get_protocol_instructions` 阅读接入总则，72 小时内免重复握手。主流客户端的模型会按工具描述自动完成。

## 四、接入信息速查

| 项目 | 值 |
|---|---|
| 服务端点 | `https://www.slgj.cn/skills-api/api/v1/mcp` |
| 协议 | MCP（JSON-RPC 2.0），Streamable HTTP 的 POST/JSON 档（不提供 SSE，GET 返回 405） |
| 鉴权 | 请求头 `Authorization: Bearer <令牌>`（Bearer 前缀可省略） |
| 会话 | 无状态，无需维持会话连接 |
| 工具目录 | `tools/list` 免鉴权可查 |
| 计费 | 按次从平台会员余额扣除，失败自动退款 |

## 五、工具清单（21 个）

**接入准备**：`get_protocol_instructions`（读取接入总则）｜`get_skill_instructions`（技能工作流指令模板）

**财务测算与交付**：`fast_calc_reports`（11张报表+指标 JSON）🔑｜`fast_calc_excel`（12表全公式 Excel）🔑｜`run_delivery_bundle`（Excel+看板+敏感性+可选Word 四件套）🔑｜`fast_calc_solve`（指标反算）

**分析与体检**：`run_model_check`（勾稽体检 73 项）｜`run_revenue_review`（收入费用审查 16 项）｜`run_uncertainty`（敏感性/情景/蒙特卡洛）🔑

**报告与演示**：`generate_word_report`（公文/可研/经济评价/国民经济 Word）｜`generate_dashboard`（财务看板 HTML）｜`get_chapter_data`（章节取数）｜`ppt_extract_data`（PPT取数）🔑｜`generate_ppt_html`（PPT封装）🔑

**估算、定价与国民经济**：`match_cost_indicators`（造价指标匹配）｜`estimate_excel`（估算 Excel）🔑｜`estimate_etou_json`（估算转E投格式）🔑｜`permitted_cost_excel`（准许成本定价）🔑｜`run_national_econ`（国民经济评价）

**用量与反馈**：`query_usage`（用量统计）｜`submit_feedback`（提交反馈）

> 🔑 = 需先完成一次协议握手。每个工具的参数以客户端 `tools/list` 返回的 inputSchema 为准。
> 数据入口两种通用：① `files` 直传 5 类输入 txt（project_basic_info / construction_data / revenue_data / cost_data / financing_data）；② `p_id` 传平台项目号（只能访问令牌归属账号自己的项目）。

## 六、常见报错对照

| 报错（关键词） | 含义 | 处置 |
|---|---|---|
| `AUTH` / 401 | 令牌缺失、错误、已吊销或过期 | 个人中心 → AI接入 重新生成令牌 |
| `PROTOCOL` / 428 | 成品类工具首次调用未读总则 | 先调 `get_protocol_instructions`（72h 有效）后重试 |
| `BAD_PARAM` / 422 | 参数不合规（如 files 缺文件） | 按工具 schema 补齐：files 必须且仅含 5 类输入文件 |
| 账户余额不足 | 会员余额低于本次价格 | 前往平台充值后重试 |
| 游客账号不支持 AI 接入 | 当前为游客身份 | 注册/登录正式账号 |
| MCP 试用期已结束 | 试用到期 | 开通 VIP 会员（公测活动期内不限量） |
| `-32700` / `-32600` | 请求体不是合法 JSON-RPC | 检查 Content-Type 与请求体格式 |

## 七、注意事项

1. **令牌即账户凭证**：妥善保管，勿提交至公开代码仓库；疑似泄露立即吊销重新生成；
2. **数据隔离**：`p_id` 模式只能访问令牌归属账号自己的项目；`files` 直传为无状态计算，平台不留存输入数据；
3. **成品短链 72 小时有效**：Excel/看板/Word 等成品默认返回 72h 下载短链，请及时下载；也可要 base64 回传；
4. **超时设置**：`run_uncertainty` 完整模式 1-3 分钟（客户端超时建议 ≥300 秒）、`run_delivery_bundle` 25-30 秒（≥60 秒）、可研/经济评价 Word 报告建议 ≥120 秒；
5. **数字严谨性**：报表数字一律引用工具返回值，禁止自行换算；
6. 服务只返回计算结果与成品文件，不提供源码。

## 八、最小调用示例

见 [examples/quickstart.sh](../examples/quickstart.sh) 与 [examples/python_client.py](../examples/python_client.py)。

## 九、免责声明

引擎输出为财务测算参考结果，不构成任何投资承诺或担保，最终决策请自行判断。使用问题通过丝路E投平台（www.slgj.cn）客服或 `submit_feedback` 工具反馈。
