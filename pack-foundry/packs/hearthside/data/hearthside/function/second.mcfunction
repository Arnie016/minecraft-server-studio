scoreboard players set #clock hs.clock 0
execute as @a[scores={hearth_toggle=1..}] run function hearthside:toggle
scoreboard players enable @a hearth_toggle
execute as @a[tag=hs.enabled,gamemode=!spectator] at @s run function hearthside:check
