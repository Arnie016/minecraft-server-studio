# Ashfall Workshop · 0.1.0 alpha

[Free download site](https://ashfall-workshop.stashofdoodlido.chatgpt.site) · [GitHub release](https://github.com/Arnie016/minecraft-server-studio/releases/tag/workshop-v0.1.0) · [Publication record](docs/PUBLISHED.md)

Free, versioned Minecraft Java **1.21.1** packs and a no-login static catalogue,
with a read-only local MCP server for agent discovery and installation planning.
Maintained under **Arnie016/minecraft-server-studio**. The existing Mac app and
Codex plugin are independent of this directory.

## Build and preview

```sh
python3 pack-foundry/tools/build.py
python3 -m unittest discover -s pack-foundry/tests -p test_release.py -v
python3 -m http.server 8080 --bind 127.0.0.1 --directory pack-foundry/site
```

Open http://localhost:8080. `dist/` contains five installable ZIPs, an outer
collection bundle, `SHA256SUMS` and `catalog.json`. Unzip the **bundle** first;
install individual pack ZIPs intact. No end-user account or external asset CDN.
Source builds require Python 3.12+. Packs require no Python or MCP to play.

| Pack | What it does | Start |
|---|---|---|
| Signalkeepers | Shared relay expedition, scanner, winch, two endings | `/trigger sk_start` |
| Field Instruments | Three optional Signalkeepers item models | Enable resource pack |
| Trail Ledger | Seven-biome advancement journal and completion compass | Advancements → Trail Ledger |
| Hearthside | Optional campfire resting and brief regeneration | `/trigger hearth_toggle` |
| Fieldcraft | Six survival crafting/smelting recipes | Recipe book |

All are **alpha**. New additions need human graphical playtesting. Minecraft
version ports, full NeoForge compatibility, dinosaurs and physical swinging are
not part of this release. See [TESTING.md](docs/TESTING.md) for actual evidence.

## Agent connection

```sh
python3 -m venv .venv
.venv/bin/pip install -r pack-foundry/requirements.txt
.venv/bin/python pack-foundry/tools/mcp_server.py
```

Configure your local MCP client with command `/ABSOLUTE/REPO/.venv/bin/python`
and argument `/ABSOLUTE/REPO/pack-foundry/tools/mcp_server.py`. This uses stdio.
The tools are `list_packs`, `get_pack`, `verify_pack`, and `installation_plan`.
They do not install into saves, run shell commands, fetch arbitrary URLs, or
publish to marketplaces. For end-to-end protocol checks:

```sh
.venv/bin/python pack-foundry/tests/test_mcp.py
```

## Ownership and authenticity

Each ZIP has `ASHFALL-PROVENANCE.json`, `LICENSE.txt` and `INSTALL.txt`.
Creator metadata is attribution, not DRM. SHA-256 detects content changes against
a trusted manifest; it cannot establish identity on its own. The GitHub workflow
builds and attests release files under the repository identity. Check a published
release for the actual attestation; local builds are unsigned.

```sh
# Run in the downloaded release directory:
shasum -a 256 -c SHA256SUMS
# With GitHub CLI, verify repository-bound provenance for a downloaded ZIP:
gh attestation verify fieldcraft-0.1.0-java-1.21.1.zip -R Arnie016/minecraft-server-studio
```

Do not claim a build is authenticated unless that verification passes. Neither
hashes nor signatures guarantee that software is bug-free or safe for every save.

## Publishing and agent handoff

See [AGENT_HANDOFF.md](docs/AGENT_HANDOFF.md) for the next agent's exact starting
point and [DISTRIBUTION.md](docs/DISTRIBUTION.md) for marketplace preparation and
revenue constraints. Versioned free GitHub releases are the first distribution
route. Marketplace approval, payouts and a public website deployment are separate
statuses; none should be inferred merely from files existing in this repository.

AI disclosure: code, writing and original model geometry were substantially
created with AI assistance. Referenced vanilla textures belong to their owners
and are not bundled. The MIT license applies only to original files in this
subdirectory, to the extent rights exist. This is not an official Minecraft
product and is not approved by or associated with Mojang or Microsoft.
