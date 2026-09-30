#!/usr/bin/env python3
"""Reproducible, dependency-free Signalkeepers datapack and model compiler."""
from pathlib import Path
import json
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "datapack"
ART = ROOT / "resourcepack"
NS = "signalkeepers"


def write(root, path, value):
    p = root / path
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text((json.dumps(value, indent=2, ensure_ascii=False) if not isinstance(value, str) else value.strip()) + "\n")


def fn(name, content):
    write(DATA, f"data/{NS}/function/{name}.mcfunction", content)


def txt(s, color="aqua"):
    return json.dumps({"text": s, "color": color, "italic": False}, ensure_ascii=False)


def tell(s, who="@s", color="aqua"):
    return f"tellraw {who} {txt(s, color)}"


for d in (DATA, ART):
    if d.exists():
        shutil.rmtree(d)
    d.mkdir()

write(DATA, "pack.mcmeta", {"pack": {"pack_format": 48, "description": "Ashfall: Signalkeepers 0.1.0 | Java 1.21.1 | Original exploration technology"}})
write(ART, "pack.mcmeta", {"pack": {"pack_format": 34, "description": "Signalkeepers instruments | Optional 3D models | Java 1.21.1"}})
for tag in ("load", "tick"):
    write(DATA, f"data/minecraft/tags/function/{tag}.json", {"values": [f"{NS}:{tag}"]})
write(DATA, f"data/{NS}/predicate/sneaking.json", {"condition": "minecraft:entity_properties", "entity": "this", "predicate": {"flags": {"is_sneaking": True}}})

TRIGGERS = ["start", "help", "kit", "leave", "end"]
SCORES = ["sys", "cell", "cd", "session", "charge", "kind", "age", "tmp", "award", "pid", "line"]
fn("load", "\n".join(
    [f"scoreboard objectives add sk.{s} dummy" for s in SCORES]
    + [f"scoreboard objectives add sk_{s} trigger" for s in TRIGGERS]
    + ["scoreboard objectives add sk.use minecraft.used:minecraft.carrot_on_a_stick",
       "scoreboard objectives add sk.hook minecraft.used:minecraft.warped_fungus_on_a_stick",
       "execute unless score #init sk.sys matches 1 run function signalkeepers:init",
       "bossbar add signalkeepers:expedition {\"text\":\"Signalkeepers | Relays restored\",\"color\":\"aqua\"}",
       "bossbar set signalkeepers:expedition max 3", "bossbar set signalkeepers:expedition color blue",
       'tellraw @a [{"text":"[Signalkeepers] ","color":"aqua"},{"text":"Ready. /trigger sk_help for your field guide.","color":"gray","clickEvent":{"action":"run_command","value":"/trigger sk_help"}}]']))
fn("init", "\n".join(["scoreboard players set #init sk.sys 1"] + [f"scoreboard players set #{s} sk.sys 0" for s in ["state", "session", "tick", "heat", "relays", "surges", "upgrade", "idle", "pid"]]))

