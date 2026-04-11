---
name: minecraft-server-ops
description: Inspect, start, restart, back up, and troubleshoot a local Minecraft Paper server, including plugin inventory, launch paths, logs, and migration-safe changes.
---

# Minecraft Server Ops

Use this skill when the task is about the practical server itself.

## Focus Areas

- detect the live Paper server folder
- inspect `plugins`, worlds, launch scripts, and logs
- restart or start the local server safely
- install or update Paper plugins
- check whether the server is actually listening on `25565`

## Deliverables

- identify the real live server path
- explain what is installed now
- give the next safe operational step
- avoid destructive world or plugin-data changes unless the user explicitly asks

## Default Checks

```bash
tail -n 120 /Users/arnav/minecraftserverlocal/logs/latest.log
lsof -nP -iTCP:25565 -sTCP:LISTEN
find /Users/arnav/minecraftserverlocal/plugins -maxdepth 1 -name '*.jar' | sort
```
