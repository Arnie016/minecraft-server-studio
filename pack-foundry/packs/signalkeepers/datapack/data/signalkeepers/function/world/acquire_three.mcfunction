$execute in minecraft:overworld store success score #three_prior sk.tmp run forceload query $(x) $(z)
scoreboard players set #three_owned sk.tmp 0
$execute in minecraft:overworld unless score #three_prior sk.tmp matches 1 store success score #three_owned sk.tmp run forceload add $(x) $(z)
