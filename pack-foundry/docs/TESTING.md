# Validation · 0.1.0 alpha

## Current collection checks

- **26/26 real-server checks passed** on the official Java 1.21.1 dedicated
  server using Java 21 and two offline protocol clients, confined to localhost.
- All four datapacks loaded with no function, recipe or advancement parse errors.
- Trail Ledger recorded all seven actual biome changes, granted its completion
  advancement and one compass, avoided a repeated reward, and survived reload.
- All six Fieldcraft recipes unlocked in the test player's recipe book.
- Hearthside opt-in, crouching timer, standing reset, regeneration, per-player
  separation, opt-out and objective cleanup passed. The completion test advances
  the timer after observing real ticks; it is not a human ten-second playthrough.
- Six release test methods pass: ZIP/JSON/provenance validity, reproducibility,
  tamper detection, dependency/version handling, function references and bundle
  contents. These methods contain checks across all five archives.
- A real MCP client initialized the stdio server, discovered its four tools,
  searched the catalogue, checked a hash, resolved a dependency and rejected an
  invalid pack ID.
- Browser checks pass at desktop 1440px and mobile 390px: catalogue cards,
  filtering, empty-search state, details dialog/Escape, archive download,
  corruption rejection, no mobile horizontal overflow and no JavaScript errors.
  Catalogue screenshots are saved under `verification/`; they are website
  screenshots, not Minecraft gameplay images.

The regular Chromium launch could not create its profile socket in the execution
environment. The installed headless-shell engine successfully ran the browser
suite when the HTTP server ran inside the same test process environment.
Minecraft account-service DNS was unavailable; offline clients used only the
isolated localhost test server. No account credentials were used.

## Historical Signalkeepers evidence

`packs/signalkeepers/verification/` preserves the previous creator kit's reports.
That earlier run passed 33 campaign checks, including both endings. Those checks
were **not rerun** as part of the current collection test. The current server did
load the unchanged Signalkeepers gameplay source alongside the new packs.

## Reproduce

```sh
python3 pack-foundry/tools/build.py
python3 -m unittest discover -s pack-foundry/tests -p test_release.py -v
.venv/bin/python pack-foundry/tests/test_mcp.py
# Optional browser dependency and browser installation:
.venv/bin/pip install playwright==1.63.0
.venv/bin/python -m playwright install chromium
.venv/bin/python pack-foundry/tests/test_web.py
# Real server: obtain an official 1.21.1 server.jar and accept its EULA before use.
npm ci --prefix pack-foundry/tests
python3 pack-foundry/tests/server_smoke.py --server-jar /PATH/server.jar --java /PATH/java21/bin/java
```

The server harness creates a **new temporary world**, binds only to loopback,
uses a random local RCON password and stops its server and clients. It never
reuses or deletes an existing save. It writes a result report under verification.
The official server JAR, Java distribution, node_modules, temporary credentials
and disposable world are not part of this repository.

## Outstanding acceptance checks

Human graphical playthrough; actual crafting/smelting interactions and recipe
balance; inventory-full rewards; hunger depletion during campfire rest; Mac FPS;
shader and NeoForge compatibility; model appearance and resource-pack precedence;
real marketplace screenshots. These are reasons for the alpha label. No claim of
CurseForge approval, Modrinth eligibility, paid sales or public-site deployment
follows from passing automated tests.