fn("tick", "\n".join([
    "execute if score #state sk.sys matches 0 run function signalkeepers:inactive",
    "execute if score #state sk.sys matches 3 run function signalkeepers:inactive",
    "execute in minecraft:overworld as @e[tag=sk.entity] unless score @s sk.session = #session sk.sys run kill @s",
    "execute as @a[tag=sk.member] unless score @s sk.session = #session sk.sys run tag @s remove sk.member",
    "execute as @a[tag=sk.owner] unless score @s sk.session = #session sk.sys run tag @s remove sk.owner",
    *[f"execute as @a[scores={{sk_{s}=1..}}] at @s run function signalkeepers:request/{s}" for s in TRIGGERS],
    "scoreboard players remove @a[scores={sk.cd=1..}] sk.cd 1",
    "execute if score #state sk.sys matches 1..2 as @a[tag=sk.member,scores={sk.hook=1..,sk.cd=0}] at @s if dimension minecraft:overworld if items entity @s weapon.mainhand minecraft:warped_fungus_on_a_stick[minecraft:custom_data~{signalkeepers:{winch:1b}}] run function signalkeepers:hook/try",
    "execute as @a[tag=sk.member,scores={sk.line=1..}] at @s if dimension minecraft:overworld run function signalkeepers:hook/step",
    "scoreboard players set @a[scores={sk.hook=1..}] sk.hook 0",
    "execute if score #state sk.sys matches 1..2 as @a[tag=sk.member,scores={sk.use=1..,sk.cd=0}] at @s if dimension minecraft:overworld if items entity @s weapon.mainhand minecraft:carrot_on_a_stick[minecraft:custom_data~{signalkeepers:{scanner:1b}}] run function signalkeepers:scan/try",
    "scoreboard players set @a[scores={sk.use=1..}] sk.use 0",
    "scoreboard players add #tick sk.sys 1",
    "execute if score #tick sk.sys matches 20.. run function signalkeepers:second",
]))
fn("inactive", "tag @a remove sk.member\ntag @a remove sk.owner\nscoreboard players set @a sk.line 0\nexecute in minecraft:overworld run kill @e[tag=sk.entity]")
fn("world/stamp", "scoreboard players operation @e[tag=sk.unstamped] sk.session = #session sk.sys\ntag @e[tag=sk.unstamped] remove sk.unstamped")
fn("second", "\n".join([
    "scoreboard players set #tick sk.sys 0",
    *[f"scoreboard players enable @a sk_{s}" for s in TRIGGERS],
    "execute if score #state sk.sys matches 1..2 run function signalkeepers:active",
]))
fn("request/help", "scoreboard players set @s sk_help 0\n" + tell("SIGNALKEEPERS — FIELD GUIDE", color="gold") + "\n" + "\n".join([
    tell("/trigger sk_start — begin here, or join the active expedition.", color="white"),
    tell("Track three relays. Hold your scanner and right-click. Follow its beam and coordinates.", color="gray"),
    tell("Relay I: crouch and scan to listen. Relay II: stand and scan to charge quickly.", color="gray"),
    tell("Relay III: restore the first two, let interference fall below 30, then crouch-scan.", color="gray"),
    tell("Scanning spends battery. Return within 6 blocks of camp to recharge. At 100 interference, echoes appear.", color="gray"),
    tell("Canopy Winch: aim at a tree within 24 blocks and right-click to pull toward it. Costs 6 battery; open paths only.", color="gray"),
    tell("Restore all three, return to camp, then scan to hear the ending and claim a relic.", color="gray"),
    tell("/trigger sk_kit restores a lost scanner. /trigger sk_leave leaves. The expedition leader can /trigger sk_end.", color="gray"),
    tell("Use an open outdoor site in a fresh test world. Normal difficulty recommended. One shared expedition per world.", color="yellow"),
]))
fn("request/start", "\n".join([
    "scoreboard players set @s sk_start 0",
    "execute unless dimension minecraft:overworld run return run function signalkeepers:message/overworld",
    "execute if entity @s[gamemode=spectator] run return run function signalkeepers:message/spectator",
    "execute if score #state sk.sys matches -1 run return run function signalkeepers:message/building",
    "execute if score #state sk.sys matches 1..2 run return run function signalkeepers:join",
    "function signalkeepers:start",
]))
fn("message/overworld", tell("Start or join from the Overworld.", color="yellow"))
fn("message/spectator", tell("Switch out of spectator mode to join.", color="yellow"))
fn("message/building", tell("The instruments are finding safe survey positions. Try again in a moment.", color="yellow"))
fn("join", "\n".join([
    "execute if entity @s[tag=sk.member] if score @s sk.session = #session sk.sys run return run function signalkeepers:request/help",
    "tag @s add sk.member", "scoreboard players operation @s sk.session = #session sk.sys",
    "scoreboard players set @s sk.cell 100", "scoreboard players set @s sk.cd 0",
    "execute unless score @s sk.pid matches 1.. run function signalkeepers:hook/assign",
    "scoreboard players set @s sk.line 0", "scoreboard players set @s sk.hook 0",
    "scoreboard players set @s sk.use 0", "function signalkeepers:request/kit",
    tell("You are a Signalkeeper. Three abandoned relays are still broadcasting. Find out who they are calling.", color="gold"),
    tell("The scanner beam points to the next relay. Crouch for quiet scans; stand for stronger pulses. Camp recharges it.", color="gray"),
    "function signalkeepers:world/announce with storage signalkeepers:run hub",
]))
scanner = 'minecraft:carrot_on_a_stick[minecraft:custom_data={signalkeepers:{scanner:1b}},minecraft:custom_model_data=731201,minecraft:custom_name=\'' + txt("Resonance Scanner") + "',minecraft:lore=['" + txt("Right-click: pulse | Crouch: listen", "gray") + "','" + txt("Recharge near the expedition camp", "dark_aqua") + "'],minecraft:unbreakable={}]"
winch = 'minecraft:warped_fungus_on_a_stick[minecraft:custom_data={signalkeepers:{winch:1b}},minecraft:custom_model_data=731221,minecraft:custom_name=\'' + txt("Canopy Winch", "green") + "',minecraft:lore=['" + txt("Aim at a tree within 24 blocks. Right-click to pull.", "gray") + "','" + txt("6 battery per latch. Clear paths only.", "dark_aqua") + "'],minecraft:unbreakable={}]"
fn("request/kit", "\n".join([
    "scoreboard players set @s sk_kit 0",
    "execute unless entity @s[tag=sk.member] run return run function signalkeepers:message/not_joined",
    f"execute unless items entity @s inventory.* minecraft:carrot_on_a_stick[minecraft:custom_data~{{signalkeepers:{{scanner:1b}}}}] unless items entity @s hotbar.* minecraft:carrot_on_a_stick[minecraft:custom_data~{{signalkeepers:{{scanner:1b}}}}] unless items entity @s weapon.offhand minecraft:carrot_on_a_stick[minecraft:custom_data~{{signalkeepers:{{scanner:1b}}}}] run give @s {scanner} 1",
    f"execute unless items entity @s inventory.* minecraft:warped_fungus_on_a_stick[minecraft:custom_data~{{signalkeepers:{{winch:1b}}}}] unless items entity @s hotbar.* minecraft:warped_fungus_on_a_stick[minecraft:custom_data~{{signalkeepers:{{winch:1b}}}}] unless items entity @s weapon.offhand minecraft:warped_fungus_on_a_stick[minecraft:custom_data~{{signalkeepers:{{winch:1b}}}}] run give @s {winch} 1",
]))
fn("message/not_joined", tell("Join an expedition with /trigger sk_start first.", color="yellow"))
fn("request/leave", "\n".join([
    "scoreboard players set @s sk_leave 0", "tag @s remove sk.member",
    "clear @s minecraft:carrot_on_a_stick[minecraft:custom_data~{signalkeepers:{scanner:1b}}]",
    "clear @s minecraft:warped_fungus_on_a_stick[minecraft:custom_data~{signalkeepers:{winch:1b}}]",
    "scoreboard players set @s sk.line 0",
    tell("You left the expedition. Your progress remains shared; /trigger sk_start rejoins it.", color="gray"),
]))
fn("request/end", "\n".join([
    "scoreboard players set @s sk_end 0",
    'execute unless entity @s[tag=sk.owner] run return run tellraw @s {"text":"Only the expedition leader can end it. Use /trigger sk_leave to leave.","color":"yellow"}',
    "function signalkeepers:stop",
]))

