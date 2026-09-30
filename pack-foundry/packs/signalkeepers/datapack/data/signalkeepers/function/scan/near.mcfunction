execute if entity @e[type=minecraft:marker,tag=sk.target,tag=sk.hub,distance=..4] run return run function signalkeepers:finish
execute if entity @e[type=minecraft:marker,tag=sk.target,tag=sk.one,distance=..4] run function signalkeepers:tune/one
execute if entity @e[type=minecraft:marker,tag=sk.target,tag=sk.two,distance=..4] run function signalkeepers:tune/two
execute if entity @e[type=minecraft:marker,tag=sk.target,tag=sk.three,distance=..4] run function signalkeepers:tune/three
