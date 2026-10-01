# Ashfall Bridge Lab

Research and executable planning prototype for running real Minecraft alongside
another game. **Not a playable crossover, game launcher, or universal converter.**
No commercial game binaries, saves, textures, fonts, or decompiled code included.

## What exists

- An evidence-labelled compatibility catalogue and CLI planner.
- GTA/Minecraft coordinate conversion and round-trip tests.
- A synthetic frame-policy model: reject reordered frames, hide stale frames,
  invalidate sessions on pause/disconnect, require a fresh session to resume.
- Three optional read-only stdio MCP tools: `list_bridges`, `plan_bridge`,
  `replay_demo`. These do not connect to or control games.
- Eight Python unit tests. They do not validate a real renderer or game.

```sh
python3 bridge-lab/bridge.py list
python3 bridge-lab/bridge.py plan assassins-creed --platform macos
python3 bridge-lab/bridge.py plan gta-v-legacy --platform windows --host-build 3889 --minecraft 26.3
python3 bridge-lab/bridge.py demo
python3 -m unittest discover -s bridge-lab -p 'test_bridge.py' -v
```

Optional MCP: install `bridge-lab/requirements.txt` into a virtual environment;
configure your MCP client to run that environment's Python with the absolute
path to `bridge-lab/mcp_server.py`. The CLI itself needs no third-party packages.

## Source review, 2026-10-01

Found [Universal Modder](https://github.com/rehan-remade/universal-modder), by
Rehan and contributors. Reviewed commit
`15d6f9d5fbd32de9b1884f29ddec3be9133bd912`, particularly:

- `examples/minecraft-gta5-passthrough/README.md`
- `host/mcframe.py` in that example
- `mc/src/client/java/dev/rehan/passthrough/client/HostLink.java`
- `knowledge/games/gta-v/minecraft-passthrough.md`
- `LICENSE`

The repository is public and MIT-licensed; studying it does not require binary
reverse engineering. This starter contains original implementation code, not a
vendored copy. Preserve upstream copyright and MIT notices if importing its code
later. Dependencies have their own terms. This project is not affiliated with
Universal Modder, Mojang, Microsoft, Ubisoft, Rockstar or Take-Two.

The concrete upstream example is **Minecraft 26.3 + GTA V Legacy build 3889 on
Windows**. Its authors report in-game verification. Ashfall has not reproduced
it. The example credits chasm's Skyrim work and TobynJacobs' Elden Ring work;
those are distinct projects, not proof that every target works in this toolkit.

The architecture has two running games and two adapters. Camera/input/ground and
gameplay events travel over a local WebSocket. Minecraft exports world colour,
depth and HUD frames through shared memory. A ReShade compositor tests depths
and compensates for camera delay. Minecraft blocks are represented by host-side
collision objects. Full interaction requires more than an overlay.

Two concrete findings:

1. `HostLink` binds to loopback but accepts command messages without a token.
   Before a public installer, add per-session authentication and a narrow message
   schema on **both** endpoints. No command channel is exposed by this starter.
2. The field note reports that pausing GTA leaves the last Minecraft frame on
   screen; the demo edit cut around it. Our `FrameGate` tests the desired policy,
   but is **not integrated into or a fix for the upstream compositor**.

Mac support is not established by this Windows example. The named shared memory,
Direct3D/ReShade and game-specific hooks need platform-specific implementations.
Our existing Java 1.21.1 packs have not been validated against upstream's 26.3.

## Product direction

A free catalogue + local desktop companion + game adapters. The browser lets
users choose a **supported exact game/version pair**, see a real preview, and
download verified packages. A local companion checks prerequisites, makes
isolated profiles, installs with a receipt, launches the two games, calibrates,
and provides rollback. A website alone cannot manipulate installed games.

The real-time bridge belongs in native/game code. MCP is the agent-facing layer
for compatibility, builds, diagnostics and controlled test runs; it should not
carry pixel buffers or frame-by-frame camera updates.

Acceptance before enabling an install button:

- Version/build and graphics-backend match; dependency provenance recorded.
- Authenticated loopback protocol, bounded payloads and frame buffers.
- Stable camera alignment and correct occlusion, including fast movement.
- Collision and one interaction verified in both directions, without duplicates.
- Pause, cutscenes, focus changes, resize and disconnect clear stale overlays.
- Measured frame rate/latency on named hardware and recorded real gameplay.
- Backup/rollback verified; installer preserves other mods and user settings.
- Signed release artefacts, hashes, licence notices and accurate compatibility.

## Assassin's Creed target

The user wants Minecraft inside Assassin's Creed. Exact title and platform are
still needed. A technical starting candidate is **Unity 1.5.0 on Windows**, an
engineering inference based on public runtime-mod tooling, not proven crossover
support:

- [ACUFixes](https://github.com/NameTaken3125/ACUFixes) documents its plugin loader,
  ReShade-compatible interface, reverse-engineered classes and exact 1.5.0 target.
- [AssetOverrides-ACUnity](https://github.com/antr1x/AssetOverrides-ACUnity) shows
  another plugin using that loader for runtime asset overrides.

No code from those projects is imported. Review their licences and applicable
dependency permissions before redistribution. A native Mac title, or Unity
through a compatibility layer, needs separate investigation; do not infer that
the Windows route will work.

First experiment, on a user-owned offline installation:

1. Record exact title, executable build/hash, OS and graphics backend. Work in a
   separate mod profile and back up saves.
2. Read the rendered camera pose, projection and viewport consistently per frame.
   Establish axis orientation and scale from measured landmarks; do not reuse
   GTA's coordinate mapping without calibration.
3. Identify the correct scene depth buffer. Composite one fixed Minecraft block
   into the scene: a wall must hide it from one view and reveal it from another.
4. Verify that it stays anchored while walking, turning, changing FOV and pausing.
5. Add placement/breaking, then host collision. Only then attempt parkour on
   placed blocks or cross-game combat.

If steps 2–3 fail, stop advertising full passthrough support. A cosmetic skin or
HUD experiment is a different feature and must be described separately.

## Agent handoff

Continue here without modifying the released pack collection. Do not mark
`playable` or `install_available` true based on matching version strings.
Next deliverable is a reviewed **single-title camera/depth adapter and real
occlusion recording**, not more catalogue entries. No local game installation
or graphical client was available in this session. The existing public pack
website has not been updated to advertise crossover downloads.

Original starter code: copyright 2026 Arnie016; MIT, see LICENSE. Built with AI
assistance. Upstream authorship is credited above.
