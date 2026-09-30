execute if score #quiet sk.tmp matches 1 run scoreboard players add @e[type=minecraft:marker,tag=sk.target,limit=1] sk.charge 2
execute if score #quiet sk.tmp matches 0 run scoreboard players add @e[type=minecraft:marker,tag=sk.target,limit=1] sk.charge 1
function signalkeepers:tune/feedback
execute if score @e[type=minecraft:marker,tag=sk.target,limit=1] sk.charge matches 8.. run function signalkeepers:complete/one