# Record positions as scores and copy into macro storage. Each footprint owns
# at most one forced chunk, preserving any chunk already forced by other packs.
offsets = {"hub": (0, 0), "one": (80, 16), "two": (-48, 80), "three": (-64, -64)}
start = ["function signalkeepers:world/cleanup", "scoreboard players add #session sk.sys 1", "tag @a remove sk.owner", "tag @a remove sk.member", "tag @s add sk.owner", "scoreboard players set #state sk.sys -1"]
start += [f"scoreboard players set #{s} sk.sys 0" for s in ["heat", "relays", "surges", "upgrade", "idle", "buildwait"]]
start += ["execute store result score #x sk.tmp run data get entity @s Pos[0] 1", "execute store result score #z sk.tmp run data get entity @s Pos[2] 1"]
for name, (x, z) in offsets.items():
    start += [f"data modify storage signalkeepers:run {name} set value {{x:0,z:0}}",
              f"scoreboard players operation #posx sk.tmp = #x sk.tmp", f"scoreboard players {'add' if x >= 0 else 'remove'} #posx sk.tmp {abs(x)}",
              f"scoreboard players operation #posz sk.tmp = #z sk.tmp", f"scoreboard players {'add' if z >= 0 else 'remove'} #posz sk.tmp {abs(z)}",
              f"execute store result storage signalkeepers:run {name}.x int 1 run scoreboard players get #posx sk.tmp",
              f"execute store result storage signalkeepers:run {name}.z int 1 run scoreboard players get #posz sk.tmp",
              f"function signalkeepers:world/acquire_{name} with storage signalkeepers:run {name}"]
    fn(f"world/acquire_{name}", f"""
$execute in minecraft:overworld store success score #{name}_prior sk.tmp run forceload query $(x) $(z)
scoreboard players set #{name}_owned sk.tmp 0
$execute in minecraft:overworld unless score #{name}_prior sk.tmp matches 1 store success score #{name}_owned sk.tmp run forceload add $(x) $(z)
""")
    fn(f"world/release_{name}", f"$execute in minecraft:overworld if score #{name}_owned sk.tmp matches 1 run forceload remove $(x) $(z)\nscoreboard players set #{name}_owned sk.tmp 0")
    fn(f"world/check_{name}", f"$execute in minecraft:overworld if loaded $(x) 0 $(z) run scoreboard players add #loaded sk.tmp 1")
    fn(f"world/build_{name}", f"$execute in minecraft:overworld positioned $(x) 0 $(z) positioned over motion_blocking_no_leaves positioned ~0.5 ~0.2 ~0.5 run function signalkeepers:world/site_{name}")
start += ["function signalkeepers:join", tell("Survey instruments deploying. No terrain will be replaced.", color="gray"), "schedule function signalkeepers:world/build 10t replace"]
fn("start", "\n".join(start))
fn("world/announce", '$tellraw @s {"text":"Camp coordinates: X $(x), Z $(z). Return here for battery power and extraction.","color":"aqua"}')
fn("world/build", "\n".join([
    "execute unless score #state sk.sys matches -1 run return 0",
    "scoreboard players set #loaded sk.tmp 0",
    *[f"function signalkeepers:world/check_{n} with storage signalkeepers:run {n}" for n in offsets],
    "execute if score #loaded sk.tmp matches 4 run return run function signalkeepers:world/build_ready",
    "scoreboard players add #buildwait sk.sys 1",
    "execute if score #buildwait sk.sys matches 40.. run return run function signalkeepers:world/build_failed",
    "schedule function signalkeepers:world/build 10t replace",
]))
fn("world/build_ready", "\n".join([
    *[f"function signalkeepers:world/build_{n} with storage signalkeepers:run {n}" for n in offsets],
    "scoreboard players set #state sk.sys 1",
    tell("The receivers are online. Restore the Listening Post and the Capacitor, then wake the Last Lantern.", who="@a[tag=sk.member]", color="gold"),
]))
fn("world/build_failed", tell("Survey placement timed out. Choose an open site inside the world border and try again.", who="@a[tag=sk.member]", color="yellow") + "\nfunction signalkeepers:stop")


def block_display(block, x, y, z, sx, sy, sz, tags):
    tag = ",".join(json.dumps(t) for t in ["sk.entity", "sk.unstamped", *tags])
    return f'summon minecraft:block_display ~{x} ~{y} ~{z} {{Tags:[{tag}],block_state:{{Name:"minecraft:{block}"}},transformation:{{translation:[0f,0f,0f],scale:[{sx}f,{sy}f,{sz}f],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}},brightness:{{block:12,sky:15}},view_range:1.5f}}'


