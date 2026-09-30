execute if block ~ ~ ~ #signalkeepers:grapple_targets run return run function signalkeepers:hook/hit
execute unless block ~ ~ ~ #signalkeepers:passable run return 0
scoreboard players add #ray sk.tmp 1
execute if score #ray sk.tmp matches ..47 positioned ^ ^ ^0.5 run function signalkeepers:hook/ray
