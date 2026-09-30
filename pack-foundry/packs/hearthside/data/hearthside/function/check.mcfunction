tag @s remove hs.warm
execute if block ~ ~-1 ~ minecraft:campfire[lit=true] run tag @s add hs.warm
execute if block ~ ~-2 ~ minecraft:campfire[lit=true] run tag @s add hs.warm
execute if block ~ ~-1 ~ minecraft:soul_campfire[lit=true] run tag @s add hs.warm
execute if block ~ ~-2 ~ minecraft:soul_campfire[lit=true] run tag @s add hs.warm
execute unless predicate hearthside:resting run tag @s remove hs.warm
execute unless entity @s[tag=hs.warm] run scoreboard players set @s hs.timer 0
execute if entity @s[tag=hs.warm] run scoreboard players add @s hs.timer 1
execute if score @s hs.timer matches 10.. run function hearthside:restore
tag @s remove hs.warm
