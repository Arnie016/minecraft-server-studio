execute unless score #state sk.sys matches -1 run return 0
scoreboard players set #loaded sk.tmp 0
function signalkeepers:world/check_hub with storage signalkeepers:run hub
function signalkeepers:world/check_one with storage signalkeepers:run one
function signalkeepers:world/check_two with storage signalkeepers:run two
function signalkeepers:world/check_three with storage signalkeepers:run three
execute if score #loaded sk.tmp matches 4 run return run function signalkeepers:world/build_ready
scoreboard players add #buildwait sk.sys 1
execute if score #buildwait sk.sys matches 40.. run return run function signalkeepers:world/build_failed
schedule function signalkeepers:world/build 10t replace
