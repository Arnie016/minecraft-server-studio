execute if entity @a[tag=sk.member] run scoreboard players set #idle sk.sys 0
execute unless entity @a[tag=sk.member] run scoreboard players add #idle sk.sys 1
execute if score #idle sk.sys matches 300.. run return run function signalkeepers:stop
execute if score #heat sk.sys matches 1.. run scoreboard players remove #heat sk.sys 2
execute if score #heat sk.sys matches 1.. if score #upgrade sk.sys matches 1 run scoreboard players remove #heat sk.sys 2
execute if score #heat sk.sys matches ..-1 run scoreboard players set #heat sk.sys 0
execute in minecraft:overworld at @e[type=minecraft:marker,tag=sk.hub,limit=1] as @a[tag=sk.member,distance=..6,scores={sk.cell=..99}] run scoreboard players add @s sk.cell 8
scoreboard players set @a[scores={sk.cell=101..}] sk.cell 100
execute in minecraft:overworld as @e[type=minecraft:husk,tag=sk.echo] run scoreboard players add @s sk.age 1
execute in minecraft:overworld as @e[type=minecraft:husk,tag=sk.echo,scores={sk.age=60..}] run kill @s
execute in minecraft:overworld as @e[type=minecraft:marker,tag=sk.hook_anchor] run scoreboard players add @s sk.age 1
execute in minecraft:overworld run kill @e[type=minecraft:marker,tag=sk.hook_anchor,scores={sk.age=3..}]
execute in minecraft:overworld as @e[type=minecraft:marker,tag=sk.anchor] at @s if entity @a[tag=sk.member,distance=..40] run particle minecraft:reverse_portal ~ ~1.8 ~ 0.25 0.35 0.25 0.015 3 normal @a[tag=sk.member,distance=..40]
bossbar set signalkeepers:expedition players @a[tag=sk.member]
bossbar set signalkeepers:expedition visible true
execute store result bossbar signalkeepers:expedition value run scoreboard players get #relays sk.sys
execute as @a[tag=sk.member] at @s if items entity @s weapon.mainhand minecraft:carrot_on_a_stick[minecraft:custom_data~{signalkeepers:{scanner:1b}}] run function signalkeepers:hud
