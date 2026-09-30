scoreboard players set #tick sk.sys 0
scoreboard players enable @a sk_start
scoreboard players enable @a sk_help
scoreboard players enable @a sk_kit
scoreboard players enable @a sk_leave
scoreboard players enable @a sk_end
execute if score #state sk.sys matches 1..2 run function signalkeepers:active
