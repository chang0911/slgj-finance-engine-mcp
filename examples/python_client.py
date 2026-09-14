#!/usr/bin/env python3
"""丝路E投财务引擎 MCP 客户端最小示例（官方 Python SDK，Streamable HTTP）。
依赖：pip install "mcp>=1.8"
用法：SLGJ_TOKEN=*** python3 python_client.py
"""
import asyncio
import os
from mcp import ClientSession
from mcp.client.streamable_http import streamablehttp_client
ENDPOINT = "https://www.slgj.cn/skills-api/api/v1/mcp"
async def main() -> None:
    token = os.environ["SLGJ_TOKEN"]
    async with streamablehttp_client(
        ENDPOINT, headers={"Authorization": f"Bearer {token}"}
    ) as (read_stream, write_stream, _):
        async with ClientSession(read_stream, write_stream) as session:
            await session.initialize()
            # ① 工具目录
            tools = await session.list_tools()
            print(f"{len(tools.tools)} 个工具：", " / ".join(t.name for t in tools.tools))
            # ② 调用工具：造价指标匹配（免握手）
            result = await session.call_tool(
                "match_cost_indicators", {"query": "污水处理厂 5万吨/日"}
            )
            for item in result.content:
                if getattr(item, "text", None):
                    print(item.text[:2000])
if __name__ == "__main__":
    asyncio.run(main())
