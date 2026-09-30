"""Local stdio MCP catalogue. Never installs, executes commands or publishes."""
from mcp.server.fastmcp import FastMCP
from mcp.types import ToolAnnotations
from catalog_api import list_packs,get_pack,verify_pack,installation_plan
mcp=FastMCP('Ashfall Workshop')
annotations=ToolAnnotations(readOnlyHint=True,destructiveHint=False,idempotentHint=True,openWorldHint=False)
for fn in [list_packs,get_pack,verify_pack,installation_plan]:
    mcp.tool(annotations=annotations)(fn)
if __name__=='__main__':mcp.run(transport='stdio')
