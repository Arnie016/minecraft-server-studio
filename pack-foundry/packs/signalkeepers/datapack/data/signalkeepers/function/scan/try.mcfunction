scoreboard players set #quiet sk.tmp 0
execute if predicate signalkeepers:sneaking run scoreboard players set #quiet sk.tmp 1
execute if score #quiet sk.tmp matches 1 if score @s sk.cell matches ..3 run return run function signalkeepers:scan/empty
execute if score #quiet sk.tmp matches 0 if score @s sk.cell matches ..7 run return run function signalkeepers:scan/empty
function signalkeepers:scan/pulse