site_names = {"hub": "FIELD CAMP • RECHARGE", "one": "I • LISTENING POST", "two": "II • CAPACITOR", "three": "III • LAST LANTERN"}
for i, name in enumerate(offsets):
    tag = f"sk.{name}"
    site = [f'summon minecraft:marker ~ ~ ~ {{Tags:["sk.entity","sk.unstamped","sk.anchor","{tag}"' + (',"sk.relay"' if i else '') + ']}']
    site += [f"scoreboard players set @e[type=minecraft:marker,tag={tag},sort=nearest,limit=1,distance=..1] sk.kind {i}", f"scoreboard players set @e[type=minecraft:marker,tag={tag},sort=nearest,limit=1,distance=..1] sk.charge 0"]
    site += [block_display("polished_deepslate", -0.7, 0, -0.7, 1.4, 0.15, 1.4, [tag]),
             block_display("cut_copper", -0.22, 0.15, -0.22, 0.44, 1.6, 0.44, [tag]),
             block_display("amethyst_block" if i else "sea_lantern", -0.35, 1.4, -0.35, 0.7, 0.7, 0.7, [tag, "sk.core"])]
    for x, z in [(-0.8, -0.8), (-0.8, 0.6), (0.6, -0.8), (0.6, 0.6)]:
        site.append(block_display("oxidized_copper", x, 0.1, z, 0.2, 2.3 if i else 0.9, 0.2, [tag]))
    label = txt(site_names[name], "aqua" if not i else "gold")
    site.append(f"summon minecraft:text_display ~ ~2.9 ~ {{Tags:[\"sk.entity\",\"sk.unstamped\",\"{tag}\"],text:'{label}',billboard:\"center\",alignment:\"center\",background:1073741824,text_opacity:-1b,shadow:1b,line_width:240,view_range:1f}}")
    site.append("function signalkeepers:world/stamp")
    fn(f"world/site_{name}", "\n".join(site))

fn("active", "\n".join([
    "execute if entity @a[tag=sk.member] run scoreboard players set #idle sk.sys 0",
    "execute unless entity @a[tag=sk.member] run scoreboard players add #idle sk.sys 1",
    "execute if score #idle sk.sys matches 300.. run return run function signalkeepers:stop",
    "execute if score #heat sk.sys matches 1.. run scoreboard players remove #heat sk.sys 2",
    "execute if score #heat sk.sys matches 1.. if score #upgrade sk.sys matches 1 run scoreboard players remove #heat sk.sys 2",
    "execute if score #heat sk.sys matches ..-1 run scoreboard players set #heat sk.sys 0",
    "execute in minecraft:overworld at @e[type=minecraft:marker,tag=sk.hub,limit=1] as @a[tag=sk.member,distance=..6,scores={sk.cell=..99}] run scoreboard players add @s sk.cell 8",
    "scoreboard players set @a[scores={sk.cell=101..}] sk.cell 100",
    "execute in minecraft:overworld as @e[type=minecraft:husk,tag=sk.echo] run scoreboard players add @s sk.age 1",
    "execute in minecraft:overworld as @e[type=minecraft:husk,tag=sk.echo,scores={sk.age=60..}] run kill @s",
    "execute in minecraft:overworld as @e[type=minecraft:marker,tag=sk.hook_anchor] run scoreboard players add @s sk.age 1",
    "execute in minecraft:overworld run kill @e[type=minecraft:marker,tag=sk.hook_anchor,scores={sk.age=3..}]",
    "execute in minecraft:overworld as @e[type=minecraft:marker,tag=sk.anchor] at @s if entity @a[tag=sk.member,distance=..40] run particle minecraft:reverse_portal ~ ~1.8 ~ 0.25 0.35 0.25 0.015 3 normal @a[tag=sk.member,distance=..40]",
    "bossbar set signalkeepers:expedition players @a[tag=sk.member]",
    "bossbar set signalkeepers:expedition visible true",
    "execute store result bossbar signalkeepers:expedition value run scoreboard players get #relays sk.sys",
    "execute as @a[tag=sk.member] at @s if items entity @s weapon.mainhand minecraft:carrot_on_a_stick[minecraft:custom_data~{signalkeepers:{scanner:1b}}] run function signalkeepers:hud",
]))
fn("hud", 'title @s actionbar [{"text":"RELAYS ","color":"aqua"},{"score":{"name":"#relays","objective":"sk.sys"}},{"text":"/3  •  CELL ","color":"gray"},{"score":{"name":"@s","objective":"sk.cell"}},{"text":"%  •  INTERFERENCE ","color":"gold"},{"score":{"name":"#heat","objective":"sk.sys"}},{"text":"/100","color":"gray"}]')

