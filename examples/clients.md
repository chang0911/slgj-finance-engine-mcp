# Claude Code 接入

```bash
claude mcp add --transport http slgj-finance \
  https://www.slgj.cn/skills-api/api/v1/mcp \
  --header "Authorization: Bearer sk-mcp-你的令牌"
```

添加后用 `/mcp` 查看连接状态，应显示 21 个工具。

# Cursor / Cline 接入（mcp.json）

```json
{
  "mcpServers": {
    "slgj-finance": {
      "url": "https://www.slgj.cn/skills-api/api/v1/mcp",
      "headers": { "Authorization": "Bearer <YOUR_TOKEN>" }
    }
  }
}
```

# Cherry Studio / DeepChat / 5ire 等表单型客户端

| 字段 | 值 |
|---|---|
| 类型 | Streamable HTTP（或 MCP、远程） |
| URL | `https://www.slgj.cn/skills-api/api/v1/mcp` |
| 请求头 | `Authorization: Bearer sk-mcp-你的令牌` |

> 令牌获取：[www.slgj.cn](https://www.slgj.cn) 注册 → 个人中心 → AI接入 → 生成专用令牌（`sk-mcp-` 开头）。
