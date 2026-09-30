import asyncio,sys
from pathlib import Path
from mcp import ClientSession,StdioServerParameters
from mcp.client.stdio import stdio_client
ROOT=Path(__file__).resolve().parents[1]
async def main():
    async with stdio_client(StdioServerParameters(command=sys.executable,args=[str(ROOT/'tools/mcp_server.py')])) as (read,write):
        async with ClientSession(read,write) as client:
            await client.initialize()
            tools=await client.list_tools()
            assert {t.name for t in tools.tools}=={'list_packs','get_pack','verify_pack','installation_plan'}
            result=await client.call_tool('list_packs',{'kind':'resourcepack'})
            assert not result.isError and 'signalkeepers-models' in str(result)
            result=await client.call_tool('verify_pack',{'pack_id':'fieldcraft'})
            assert not result.isError and 'true' in str(result).lower()
            result=await client.call_tool('installation_plan',{'pack_ids':['signalkeepers-models']})
            assert not result.isError and 'signalkeepers' in str(result)
            result=await client.call_tool('get_pack',{'pack_id':'../../secrets'})
            assert result.isError
    print('MCP initialize, discovery, search, verification, dependency plan and invalid-ID rejection passed.')
asyncio.run(main())
