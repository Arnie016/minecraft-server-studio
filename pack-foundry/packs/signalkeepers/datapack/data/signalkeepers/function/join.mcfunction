execute if entity @s[tag=sk.member] if score @s sk.session = #session sk.sys run return run function signalkeepers:request/help
tag @s add sk.member
scoreboard players operation @s sk.session = #session sk.sys
scoreboard players set @s sk.cell 100
scoreboard players set @s sk.cd 0
execute unless score @s sk.pid matches 1.. run function signalkeepers:hook/assign
scoreboard players set @s sk.line 0
scoreboard players set @s sk.hook 0
scoreboard players set @s sk.use 0
function signalkeepers:request/kit
tellraw @s {"text": "You are a Signalkeeper. Three abandoned relays are still broadcasting. Find out who they are calling.", "color": "gold", "italic": false}
tellraw @s {"text": "The scanner beam points to the next relay. Crouch for quiet scans; stand for stronger pulses. Camp recharges it.", "color": "gray", "italic": false}
function signalkeepers:world/announce with storage signalkeepers:run hub
