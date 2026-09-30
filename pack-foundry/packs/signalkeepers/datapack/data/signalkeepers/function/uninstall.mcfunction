function signalkeepers:stop
bossbar remove signalkeepers:expedition
data remove storage signalkeepers:run hub
data remove storage signalkeepers:run one
data remove storage signalkeepers:run two
data remove storage signalkeepers:run three
scoreboard objectives remove sk.sys
scoreboard objectives remove sk.cell
scoreboard objectives remove sk.cd
scoreboard objectives remove sk.session
scoreboard objectives remove sk.charge
scoreboard objectives remove sk.kind
scoreboard objectives remove sk.age
scoreboard objectives remove sk.tmp
scoreboard objectives remove sk.award
scoreboard objectives remove sk.pid
scoreboard objectives remove sk.line
scoreboard objectives remove sk.use
scoreboard objectives remove sk.hook
scoreboard objectives remove sk_start
scoreboard objectives remove sk_help
scoreboard objectives remove sk_kit
scoreboard objectives remove sk_leave
scoreboard objectives remove sk_end
tellraw @a {"text": "Signalkeepers uninstalled. Now remove its datapack ZIP and reload.", "color": "gray", "italic": false}
