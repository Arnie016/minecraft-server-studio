---
name: minecraft-ai-builder-lab
description: Tune the Acacia AI builder workflow, including style presets, prompt sizing, repair loops, validation rules, and ambitious but buildable plans grounded in real Minecraft command limits.
---

# Minecraft AI Builder Lab

Use this skill when the task is about the AI builder planning loop rather than generic server ops.

## Focus Areas

- prompt sizing and command-count tradeoffs
- style preset design and custom style overlays
- validating `fill`, `setblock`, and coordinate usage
- using URLs and references to ground build prompts
- making plans bigger without silently breaking Minecraft syntax

## Guidance

- bigger plans still need command validity
- prefer retries and repair loops over one-shot failure
- keep placement anchored near the player unless the user asked for another coordinate
- when a plan fails, explain whether it was size, syntax, unsupported entities, or placement
