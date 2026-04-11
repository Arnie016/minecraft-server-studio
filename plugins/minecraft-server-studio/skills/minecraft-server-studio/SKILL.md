---
name: minecraft-server-studio
description: Work on the real Minecraft Server Studio product, including the macOS menu bar app, repo-local Codex plugin, local Paper server discovery, and the connection between server-side plugins and the local control surface.
---

# Minecraft Server Studio

Use this skill when the user wants the product surface for Minecraft Server Studio itself improved or explained.

## Repo Scope

- Repo root: `/Users/arnav/Desktop/minecraft-server-studio`
- Menu bar app: `/Users/arnav/Desktop/minecraft-server-studio/apps/minecraft-server-studio`
- Repo-local plugin: `/Users/arnav/Desktop/minecraft-server-studio/plugins/minecraft-server-studio`

## Product Boundary

Minecraft Server Studio owns:

- the local macOS menu bar app for server visibility
- the repo-local Codex plugin and focused skills
- discovery of likely Paper server folders
- fast visibility into plugins, worlds, logs, and start paths

Minecraft Server Studio does not replace:

- the Paper-side `AcaciaAIBuilder` plugin
- Minecraft gameplay itself
- remote hosting control panels

## Working Rules

- Keep the menu bar app compact and operational, not dashboard-bloated.
- Prefer showing the real local server state over presenting static help text.
- Treat screenshots from Minecraft chat as the primary debug signal for command coaching.
- Keep the Codex plugin and the macOS app aligned, but clearly separated.

## Validation

- `bash scripts/run_minecraft_server_studio.sh doctor`
- `bash scripts/run_minecraft_server_studio.sh build`
- `bash plugins/minecraft-server-studio/install-local-plugin.sh`
