tag @e[tag=sk.hook_target] remove sk.hook_target
scoreboard players operation #pid sk.tmp = @s sk.pid
execute as @e[type=minecraft:marker,tag=sk.hook_anchor] if score @s sk.pid = #pid sk.tmp run tag @s add sk.hook_target
execute unless entity @e[tag=sk.hook_target] run scoreboard players set @s sk.line 0
execute if entity @e[tag=sk.hook_target,distance=..2] run scoreboard players set @s sk.line 0
execute unless score @s sk.line matches 1.. run return run function signalkeepers:hook/release
scoreboard players set #moved sk.tmp 0
function signalkeepers:hook/move
execute if score #moved sk.tmp matches 1 at @s run function signalkeepers:hook/move
effect give @s minecraft:slow_falling 2 0 true
scoreboard players remove @s sk.line 1
execute unless score #moved sk.tmp matches 1 run scoreboard players set @s sk.line 0
execute unless score @s sk.line matches 1.. run function signalkeepers:hook/release
