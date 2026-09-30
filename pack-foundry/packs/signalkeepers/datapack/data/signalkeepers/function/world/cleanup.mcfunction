schedule clear signalkeepers:world/build
execute in minecraft:overworld run kill @e[tag=sk.entity]
execute if data storage signalkeepers:run hub run function signalkeepers:world/release_hub with storage signalkeepers:run hub
execute if data storage signalkeepers:run one run function signalkeepers:world/release_one with storage signalkeepers:run one
execute if data storage signalkeepers:run two run function signalkeepers:world/release_two with storage signalkeepers:run two
execute if data storage signalkeepers:run three run function signalkeepers:world/release_three with storage signalkeepers:run three
