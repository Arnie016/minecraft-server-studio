scoreboard players set #heat sk.sys 55
scoreboard players add #surges sk.sys 1
tellraw @a[tag=sk.member] {"text": "SIGNAL SURGE — Something heard you. Quiet scans keep interference down.", "color": "red", "italic": false}
playsound minecraft:entity.warden.heartbeat player @s ~ ~ ~ 0.6 1.4
scoreboard players set #echoes sk.tmp 0
execute as @e[type=minecraft:husk,tag=sk.echo] run scoreboard players add #echoes sk.tmp 1
execute if score #echoes sk.tmp matches ..2 positioned ~4 ~ ~4 positioned over motion_blocking_no_leaves run function signalkeepers:echo/spawn
execute if score #echoes sk.tmp matches ..2 positioned ~-4 ~ ~-4 positioned over motion_blocking_no_leaves run function signalkeepers:echo/spawn