fn("scan/try", "\n".join([
    "scoreboard players set #quiet sk.tmp 0",
    "execute if predicate signalkeepers:sneaking run scoreboard players set #quiet sk.tmp 1",
    "execute if score #quiet sk.tmp matches 1 if score @s sk.cell matches ..3 run return run function signalkeepers:scan/empty",
    "execute if score #quiet sk.tmp matches 0 if score @s sk.cell matches ..7 run return run function signalkeepers:scan/empty",
    "function signalkeepers:scan/pulse",
]))
fn("scan/empty", "scoreboard players set @s sk.cd 20\n" + tell("Battery low. Return to camp; it recharges within 6 blocks. /trigger sk_help for the guide.", color="yellow") + "\nfunction signalkeepers:world/announce with storage signalkeepers:run hub")
fn("scan/pulse", "\n".join([
    "scoreboard players set @s sk.cd 40",
    "execute if score #quiet sk.tmp matches 1 run scoreboard players remove @s sk.cell 4",
    "execute if score #quiet sk.tmp matches 1 run scoreboard players add #heat sk.sys 2",
    "execute if score #quiet sk.tmp matches 0 run scoreboard players remove @s sk.cell 8",
    "execute if score #quiet sk.tmp matches 0 run scoreboard players add #heat sk.sys 18",
    "playsound minecraft:block.amethyst_block.chime player @s ~ ~ ~ 0.7 1.2",
    "tag @e[tag=sk.target] remove sk.target",
    "execute if score #relays sk.sys matches ..1 run tag @e[type=minecraft:marker,tag=sk.relay,tag=!sk.done,scores={sk.kind=1..2},sort=nearest,limit=1] add sk.target",
    "execute if score #relays sk.sys matches 2 run tag @e[type=minecraft:marker,tag=sk.three,limit=1] add sk.target",
    "execute if score #relays sk.sys matches 3 run tag @e[type=minecraft:marker,tag=sk.hub,limit=1] add sk.target",
    "execute if entity @e[type=minecraft:marker,tag=sk.target,distance=..4,limit=1] run function signalkeepers:scan/near",
    "execute unless entity @e[type=minecraft:marker,tag=sk.target,distance=..4,limit=1] run function signalkeepers:scan/guide",
    "execute if score #state sk.sys matches 1..2 if score #heat sk.sys matches 100.. run function signalkeepers:surge",
    "tag @e[tag=sk.target] remove sk.target",
]))
fn("scan/near", "\n".join([
    "execute if entity @e[type=minecraft:marker,tag=sk.target,tag=sk.hub,distance=..4] run return run function signalkeepers:finish",
    "execute if entity @e[type=minecraft:marker,tag=sk.target,tag=sk.one,distance=..4] run function signalkeepers:tune/one",
    "execute if entity @e[type=minecraft:marker,tag=sk.target,tag=sk.two,distance=..4] run function signalkeepers:tune/two",
    "execute if entity @e[type=minecraft:marker,tag=sk.target,tag=sk.three,distance=..4] run function signalkeepers:tune/three",
]))
fn("scan/guide", "\n".join([
    "scoreboard players set #ray sk.tmp 0",
    "execute anchored eyes facing entity @e[type=minecraft:marker,tag=sk.target,limit=1] feet positioned ^ ^ ^1 run function signalkeepers:scan/ray",
    "execute store result score #targetx sk.tmp run data get entity @e[type=minecraft:marker,tag=sk.target,limit=1] Pos[0] 1",
    "execute store result score #targetz sk.tmp run data get entity @e[type=minecraft:marker,tag=sk.target,limit=1] Pos[2] 1",
    'tellraw @s [{"text":"Signal bearing • X ","color":"aqua"},{"score":{"name":"#targetx","objective":"sk.tmp"}},{"text":"  Z "},{"score":{"name":"#targetz","objective":"sk.tmp"}},{"text":". Tune within 4 blocks.","color":"gray"}]',
]))
fn("scan/ray", "\n".join([
    'particle minecraft:dust{color:[0.15,0.85,0.8],scale:0.7} ~ ~ ~ 0 0 0 0 1 normal @s',
    "scoreboard players add #ray sk.tmp 1",
    "execute if score #ray sk.tmp matches ..23 positioned ^ ^ ^1 run function signalkeepers:scan/ray",
]))
target = "@e[type=minecraft:marker,tag=sk.target,limit=1]"
fn("tune/one", "\n".join([
    f"execute if score #quiet sk.tmp matches 1 run scoreboard players add {target} sk.charge 2",
    f"execute if score #quiet sk.tmp matches 0 run scoreboard players add {target} sk.charge 1",
    "function signalkeepers:tune/feedback",
    f"execute if score {target} sk.charge matches 8.. run function signalkeepers:complete/one",
]))
fn("tune/two", "\n".join([
    f"execute if score #quiet sk.tmp matches 1 run scoreboard players add {target} sk.charge 1",
    f"execute if score #quiet sk.tmp matches 0 run scoreboard players add {target} sk.charge 3",
    "function signalkeepers:tune/feedback",
    f"execute if score {target} sk.charge matches 8.. run function signalkeepers:complete/two",
]))
fn("tune/three", "\n".join([
    'execute unless score #quiet sk.tmp matches 1 run return run tellraw @s {"text":"The Last Lantern only answers a quiet signal. Crouch, then scan.","color":"yellow"}',
    'execute if score #heat sk.sys matches 30.. run return run tellraw @s {"text":"Too much interference. Wait for it to fall below 30, then listen again.","color":"yellow"}',
    f"scoreboard players add {target} sk.charge 2",
    "function signalkeepers:tune/feedback",
    f"execute if score {target} sk.charge matches 8.. run function signalkeepers:complete/three",
]))
fn("tune/feedback", f"execute store result score #charge sk.tmp run scoreboard players get {target} sk.charge\n" + 'tellraw @s [{"text":"Relay coherence ","color":"aqua"},{"score":{"name":"#charge","objective":"sk.tmp"}},{"text":"/8. I prefers listening; II prefers power; III requires silence.","color":"gray"}]')
stories = {
    "one": "RECORDING 01 — We left before the ash. Mara hid the town archive in the relays. If anyone hears this: keep the lamps lit.",
    "two": "RECORDING 02 — The power is not a weapon. It is a way home. Stabilizer restored: interference now fades twice as quickly.",
    "three": "RECORDING 03 — No one was trapped below. We chose to leave a seed, not a grave. Bring the signal back to camp.",
}
for n in ("one", "two", "three"):
    complete = [f"execute if entity {target[:-1]},tag=sk.done] run return 0", f"tag {target} add sk.done", "scoreboard players add #relays sk.sys 1",
                f'execute as @e[type=minecraft:block_display,tag=sk.{n},tag=sk.core] run data merge entity @s {{block_state:{{Name:"minecraft:emerald_block"}}}}',
                "playsound minecraft:block.beacon.activate player @a[tag=sk.member] ~ ~ ~ 0.6 1.2",
                tell(stories[n], who="@a[tag=sk.member]", color="gold")]
    if n == "two":
        complete.append("scoreboard players set #upgrade sk.sys 1")
    complete += ["execute if score #relays sk.sys matches 2 run " + tell("The Last Lantern is unlocked. Let interference fall below 30 before quiet tuning.", who="@a[tag=sk.member]", color="aqua"),
                 "execute if score #relays sk.sys matches 3 run scoreboard players set #state sk.sys 2"]
    fn(f"complete/{n}", "\n".join(complete))

