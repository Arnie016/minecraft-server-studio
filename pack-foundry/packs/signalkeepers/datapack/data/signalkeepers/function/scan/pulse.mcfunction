scoreboard players set @s sk.cd 40
execute if score #quiet sk.tmp matches 1 run scoreboard players remove @s sk.cell 4
execute if score #quiet sk.tmp matches 1 run scoreboard players add #heat sk.sys 2
execute if score #quiet sk.tmp matches 0 run scoreboard players remove @s sk.cell 8
execute if score #quiet sk.tmp matches 0 run scoreboard players add #heat sk.sys 18
playsound minecraft:block.amethyst_block.chime player @s ~ ~ ~ 0.7 1.2
tag @e[tag=sk.target] remove sk.target
execute if score #relays sk.sys matches ..1 run tag @e[type=minecraft:marker,tag=sk.relay,tag=!sk.done,scores={sk.kind=1..2},sort=nearest,limit=1] add sk.target
execute if score #relays sk.sys matches 2 run tag @e[type=minecraft:marker,tag=sk.three,limit=1] add sk.target
execute if score #relays sk.sys matches 3 run tag @e[type=minecraft:marker,tag=sk.hub,limit=1] add sk.target
execute if entity @e[type=minecraft:marker,tag=sk.target,distance=..4,limit=1] run function signalkeepers:scan/near
execute unless entity @e[type=minecraft:marker,tag=sk.target,distance=..4,limit=1] run function signalkeepers:scan/guide
execute if score #state sk.sys matches 1..2 if score #heat sk.sys matches 100.. run function signalkeepers:surge
tag @e[tag=sk.target] remove sk.target
