scoreboard players set @s sk.cd 20
tellraw @s {"text": "Battery low. Return to camp; it recharges within 6 blocks. /trigger sk_help for the guide.", "color": "yellow", "italic": false}
function signalkeepers:world/announce with storage signalkeepers:run hub