fn("surge", "\n".join([
    "scoreboard players set #heat sk.sys 55", "scoreboard players add #surges sk.sys 1",
    tell("SIGNAL SURGE — Something heard you. Quiet scans keep interference down.", who="@a[tag=sk.member]", color="red"),
    "playsound minecraft:entity.warden.heartbeat player @s ~ ~ ~ 0.6 1.4",
    "scoreboard players set #echoes sk.tmp 0",
    "execute as @e[type=minecraft:husk,tag=sk.echo] run scoreboard players add #echoes sk.tmp 1",
    "execute if score #echoes sk.tmp matches ..2 positioned ~4 ~ ~4 positioned over motion_blocking_no_leaves run function signalkeepers:echo/spawn",
    "execute if score #echoes sk.tmp matches ..2 positioned ~-4 ~ ~-4 positioned over motion_blocking_no_leaves run function signalkeepers:echo/spawn",
]))
fn("echo/spawn", '''
execute unless block ~ ~ ~ minecraft:air run return 0
summon minecraft:husk ~ ~ ~ {Tags:["sk.entity","sk.unstamped","sk.echo"],CustomName:'{"text":"Signal Echo","color":"dark_aqua"}',CustomNameVisible:1b,PersistenceRequired:0b,CanPickUpLoot:0b,DeathLootTable:"minecraft:empty",Health:16f,Attributes:[{Name:"minecraft:generic.max_health",Base:16.0d},{Name:"minecraft:generic.movement_speed",Base:0.25d}],Silent:1b}
function signalkeepers:world/stamp
''')

