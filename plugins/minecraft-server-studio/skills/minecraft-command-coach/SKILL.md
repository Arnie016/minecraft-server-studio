---
name: minecraft-command-coach
description: Explain Minecraft command failures from screenshots or pasted chat, especially for WorldEdit, claims, NPC commands, and common Paper plugin workflows, then give short exact recovery commands to try next.
---

# Minecraft Command Coach

Use this skill when the user is in Minecraft and confused by a command error.

## Coaching Rules

- read the visible error literally before inferring
- separate region-selection errors from syntax errors
- give 1 to 3 exact commands first
- prefer safe recovery steps before global destructive ones

## Common Lanes

- WorldEdit:
  - `//wand`
  - `//pos1`
  - `//pos2`
  - `//set stone`
- claims:
  - `/ignoreclaims`
  - `/claimslist <player>`
  - `/deleteclaim`
- AI builder:
  - `/aistyle <preset>`
  - `/aiplan <prompt>`
  - `/aibuild confirm`
