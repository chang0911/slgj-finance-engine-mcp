# 各客户端接入配置片段
端点：`https://www.slgj.cn/skills-api/api/v1/mcp`
鉴权头：`Authorization: Bearer <你的sk-mcp-令牌>`（Bearer 前缀可省略）
## Cursor / Cline / VS Code / CodeBuddy / Cherry Studio 等
通用 `mcpServers` 结构（url + headers）：
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
## Claude Desktop
方式一：Settings → Connectors → Add custom connector，填服务端点 URL。
（注意：自定义连接器界面若不支持填写自定义请求头，请用方式二。）
方式二（桥接，支持自定义请求头）：`claude_desktop_config.json`：
```json
{
  "mcpServers": {
    "slgj-finance": {
      "command": "npx",
      "args": [
        "-y", "mcp-remote",
        "https://www.slgj.cn/skills-api/api/v1/mcp",
        "--header", "Authorization: ${SLGJ_TOKEN}"
      ],
      "env": { "SLGJ_TOKEN": "Bearer sk-mcp-****" }
    }
  }
}
```
> 需要 Node.js ≥ 18（npx 可用）。`mcp-remote` 会把 Streamable HTTP 桥接为 stdio。
## 仅支持 stdio 的老客户端（通用桥接）
同上，用 `npx -y mcp-remote <url> --header "Authorization: Bearer <令牌>"` 即可。
## 百炼（阿里云）自定义 MCP 服务
MCP 管理 → 创建MCP服务 → 脚本部署 → 安装方式选 **http** → 配置粘贴上面的通用 JSON。
## 提醒
- 令牌只在客户端配置里使用，**不要写进任何公开仓库**；
- 首次使用成品类工具（fast_calc_excel / run_delivery_bundle / run_uncertainty / estimate_excel / estimate_etou_json / ppt_extract_data / generate_ppt_html / permitted_cost_excel）前，先调用一次 `get_protocol_instructions`（72 小时内有效）。
