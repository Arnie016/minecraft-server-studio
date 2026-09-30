execute unless score #quiet sk.tmp matches 1 run return run tellraw @s {"text":"The Last Lantern only answers a quiet signal. Crouch, then scan.","color":"yellow"}
execute if score #heat sk.sys matches 30.. run return run tellraw @s {"text":"Too much interference. Wait for it to fall below 30, then listen again.","color":"yellow"}
scoreboard players add @e[type=minecraft:marker,tag=sk.target,limit=1] sk.charge 2
function signalkeepers:tune/feedback
execute if score @e[type=minecraft:marker,tag=sk.target,limit=1] sk.charge matches 8.. run function signalkeepers:complete/three
