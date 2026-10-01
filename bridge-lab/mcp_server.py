"""Optional local stdio planning tools. No game control or network listener."""
from mcp.server.fastmcp import FastMCP
from mcp.types import ToolAnnotations
from bridge import list_bridges, plan_bridge, replay_demo

mcp = FastMCP('Ashfall Bridge Lab')
for fn in (list_bridges, plan_bridge, replay_demo):
    mcp.tool(annotations=ToolAnnotations(readOnlyHint=True, destructiveHint=False,
                                        idempotentHint=True, openWorldHint=False))(fn)

if __name__ == '__main__':
    mcp.run(transport='stdio')