# Bounded traversal prototype. This is a collision-aware winch, not a native
# pendulum/rope simulation. Anchors have explicit owners for multiplayer use.
write(DATA, f"data/{NS}/tags/block/grapple_targets.json", {"values": ["#minecraft:logs", "#minecraft:leaves"]})
write(DATA, f"data/{NS}/tags/block/passable.json", {"values": ["minecraft:air", "minecraft:cave_air", "minecraft:void_air", "minecraft:short_grass", "minecraft:tall_grass", "minecraft:fern", "minecraft:large_fern", "minecraft:vine", "minecraft:snow"]})
fn("hook/assign", "scoreboard players add #pid sk.sys 1\nscoreboard players operation @s sk.pid = #pid sk.sys")
fn("hook/try", "\n".join([
    "execute if score @s sk.line matches 1.. run return 0",
    "execute if score @s sk.cell matches ..5 run return run function signalkeepers:scan/empty",
    "scoreboard players set @s sk.cd 15",
    "scoreboard players operation #pid sk.tmp = @s sk.pid",
    "execute as @e[type=minecraft:marker,tag=sk.hook_anchor] if score @s sk.pid = #pid sk.tmp run kill @s",
    "scoreboard players set #ray sk.tmp 0",
    "execute anchored eyes positioned ^ ^ ^0.5 run function signalkeepers:hook/ray",
    'execute unless score @s sk.line matches 1.. run tellraw @s {"text":"No clear tree anchor within 24 blocks.","color":"gray"}',
]))
fn("hook/ray", "\n".join([
    "execute if block ~ ~ ~ #signalkeepers:grapple_targets run return run function signalkeepers:hook/hit",
    "execute unless block ~ ~ ~ #signalkeepers:passable run return 0",
    "scoreboard players add #ray sk.tmp 1",
    "execute if score #ray sk.tmp matches ..47 positioned ^ ^ ^0.5 run function signalkeepers:hook/ray",
]))
fn("hook/hit", "\n".join([
    "execute if score #ray sk.tmp matches ..3 run return 0",
    'execute positioned ^ ^ ^-1 run summon minecraft:marker ~ ~ ~ {Tags:["sk.entity","sk.unstamped","sk.hook_anchor","sk.new_hook"]}',
    "function signalkeepers:world/stamp",
    "scoreboard players operation @e[type=minecraft:marker,tag=sk.new_hook,limit=1] sk.pid = @s sk.pid",
    "scoreboard players set @e[type=minecraft:marker,tag=sk.new_hook,limit=1] sk.age 0",
    "tag @e[tag=sk.new_hook] remove sk.new_hook",
    "scoreboard players set @s sk.line 35",
    "scoreboard players remove @s sk.cell 6",
    "playsound minecraft:item.crossbow.shoot player @s ~ ~ ~ 0.6 1.6",
]))
fn("hook/step", "\n".join([
    "tag @e[tag=sk.hook_target] remove sk.hook_target",
    "scoreboard players operation #pid sk.tmp = @s sk.pid",
    "execute as @e[type=minecraft:marker,tag=sk.hook_anchor] if score @s sk.pid = #pid sk.tmp run tag @s add sk.hook_target",
    "execute unless entity @e[tag=sk.hook_target] run scoreboard players set @s sk.line 0",
    "execute if entity @e[tag=sk.hook_target,distance=..2] run scoreboard players set @s sk.line 0",
    "execute unless score @s sk.line matches 1.. run return run function signalkeepers:hook/release",
    "scoreboard players set #moved sk.tmp 0",
    "function signalkeepers:hook/move",
    "execute if score #moved sk.tmp matches 1 at @s run function signalkeepers:hook/move",
    "effect give @s minecraft:slow_falling 2 0 true",
    "scoreboard players remove @s sk.line 1",
    "execute unless score #moved sk.tmp matches 1 run scoreboard players set @s sk.line 0",
    "execute unless score @s sk.line matches 1.. run function signalkeepers:hook/release",
]))
fn("hook/release", "kill @e[type=minecraft:marker,tag=sk.hook_target]\ntag @e[tag=sk.hook_target] remove sk.hook_target")
corners = " ".join(f"if block ~{x} ~{y} ~{z} #signalkeepers:passable" for x in [-0.31, 0.31] for y in [0, 1.79] for z in [-0.31, 0.31])
fn("hook/move", f"scoreboard players set #moved sk.tmp 0\nexecute facing entity @e[tag=sk.hook_target,limit=1] feet positioned ^ ^ ^0.325 {corners} store success score #moved sk.tmp run tp @s ~ ~ ~")
relic = 'minecraft:amethyst_shard[minecraft:custom_data={signalkeepers:{relic:1b}},minecraft:custom_model_data=731211,minecraft:custom_name=\'' + txt("Seed of the Signal", "light_purple") + "',minecraft:lore=['" + txt("Three relays. One town remembered.", "gray") + "'],minecraft:max_stack_size=1]"
fn("finish", "\n".join([
    "execute unless score #state sk.sys matches 2 run return 0",
    "execute unless score #relays sk.sys matches 3 run return 0",
    "scoreboard players set #state sk.sys 3",
    'title @a[tag=sk.member] title {"text":"THE LAMPS ARE LIT","color":"gold"}',
    "execute if score #surges sk.sys matches 0 run " + tell("QUIET ENDING — You heard the town without waking its echoes. The archive returns intact.", who="@a[tag=sk.member]", color="aqua"),
    "execute if score #surges sk.sys matches 1.. run " + tell("STORM ENDING — The archive survived, but your signal woke its guardians. The town is remembered all the same.", who="@a[tag=sk.member]", color="gold"),
    "execute as @a[tag=sk.member] unless score @s sk.award = #session sk.sys run function signalkeepers:reward",
    "function signalkeepers:world/cleanup", "bossbar set signalkeepers:expedition visible false",
    "tag @a remove sk.member", "tag @a remove sk.owner",
]))
fn("reward", f"give @s {relic} 1\nscoreboard players operation @s sk.award = #session sk.sys\nexperience add @s 5 levels\n" + tell("Relic recovered. A new expedition can be started anywhere outdoors with /trigger sk_start.", color="gray"))
fn("world/cleanup", "\n".join([
    "schedule clear signalkeepers:world/build",
    "execute in minecraft:overworld run kill @e[tag=sk.entity]",
    *[f"execute if data storage signalkeepers:run {n} run function signalkeepers:world/release_{n} with storage signalkeepers:run {n}" for n in offsets],
]))
fn("stop", "\n".join([
    "function signalkeepers:world/cleanup", "scoreboard players set #state sk.sys 0",
    "bossbar set signalkeepers:expedition visible false",
    "clear @a[tag=sk.member] minecraft:carrot_on_a_stick[minecraft:custom_data~{signalkeepers:{scanner:1b}}]",
    "clear @a[tag=sk.member] minecraft:warped_fungus_on_a_stick[minecraft:custom_data~{signalkeepers:{winch:1b}}]",
    "scoreboard players set @a sk.line 0",
    tell("Expedition closed. Survey projections and owned chunk tickets have been removed.", who="@a[tag=sk.member]", color="gray"),
    "tag @a remove sk.member", "tag @a remove sk.owner",
]))
fn("uninstall", "\n".join([
    "function signalkeepers:stop", "bossbar remove signalkeepers:expedition", "data remove storage signalkeepers:run hub",
    *[f"data remove storage signalkeepers:run {n}" for n in ["one", "two", "three"]],
    *[f"scoreboard objectives remove sk.{s}" for s in SCORES], "scoreboard objectives remove sk.use", "scoreboard objectives remove sk.hook",
    *[f"scoreboard objectives remove sk_{s}" for s in TRIGGERS],
    tell("Signalkeepers uninstalled. Now remove its datapack ZIP and reload.", who="@a", color="gray"),
]))

