scoreboard players set @s sk_end 0
execute unless entity @s[tag=sk.owner] run return run tellraw @s {"text":"Only the expedition leader can end it. Use /trigger sk_leave to leave.","color":"yellow"}
function signalkeepers:stop
