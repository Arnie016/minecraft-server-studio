$execute in minecraft:overworld if score #hub_owned sk.tmp matches 1 run forceload remove $(x) $(z)
scoreboard players set #hub_owned sk.tmp 0
