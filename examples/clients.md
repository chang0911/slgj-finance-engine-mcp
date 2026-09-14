# 客户端接入配置速查

端点：`https://www.slgj.cn/skills-api/api/v1/mcp`　鉴权头：`Authorization: Bearer <你的sk-mcp-令牌>`（Bearer 前缀可省）

> 令牌获取：[www.slgj.cn](https://www.slgj.cn) 注册 → 个人中心 → AI接入 → 生成专用令牌（`sk-mcp-` 开头）。

## Claude Code（命令行）

```bash
claude mcp add --transport http slgj-finance \
  https://www.slgj.cn/skills-api/api/v1/mcp \
  --header "Authorization: Bearer ***你的令牌"
```

添加后用 `/mcp` 查看连接状态，应显示 21 个工具。

## Claude Desktop

方式一：Settings → Connectors → Add custom connector，填服务端点 URL（界面若不支持自定义请求头，用方式二）。

方式二（mcp-remote 桥接，支持自定义请求头）— `claude_desktop_config.json`：

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

## Cursor / Cline / VS Code (Copilot) / CodeBuddy / Cherry Studio 等

通用 `mcpServers` 结构（`url` + `headers`）：

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

VS Code 原生写法见 [vscode-mcp.json](vscode-mcp.json)（`"type": "http"`）。

## Cherry Studio / DeepChat / 5ire 等表单型客户端

| 字段 | 值 |
|---|---|
| 类型 | Streamable HTTP（或 MCP、远程） |
| URL | `https://www.slgj.cn/skills-api/api/v1/mcp` |
| 请求头 | `Authorization: Bearer ***你的令牌` |

## 仅支持 stdio 的老客户端（通用桥接）

```bash
npx -y mcp-remote https://www.slgj.cn/skills-api/api/v1/mcp \
  --header "Authorization: Bearer <令牌>"
```

## 阿里云百炼（自定义 MCP 服务）

MCP 管理 → 创建MCP服务 → 脚本部署 → 安装方式选 **http** → 配置粘贴上面的通用 JSON。

## 提醒

- 令牌只在客户端配置里使用，**不要写进任何公开仓库**；
- 首次使用成品类工具（`fast_calc_excel` / `run_delivery_bundle` / `run_uncertainty` / `estimate_excel` / `estimate_etou_json` / `ppt_extract_data` / `generate_ppt_html` / `permitted_cost_excel`）前，先调用一次 `get_protocol_instructions`（72 小时内有效）。
