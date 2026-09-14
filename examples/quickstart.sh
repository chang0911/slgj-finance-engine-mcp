#!/usr/bin/env sh
# 丝路E投财务引擎 MCP 最小调用示例
# 用法：export SLGJ_TOKEN="***" && sh quickstart.sh
set -eu
ENDPOINT="https://www.slgj.cn/skills-api/api/v1/mcp"
AUTH="Authorization: Bearer ${SLGJ_TOKEN:?需要先 export SLGJ_TOKEN=***}"
echo "== ① 初始化（常规客户端自动完成） =="
curl -s -X POST "$ENDPOINT" \
  -H 'Content-Type: application/json' -H "$AUTH" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"demo","version":"1.0"}}}'
echo
echo "== ② 工具目录（免鉴权） =="
curl -s -X POST "$ENDPOINT" \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' \
| python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d['result']['tools']), '个工具'); [print('-', t['name']) for t in d['result']['tools']]"
echo
echo "== ③ 调用工具：造价指标匹配（免握手） =="
curl -s -X POST "$ENDPOINT" \
  -H 'Content-Type: application/json' -H "$AUTH" \
  -d '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"match_cost_indicators","arguments":{"query":"污水处理厂 5万吨/日"}}}'
echo
