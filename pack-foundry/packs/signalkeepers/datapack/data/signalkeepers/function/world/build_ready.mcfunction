function signalkeepers:world/build_hub with storage signalkeepers:run hub
function signalkeepers:world/build_one with storage signalkeepers:run one
function signalkeepers:world/build_two with storage signalkeepers:run two
function signalkeepers:world/build_three with storage signalkeepers:run three
scoreboard players set #state sk.sys 1
tellraw @a[tag=sk.member] {"text": "The receivers are online. Restore the Listening Post and the Capacitor, then wake the Last Lantern.", "color": "gold", "italic": false}
