execute unless score #state sk.sys matches 2 run return 0
execute unless score #relays sk.sys matches 3 run return 0
scoreboard players set #state sk.sys 3
title @a[tag=sk.member] title {"text":"THE LAMPS ARE LIT","color":"gold"}
execute if score #surges sk.sys matches 0 run tellraw @a[tag=sk.member] {"text": "QUIET ENDING — You heard the town without waking its echoes. The archive returns intact.", "color": "aqua", "italic": false}
execute if score #surges sk.sys matches 1.. run tellraw @a[tag=sk.member] {"text": "STORM ENDING — The archive survived, but your signal woke its guardians. The town is remembered all the same.", "color": "gold", "italic": false}
execute as @a[tag=sk.member] unless score @s sk.award = #session sk.sys run function signalkeepers:reward
function signalkeepers:world/cleanup
bossbar set signalkeepers:expedition visible false
tag @a remove sk.member
tag @a remove sk.owner
