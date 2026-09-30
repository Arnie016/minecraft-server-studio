scoreboard players set @s sk_start 0
execute unless dimension minecraft:overworld run return run function signalkeepers:message/overworld
execute if entity @s[gamemode=spectator] run return run function signalkeepers:message/spectator
execute if score #state sk.sys matches -1 run return run function signalkeepers:message/building
execute if score #state sk.sys matches 1..2 run return run function signalkeepers:join
function signalkeepers:start
