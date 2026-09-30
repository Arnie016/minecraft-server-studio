execute if score #ray sk.tmp matches ..3 run return 0
execute positioned ^ ^ ^-1 run summon minecraft:marker ~ ~ ~ {Tags:["sk.entity","sk.unstamped","sk.hook_anchor","sk.new_hook"]}
function signalkeepers:world/stamp
scoreboard players operation @e[type=minecraft:marker,tag=sk.new_hook,limit=1] sk.pid = @s sk.pid
scoreboard players set @e[type=minecraft:marker,tag=sk.new_hook,limit=1] sk.age 0
tag @e[tag=sk.new_hook] remove sk.new_hook
scoreboard players set @s sk.line 35
scoreboard players remove @s sk.cell 6
playsound minecraft:item.crossbow.shoot player @s ~ ~ ~ 0.6 1.6
