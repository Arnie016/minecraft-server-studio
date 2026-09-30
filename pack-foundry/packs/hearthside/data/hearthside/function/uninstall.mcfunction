tag @a remove hs.enabled
tag @a remove hs.warm
scoreboard objectives remove hs.timer
scoreboard objectives remove hs.clock
scoreboard objectives remove hearth_toggle
tellraw @a {"text":"Hearthside: save and quit now, remove its ZIP, then reopen. Offline players should toggle off after reinstallation.","color":"gold"}
