execute if score @s sk.line matches 1.. run return 0
execute if score @s sk.cell matches ..5 run return run function signalkeepers:scan/empty
scoreboard players set @s sk.cd 15
scoreboard players operation #pid sk.tmp = @s sk.pid
execute as @e[type=minecraft:marker,tag=sk.hook_anchor] if score @s sk.pid = #pid sk.tmp run kill @s
scoreboard players set #ray sk.tmp 0
execute anchored eyes positioned ^ ^ ^0.5 run function signalkeepers:hook/ray
execute unless score @s sk.line matches 1.. run tellraw @s {"text":"No clear tree anchor within 24 blocks.","color":"gray"}
