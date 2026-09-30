give @s minecraft:amethyst_shard[minecraft:custom_data={signalkeepers:{relic:1b}},minecraft:custom_model_data=731211,minecraft:custom_name='{"text": "Seed of the Signal", "color": "light_purple", "italic": false}',minecraft:lore=['{"text": "Three relays. One town remembered.", "color": "gray", "italic": false}'],minecraft:max_stack_size=1] 1
scoreboard players operation @s sk.award = #session sk.sys
experience add @s 5 levels
tellraw @s {"text": "Relic recovered. A new expedition can be started anywhere outdoors with /trigger sk_start.", "color": "gray", "italic": false}
