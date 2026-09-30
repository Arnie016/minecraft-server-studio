scoreboard players set @s sk_leave 0
tag @s remove sk.member
clear @s minecraft:carrot_on_a_stick[minecraft:custom_data~{signalkeepers:{scanner:1b}}]
clear @s minecraft:warped_fungus_on_a_stick[minecraft:custom_data~{signalkeepers:{winch:1b}}]
scoreboard players set @s sk.line 0
tellraw @s {"text": "You left the expedition. Your progress remains shared; /trigger sk_start rejoins it.", "color": "gray", "italic": false}
