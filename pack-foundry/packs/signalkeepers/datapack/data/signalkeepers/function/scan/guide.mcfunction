scoreboard players set #ray sk.tmp 0
execute anchored eyes facing entity @e[type=minecraft:marker,tag=sk.target,limit=1] feet positioned ^ ^ ^1 run function signalkeepers:scan/ray
execute store result score #targetx sk.tmp run data get entity @e[type=minecraft:marker,tag=sk.target,limit=1] Pos[0] 1
execute store result score #targetz sk.tmp run data get entity @e[type=minecraft:marker,tag=sk.target,limit=1] Pos[2] 1
tellraw @s [{"text":"Signal bearing • X ","color":"aqua"},{"score":{"name":"#targetx","objective":"sk.tmp"}},{"text":"  Z "},{"score":{"name":"#targetz","objective":"sk.tmp"}},{"text":". Tune within 4 blocks.","color":"gray"}]
