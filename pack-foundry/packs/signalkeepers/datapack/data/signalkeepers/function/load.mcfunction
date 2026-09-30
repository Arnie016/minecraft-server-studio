scoreboard objectives add sk.sys dummy
scoreboard objectives add sk.cell dummy
scoreboard objectives add sk.cd dummy
scoreboard objectives add sk.session dummy
scoreboard objectives add sk.charge dummy
scoreboard objectives add sk.kind dummy
scoreboard objectives add sk.age dummy
scoreboard objectives add sk.tmp dummy
scoreboard objectives add sk.award dummy
scoreboard objectives add sk.pid dummy
scoreboard objectives add sk.line dummy
scoreboard objectives add sk_start trigger
scoreboard objectives add sk_help trigger
scoreboard objectives add sk_kit trigger
scoreboard objectives add sk_leave trigger
scoreboard objectives add sk_end trigger
scoreboard objectives add sk.use minecraft.used:minecraft.carrot_on_a_stick
scoreboard objectives add sk.hook minecraft.used:minecraft.warped_fungus_on_a_stick
execute unless score #init sk.sys matches 1 run function signalkeepers:init
bossbar add signalkeepers:expedition {"text":"Signalkeepers | Relays restored","color":"aqua"}
bossbar set signalkeepers:expedition max 3
bossbar set signalkeepers:expedition color blue
tellraw @a [{"text":"[Signalkeepers] ","color":"aqua"},{"text":"Ready. /trigger sk_help for your field guide.","color":"gray","clickEvent":{"action":"run_command","value":"/trigger sk_help"}}]
