particle minecraft:dust{color:[0.15,0.85,0.8],scale:0.7} ~ ~ ~ 0 0 0 0 1 normal @s
scoreboard players add #ray sk.tmp 1
execute if score #ray sk.tmp matches ..23 positioned ^ ^ ^1 run function signalkeepers:scan/ray
