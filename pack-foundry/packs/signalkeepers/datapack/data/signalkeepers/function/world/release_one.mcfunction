$execute in minecraft:overworld if score #one_owned sk.tmp matches 1 run forceload remove $(x) $(z)
scoreboard players set #one_owned sk.tmp 0
