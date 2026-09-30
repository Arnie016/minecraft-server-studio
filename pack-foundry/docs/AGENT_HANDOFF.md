# Agent handoff · Ashfall Workshop

## Start here

Repository: https://github.com/Arnie016/minecraft-server-studio
Branch: `feat/pack-foundry-v0.1.0`
Working directory: `pack-foundry/`
Version: `0.1.0` alpha, Minecraft Java `1.21.1` only.

```sh
git fetch origin
git switch feat/pack-foundry-v0.1.0
python3 pack-foundry/tools/build.py
python3 -m unittest discover -s pack-foundry/tests -p test_release.py -v
```

Read README.md, catalog.source.json, docs/TESTING.md and docs/DISTRIBUTION.md.
The existing Swift application and Codex plugin are separate and must be preserved.
Never assume the private minecraft-launchpad repository is the public catalogue.

## Sources of truth

- `catalog.source.json`: product names, target, version, authorship and caveats.
- `tools/generate.py`: Trail Ledger, Hearthside and Fieldcraft source generator.
- `packs/signalkeepers/tools/build.py`: Signalkeepers generator recovered from
  the previous creator kit. Generated `.mcfunction` edits must also change this.
- `tools/build.py`: deterministic ZIPs, per-file provenance, bundle and website.
- `web/`: no-login catalogue; CSS illustration is not a screenshot of gameplay.
- `tools/mcp_server.py`: local stdio MCP using the official Python SDK.
- `docs/DISTRIBUTION.md`: marketplace submission prerequisites and business model.
- `.github/workflows/pack-foundry.yml`: CI, initial branch alpha release and explicit later releases.

## Next acceptance work

1. Human playthrough of all five packs on vanilla Java 1.21.1. Record footage.
2. Test the actual Ashfall NeoForge mod stack on the Mac, in a copied world.
3. Review model-pack ordering and compatibility with other item model overrides.
4. Verify Hearthside timing/hunger and offline-player uninstall edge cases.
5. Capture real marketplace screenshots and make an original 400×400 project icon.
6. Create CurseForge project IDs, then upload reviewed alpha files with accurate
   AI disclosure and validation status. Keep credentials in secret storage.
7. The no-login public catalogue is deployed. See PUBLISHED.md for its URL and
   exact hosting identity. Reuse that Site for future updates.
8. The initial branch push runs a gated alpha-release job. Later versions can
   use workflow_dispatch with publish=true. Verify
   the attestation before describing downloads as authenticated.

## Expansion rules

Keep the collection useful, original and small enough to maintain. Add actual
mechanics, not cosmetic clones marketed as new mods. The current items are data
and resource packs, not Fabric/NeoForge JAR mods. Native mod development requires
a separate loader project and test matrix. Never describe the current winch as
physical pendulum swinging or claim dinosaurs exist in this release.

Possible next milestone: a proper Canopy movement prototype with collision,
multiplayer ownership and accessibility controls; validate feel before artwork.
A future village-rumour system is a distinct project, not implemented here.

## Reporting

Commit each completed change with its test evidence. Record failures and remaining
human checks honestly. Keep GitHub links and version IDs in handoffs so agents do
not reconstruct lost context. Never publish personal logs, save backups or keys.