# The optional models use vanilla texture references only. No raster generation,
# texture replacement, shader, sound download, client mod, or asset API is needed.
def cuboid(a, b, texture):
    return {"from": a, "to": b, "faces": {side: {"texture": texture} for side in ["north", "south", "east", "west", "up", "down"]}}

model = {
    "credit": "Original Signalkeepers geometry; textures referenced from Minecraft",
    "textures": {"copper": "minecraft:block/cut_copper", "dark": "minecraft:block/polished_deepslate", "glass": "minecraft:block/amethyst_block", "wire": "minecraft:block/oxidized_copper", "particle": "minecraft:block/cut_copper"},
    "elements": [cuboid([4, 3, 5], [12, 11, 10], "#copper"), cuboid([5, 4, 4.6], [11, 10, 5], "#dark"), cuboid([6, 6, 4.3], [10, 9, 4.6], "#glass"), cuboid([7, 0, 6], [9, 3, 9], "#dark"), cuboid([5, 11, 7], [6, 15, 8], "#wire"), cuboid([10, 11, 7], [11, 14, 8], "#wire"), cuboid([5.5, 4.5, 4.2], [6.5, 5.5, 4.6], "#wire"), cuboid([9.5, 4.5, 4.2], [10.5, 5.5, 4.6], "#wire")],
    "display": {
        "gui": {"rotation": [15, -30, 0], "translation": [0, 0, 0], "scale": [0.9, 0.9, 0.9]},
        "firstperson_righthand": {"rotation": [0, -15, 0], "translation": [0, 1, 0], "scale": [0.75, 0.75, 0.75]},
        "firstperson_lefthand": {"rotation": [0, 15, 0], "translation": [0, 1, 0], "scale": [0.75, 0.75, 0.75]},
        "thirdperson_righthand": {"rotation": [0, 0, 0], "translation": [0, 2, 0], "scale": [0.65, 0.65, 0.65]},
        "ground": {"translation": [0, 3, 0], "scale": [0.55, 0.55, 0.55]},
        "fixed": {"rotation": [0, 180, 0], "scale": [0.8, 0.8, 0.8]},
    },
}
write(ART, f"assets/{NS}/models/item/scanner.json", model)
write(ART, f"assets/{NS}/models/item/relic.json", {"textures": model["textures"], "elements": [cuboid([5, 2, 5], [11, 4, 11], "#copper"), cuboid([6, 4, 6], [10, 11, 10], "#glass"), cuboid([7, 11, 7], [9, 14, 9], "#wire")], "display": model["display"]})
write(ART, f"assets/{NS}/models/item/winch.json", {"textures": model["textures"], "elements": [cuboid([5, 2, 6], [8, 8, 9], "#dark"), cuboid([3, 7, 5], [12, 11, 10], "#copper"), cuboid([6, 8, 1], [9, 10, 5], "#wire"), cuboid([4, 8, 0], [11, 10, 1], "#dark")], "display": model["display"]})
for vanilla, cmd, custom, parent in [("carrot_on_a_stick", 731201, "scanner", "handheld_rod"), ("amethyst_shard", 731211, "relic", "generated"), ("warped_fungus_on_a_stick", 731221, "winch", "handheld_rod")]:
    fallback = {"parent": f"minecraft:item/{parent}", "textures": {"layer0": f"minecraft:item/{vanilla}"}}
    write(ART, f"assets/{NS}/models/item/{vanilla}_vanilla.json", fallback)
    write(ART, f"assets/minecraft/models/item/{vanilla}.json", {**fallback, "overrides": [
        {"predicate": {"custom_model_data": cmd}, "model": f"{NS}:item/{custom}"},
        {"predicate": {"custom_model_data": cmd + 1}, "model": f"{NS}:item/{vanilla}_vanilla"},
    ]})

dist = ROOT / "dist"
dist.mkdir(exist_ok=True)
for folder, name in [(DATA, "Signalkeepers-1.21.1-datapack.zip"), (ART, "Signalkeepers-1.21.1-models.zip")]:
    with zipfile.ZipFile(dist / name, "w", zipfile.ZIP_DEFLATED) as z:
        for p in sorted(folder.rglob("*")):
            if p.is_file():
                # Fixed timestamps keep builds byte-for-byte reproducible.
                entry = zipfile.ZipInfo(str(p.relative_to(folder)), (2026, 10, 1, 0, 0, 0))
                entry.compress_type = zipfile.ZIP_DEFLATED
                z.writestr(entry, p.read_bytes())
print(f"Built {len(list(DATA.rglob('*.mcfunction')))} functions; two installable ZIPs in {dist}")
