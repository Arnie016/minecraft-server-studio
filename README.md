# Minecraft Server Studio

Minecraft Server Studio is a standalone repo for managing a local Minecraft Java server with two product surfaces:

- a small macOS menu bar app for seeing what server is live, what plugins are installed, and what the latest logs say
- a repo-local Codex plugin with focused Minecraft skills for server ops, AI builder work, and in-game command coaching

This mirrors the cleaner `FrameCrawler` pattern on your machine:

- standalone product repo
- repo-local Codex plugin inside the repo
- local install script for the plugin

## What is in this repo

- `apps/minecraft-server-studio`: SwiftUI macOS menu bar app
- `plugins/minecraft-server-studio`: repo-local Codex plugin bundle
- `scripts/run_minecraft_server_studio.sh`: generate, build, open, and run helper

## Minecraft Icon Bar Status

Yes, the Minecraft icon bar is implemented here as the macOS menu bar app.

It lives in:

- `apps/minecraft-server-studio`

Run it with:

```bash
cd /Users/arnav/Desktop/minecraft-server-studio
bash scripts/run_minecraft_server_studio.sh run
```

This repo is the app repo.

If you want the standalone Codex plugin repo instead, that now lives here:

- [`minecraft-codex-plugin`](https://github.com/Arnie016/minecraft-codex-plugin)

## What the icon bar can do now

The menu bar app is no longer just a server status panel. It now behaves like a small Minecraft control room with a more sophisticated macOS app structure:

- `Command Center`: live server state, launch controls, deployment brief, and top-level readiness
- `World Intel`: world-by-world insight using region counts, player traces, and auto-memory events
- `Server Lab`: create new local Paper server folders, clone your creative tooling stack, and keep a dedicated studio server workspace
- `Agents`: custom agent personalities with role, style preset, prompt seed, behavior notes, and memory participation
- `Ops Deck`: copyable WorldEdit, AI builder, and admin commands for fast operator workflows
- `World Memory`: CoreProtect-backed command/chat/block history plus notable `latest.log` events saved into local JSON
- Liquid-Glass-style surfaces on supported systems, with a strong fallback material design on older macOS versions

The default starter agents are:

- `Builder One`
- `Archivist`
- `Navigator`

The memory flow is designed so you can later plug more AI behavior into it without losing the world history.

The local server lab scaffolds new servers by:

- cloning a Paper jar from a selected source server
- writing a fresh `server.properties`
- creating a runnable `start-paper.sh`
- optionally copying only creative plugins or the whole plugin stack
- leaving `eula.txt` as `false` so you can review it yourself before first launch

## Product split

- `AcaciaAIBuilder` stays the Paper-side plugin that runs in the server
- `Minecraft Server Studio` becomes the local macOS and Codex control surface around that server

## Run the app

```bash
cd /Users/arnav/Desktop/minecraft-server-studio
bash scripts/run_minecraft_server_studio.sh doctor
bash scripts/run_minecraft_server_studio.sh run
```

The first run generates the Xcode project if needed, builds the app, and opens the built `.app`.

If you change Swift source files or add new files, the runner now regenerates the Xcode project before `open`, `build`, or `run`, so the app stays in sync with the repo.

## Install the Codex plugin

```bash
cd /Users/arnav/Desktop/minecraft-server-studio
bash plugins/minecraft-server-studio/install-local-plugin.sh
```

Then fully quit and reopen Codex desktop.

## Skills included

- `minecraft-server-studio`: product-level orchestration for this repo
- `minecraft-server-ops`: Paper lifecycle, backups, plugins, and server diagnosis
- `minecraft-command-coach`: screenshot-driven help for WorldEdit, claims, and command recovery
- `minecraft-ai-builder-lab`: Acacia AI builder prompt, style, and planning work

## Skill Catalog

### `minecraft-server-studio`

Use this for the product surface in this repo:

- menu bar app
- repo-local plugin wiring
- server discovery UI
- local app workflow

### `minecraft-server-ops`

Use this for the live Paper server:

- plugin inventory
- logs
- start and restart flows
- operational checks

### `minecraft-command-coach`

Use this for in-game screenshot help:

- WorldEdit
- claims
- command syntax recovery

### `minecraft-ai-builder-lab`

Use this for AI builder tuning:

- prompts
- styles
- larger plans
- validation rules

## FrameCrawler comparison

`FrameCrawler` on your Desktop is a separate repo with its own repo-local plugin. This repo now follows that same idea instead of living only inside `codex-goated-skills`.
