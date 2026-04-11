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

## FrameCrawler comparison

`FrameCrawler` on your Desktop is a separate repo with its own repo-local plugin. This repo now follows that same idea instead of living only inside `codex-goated-skills`.
