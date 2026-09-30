$execute in minecraft:overworld store success score #hub_prior sk.tmp run forceload query $(x) $(z)
scoreboard players set #hub_owned sk.tmp 0
$execute in minecraft:overworld unless score #hub_prior sk.tmp matches 1 store success score #hub_owned sk.tmp run forceload add $(x) $(z)
