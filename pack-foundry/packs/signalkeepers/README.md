# Signalkeepers · Java 1.21.1 alpha

A shared expedition: follow radio signals, restore three relays, manage scanner
battery and interference, and recover a forgotten town's memory. The optional
Field Instruments resource pack provides three original item models using
vanilla texture references. It contains no redistributed vanilla texture images.

Install the individual datapack ZIP into a closed test world's `datapacks` folder.
Open the world and enter `/trigger sk_start`, then `/trigger sk_help`.

- Hold the scanner and right-click to tune a relay or find its direction.
- Crouch-scanning is quiet. Standing scans charge faster but increase interference.
- Relay I favors quiet scans; relay II favors standing scans; relay III needs both
  previous relays and low interference. Return to camp to finish.
- Stand near camp to recharge. Excess interference creates temporary echo enemies.
- Aim the winch at a nearby tree with a clear route to pull toward it. This is a
  bounded pull, not physical swinging. Costs six battery per use.
- `/trigger sk_kit` recovers missing tools; `/trigger sk_leave` leaves the group;
  `/trigger sk_end` lets the expedition leader close the session.

Use open outdoor terrain in the Overworld. One expedition can run per world.
Tools may drop at your feet when inventory is full. Offline players at completion
do not receive the reward retroactively. Full loader/modpack compatibility,
visual quality, movement feel and native Mac frame time need human testing.

The model pack overrides carrot-on-a-stick, warped-fungus-on-a-stick and
amethyst-shard model definitions. Other model packs may conflict.

Before removal, an operator runs `/function signalkeepers:uninstall`, then saves,
quits and removes the ZIP. Check expedition chunks for leftover projections.
Normal terrain is not replaced. See the included historical `verification/`
reports for the original 33-check campaign evidence; those are not a new test run.

`tools/build.py` is the source generator. Use the collection-level
`../../tools/build.py` to produce releases with license and provenance metadata.
