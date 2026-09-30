execute if score #state sk.sys matches 0 run function signalkeepers:inactive
execute if score #state sk.sys matches 3 run function signalkeepers:inactive
execute in minecraft:overworld as @e[tag=sk.entity] unless score @s sk.session = #session sk.sys run kill @s
execute as @a[tag=sk.member] unless score @s sk.session = #session sk.sys run tag @s remove sk.member
execute as @a[tag=sk.owner] unless score @s sk.session = #session sk.sys run tag @s remove sk.owner
execute as @a[scores={sk_start=1..}] at @s run function signalkeepers:request/start
execute as @a[scores={sk_help=1..}] at @s run function signalkeepers:request/help
execute as @a[scores={sk_kit=1..}] at @s run function signalkeepers:request/kit
execute as @a[scores={sk_leave=1..}] at @s run function signalkeepers:request/leave
execute as @a[scores={sk_end=1..}] at @s run function signalkeepers:request/end
scoreboard players remove @a[scores={sk.cd=1..}] sk.cd 1
execute if score #state sk.sys matches 1..2 as @a[tag=sk.member,scores={sk.hook=1..,sk.cd=0}] at @s if dimension minecraft:overworld if items entity @s weapon.mainhand minecraft:warped_fungus_on_a_stick[minecraft:custom_data~{signalkeepers:{winch:1b}}] run function signalkeepers:hook/try
execute as @a[tag=sk.member,scores={sk.line=1..}] at @s if dimension minecraft:overworld run function signalkeepers:hook/step
scoreboard players set @a[scores={sk.hook=1..}] sk.hook 0
execute if score #state sk.sys matches 1..2 as @a[tag=sk.member,scores={sk.use=1..,sk.cd=0}] at @s if dimension minecraft:overworld if items entity @s weapon.mainhand minecraft:carrot_on_a_stick[minecraft:custom_data~{signalkeepers:{scanner:1b}}] run function signalkeepers:scan/try
scoreboard players set @a[scores={sk.use=1..}] sk.use 0
scoreboard players add #tick sk.sys 1
execute if score #tick sk.sys matches 20.. run function signalkeepers:second
