scoreboard players set @s hearth_toggle 0
scoreboard players set @s hs.timer 0
execute if entity @s[tag=hs.enabled] run return run function hearthside:disable
tag @s add hs.enabled
tellraw @s {"text":"Hearthside enabled. Crouch above a safe lit campfire, with at least nine food icons, for ten seconds.","color":"gold"}
