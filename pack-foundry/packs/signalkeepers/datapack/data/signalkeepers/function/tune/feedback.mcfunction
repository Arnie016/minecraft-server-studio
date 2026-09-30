execute store result score #charge sk.tmp run scoreboard players get @e[type=minecraft:marker,tag=sk.target,limit=1] sk.charge
tellraw @s [{"text":"Relay coherence ","color":"aqua"},{"score":{"name":"#charge","objective":"sk.tmp"}},{"text":"/8. I prefers listening; II prefers power; III requires silence.","color":"gray"}]
