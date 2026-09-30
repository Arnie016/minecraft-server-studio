function signalkeepers:world/cleanup
scoreboard players add #session sk.sys 1
tag @a remove sk.owner
tag @a remove sk.member
tag @s add sk.owner
scoreboard players set #state sk.sys -1
scoreboard players set #heat sk.sys 0
scoreboard players set #relays sk.sys 0
scoreboard players set #surges sk.sys 0
scoreboard players set #upgrade sk.sys 0
scoreboard players set #idle sk.sys 0
scoreboard players set #buildwait sk.sys 0
execute store result score #x sk.tmp run data get entity @s Pos[0] 1
execute store result score #z sk.tmp run data get entity @s Pos[2] 1
data modify storage signalkeepers:run hub set value {x:0,z:0}
scoreboard players operation #posx sk.tmp = #x sk.tmp
scoreboard players add #posx sk.tmp 0
scoreboard players operation #posz sk.tmp = #z sk.tmp
scoreboard players add #posz sk.tmp 0
execute store result storage signalkeepers:run hub.x int 1 run scoreboard players get #posx sk.tmp
execute store result storage signalkeepers:run hub.z int 1 run scoreboard players get #posz sk.tmp
function signalkeepers:world/acquire_hub with storage signalkeepers:run hub
data modify storage signalkeepers:run one set value {x:0,z:0}
scoreboard players operation #posx sk.tmp = #x sk.tmp
scoreboard players add #posx sk.tmp 80
scoreboard players operation #posz sk.tmp = #z sk.tmp
scoreboard players add #posz sk.tmp 16
execute store result storage signalkeepers:run one.x int 1 run scoreboard players get #posx sk.tmp
execute store result storage signalkeepers:run one.z int 1 run scoreboard players get #posz sk.tmp
function signalkeepers:world/acquire_one with storage signalkeepers:run one
data modify storage signalkeepers:run two set value {x:0,z:0}
scoreboard players operation #posx sk.tmp = #x sk.tmp
scoreboard players remove #posx sk.tmp 48
scoreboard players operation #posz sk.tmp = #z sk.tmp
scoreboard players add #posz sk.tmp 80
execute store result storage signalkeepers:run two.x int 1 run scoreboard players get #posx sk.tmp
execute store result storage signalkeepers:run two.z int 1 run scoreboard players get #posz sk.tmp
function signalkeepers:world/acquire_two with storage signalkeepers:run two
data modify storage signalkeepers:run three set value {x:0,z:0}
scoreboard players operation #posx sk.tmp = #x sk.tmp
scoreboard players remove #posx sk.tmp 64
scoreboard players operation #posz sk.tmp = #z sk.tmp
scoreboard players remove #posz sk.tmp 64
execute store result storage signalkeepers:run three.x int 1 run scoreboard players get #posx sk.tmp
execute store result storage signalkeepers:run three.z int 1 run scoreboard players get #posz sk.tmp
function signalkeepers:world/acquire_three with storage signalkeepers:run three
function signalkeepers:join
tellraw @s {"text": "Survey instruments deploying. No terrain will be replaced.", "color": "gray", "italic": false}
schedule function signalkeepers:world/build 10t replace
