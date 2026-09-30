$execute in minecraft:overworld store success score #one_prior sk.tmp run forceload query $(x) $(z)
scoreboard players set #one_owned sk.tmp 0
$execute in minecraft:overworld unless score #one_prior sk.tmp matches 1 store success score #one_owned sk.tmp run forceload add $(x) $(z)
