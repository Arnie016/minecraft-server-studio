$execute in minecraft:overworld store success score #two_prior sk.tmp run forceload query $(x) $(z)
scoreboard players set #two_owned sk.tmp 0
$execute in minecraft:overworld unless score #two_prior sk.tmp matches 1 store success score #two_owned sk.tmp run forceload add $(x) $(z)
