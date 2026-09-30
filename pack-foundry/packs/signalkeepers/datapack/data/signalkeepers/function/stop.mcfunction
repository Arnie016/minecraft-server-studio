function signalkeepers:world/cleanup
scoreboard players set #state sk.sys 0
bossbar set signalkeepers:expedition visible false
clear @a[tag=sk.member] minecraft:carrot_on_a_stick[minecraft:custom_data~{signalkeepers:{scanner:1b}}]
clear @a[tag=sk.member] minecraft:warped_fungus_on_a_stick[minecraft:custom_data~{signalkeepers:{winch:1b}}]
scoreboard players set @a sk.line 0
tellraw @a[tag=sk.member] {"text": "Expedition closed. Survey projections and owned chunk tickets have been removed.", "color": "gray", "italic": false}
tag @a remove sk.member
tag @a remove sk.owner
