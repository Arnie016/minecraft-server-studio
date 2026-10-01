"""Integration check against the real stdio MCP client/server."""
import asyncio
import json
import sys
from pathlib import Path
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client


async def main():
    params = StdioServerParameters(command=sys.executable,
                                  args=[str(Path(__file__).with_name('mcp_server.py'))])
    async with stdio_client(params) as (reader, writer):
        async with ClientSession(reader, writer) as session:
            await session.initialize()
            names = {tool.name for tool in (await session.list_tools()).tools}
            assert names == {'list_bridges', 'plan_bridge', 'replay_demo'}, names
            for name, args in [('list_bridges', {}), ('replay_demo', {}),
                               ('plan_bridge', {'target': 'assassins-creed', 'platform': 'macos'})]:
                result = await session.call_tool(name, args)
                assert not result.isError, result
                if name == 'plan_bridge':
                    data = json.loads(result.content[0].text)
                    assert data['verdict'] == 'blocked' and data['playable'] is False
            print('MCP initialize, discovery and three tool calls passed')


if __name__ == '__main__':
    asyncio.run(main())
