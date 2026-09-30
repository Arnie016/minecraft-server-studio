execute if entity @e[type=minecraft:marker,tag=sk.target,limit=1,tag=sk.done] run return 0
tag @e[type=minecraft:marker,tag=sk.target,limit=1] add sk.done
scoreboard players add #relays sk.sys 1
execute as @e[type=minecraft:block_display,tag=sk.three,tag=sk.core] run data merge entity @s {block_state:{Name:"minecraft:emerald_block"}}
playsound minecraft:block.beacon.activate player @a[tag=sk.member] ~ ~ ~ 0.6 1.2
tellraw @a[tag=sk.member] {"text": "RECORDING 03 — No one was trapped below. We chose to leave a seed, not a grave. Bring the signal back to camp.", "color": "gold", "italic": false}
execute if score #relays sk.sys matches 2 run tellraw @a[tag=sk.member] {"text": "The Last Lantern is unlocked. Let interference fall below 30 before quiet tuning.", "color": "aqua", "italic": false}
execute if score #relays sk.sys matches 3 run scoreboard players set #state sk.sys 2
