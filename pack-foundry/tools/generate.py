"""Generate bounded Java 1.21.1 source packs; never touches a game installation."""
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]

def write(pack, path, content):
    p = ROOT / 'packs' / pack / path
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text((content.strip() if isinstance(content,str) else json.dumps(content,indent=2))+'\n')

def function(pack, name, body):
    write(pack,f'data/{pack.replace("-","_")}/function/{name}.mcfunction',body)

def meta(pack, text):
    write(pack,'pack.mcmeta',{'pack':{'pack_format':48,'description':f'Ashfall Workshop | {text} | Java 1.21.1'}})

meta('trail-ledger','Trail Ledger 0.1.0')
ns='trail_ledger'
write('trail-ledger',f'data/{ns}/advancement/root.json',{'display':{'icon':{'id':'minecraft:book'},'title':'Trail Ledger','description':'Seven landscapes. One field journal.','background':'minecraft:textures/gui/advancements/backgrounds/adventure.png','show_toast':False,'announce_to_chat':False},'criteria':{'join':{'trigger':'minecraft:tick'}}})
biomes=[('forest','Forest','oak_sapling'),('desert','Desert','cactus'),('jungle','Jungle','bamboo'),('snowy_plains','Snowy Plains','snowball'),('swamp','Swamp','lily_pad'),('badlands','Badlands','red_sand'),('mushroom_fields','Mushroom Fields','red_mushroom')]
criteria={}
for biome,title,icon in biomes:
    criterion={'trigger':'minecraft:location','conditions':{'player':[{'condition':'minecraft:location_check','predicate':{'biomes':f'minecraft:{biome}'}}]}}
    criteria[biome]=criterion
    write('trail-ledger',f'data/{ns}/advancement/{biome}.json',{'parent':f'{ns}:root','display':{'icon':{'id':f'minecraft:{icon}'},'title':title,'description':f'Record a {title.lower()} landscape.','announce_to_chat':False},'criteria':{'visit':criterion},'rewards':{'experience':5}})
write('trail-ledger',f'data/{ns}/advancement/complete.json',{'parent':f'{ns}:root','display':{'icon':{'id':'minecraft:compass'},'title':'A World Remembered','description':'Visit all seven journal biomes.','frame':'challenge'},'criteria':criteria,'rewards':{'function':f'{ns}:complete'}})
function('trail-ledger','complete', '''give @s minecraft:compass[minecraft:custom_name='{"text":"Wayfarer’s Compass","italic":false,"color":"gold"}',minecraft:custom_data={ashfall_workshop:{pack:"trail-ledger",version:"0.1.0"}}] 1
playsound minecraft:ui.toast.challenge_complete master @s ~ ~ ~ 0.6 1
particle minecraft:happy_villager ~ ~1 ~ 0.4 0.6 0.4 0.1 20 force @s''')
function('trail-ledger','uninstall','tellraw @a {"text":"Trail Ledger: save and quit, then remove the ZIP. Advancement records can remain for future reinstallation.","color":"gold"}')

meta('hearthside','Hearthside 0.1.0')
for tag in ['load','tick']:
    write('hearthside',f'data/minecraft/tags/function/{tag}.json',{'values':[f'hearthside:{tag}']})
function('hearthside','load','scoreboard objectives add hs.timer dummy\nscoreboard objectives add hs.clock dummy\nscoreboard objectives add hearth_toggle trigger\nscoreboard players set #clock hs.clock 0')
write('hearthside','data/hearthside/predicate/resting.json',{'condition':'minecraft:all_of','terms':[{'condition':'minecraft:entity_properties','entity':'this','predicate':{'flags':{'is_sneaking':True}}},{'condition':'minecraft:any_of','terms':[{'condition':'minecraft:entity_properties','entity':'this','predicate':{'nbt':'{foodLevel:'+str(n)+'}'}} for n in [18,19,20]]}]})
function('hearthside','tick','scoreboard players add #clock hs.clock 1\nexecute if score #clock hs.clock matches 20.. run function hearthside:second')
function('hearthside','second','''scoreboard players set #clock hs.clock 0
execute as @a[scores={hearth_toggle=1..}] run function hearthside:toggle
scoreboard players enable @a hearth_toggle
execute as @a[tag=hs.enabled,gamemode=!spectator] at @s run function hearthside:check''')
function('hearthside','toggle','''scoreboard players set @s hearth_toggle 0
scoreboard players set @s hs.timer 0
execute if entity @s[tag=hs.enabled] run return run function hearthside:disable
tag @s add hs.enabled
tellraw @s {"text":"Hearthside enabled. Crouch above a safe lit campfire, with at least nine food icons, for ten seconds.","color":"gold"}''')
function('hearthside','disable','tag @s remove hs.enabled\ntellraw @s {"text":"Hearthside disabled.","color":"gray"}')
function('hearthside','check','''tag @s remove hs.warm
execute if block ~ ~-1 ~ minecraft:campfire[lit=true] run tag @s add hs.warm
execute if block ~ ~-2 ~ minecraft:campfire[lit=true] run tag @s add hs.warm
execute if block ~ ~-1 ~ minecraft:soul_campfire[lit=true] run tag @s add hs.warm
execute if block ~ ~-2 ~ minecraft:soul_campfire[lit=true] run tag @s add hs.warm
execute unless predicate hearthside:resting run tag @s remove hs.warm
execute unless entity @s[tag=hs.warm] run scoreboard players set @s hs.timer 0
execute if entity @s[tag=hs.warm] run scoreboard players add @s hs.timer 1
execute if score @s hs.timer matches 10.. run function hearthside:restore
tag @s remove hs.warm''')
function('hearthside','restore','''scoreboard players set @s hs.timer 0
effect give @s minecraft:regeneration 3 0 true
particle minecraft:happy_villager ~ ~1 ~ 0.2 0.3 0.2 0 5 force @s
playsound minecraft:block.amethyst_block.chime player @s ~ ~ ~ 0.2 0.8''')
function('hearthside','uninstall','''tag @a remove hs.enabled
tag @a remove hs.warm
scoreboard objectives remove hs.timer
scoreboard objectives remove hs.clock
scoreboard objectives remove hearth_toggle
tellraw @a {"text":"Hearthside: save and quit now, remove its ZIP, then reopen. Offline players should toggle off after reinstallation.","color":"gold"}''')

meta('fieldcraft','Fieldcraft 0.1.0')
recipes={
'string':{'type':'minecraft:crafting_shapeless','ingredients':[{'tag':'minecraft:wool'}],'result':{'id':'minecraft:string','count':4}},
'flint':{'type':'minecraft:crafting_shapeless','ingredients':[{'item':'minecraft:gravel'}]*3,'result':{'id':'minecraft:flint','count':1}},
'leather':{'type':'minecraft:smelting','ingredient':{'item':'minecraft:rotten_flesh'},'result':{'id':'minecraft:leather'},'experience':0.1,'cookingtime':400},
'name_tag':{'type':'minecraft:crafting_shapeless','ingredients':[{'item':'minecraft:paper'},{'item':'minecraft:string'},{'item':'minecraft:iron_nugget'}],'result':{'id':'minecraft:name_tag','count':1}},
'saddle':{'type':'minecraft:crafting_shaped','pattern':['LLL','LIL',' I '],'key':{'L':{'item':'minecraft:leather'},'I':{'item':'minecraft:iron_ingot'}},'result':{'id':'minecraft:saddle','count':1}},
'lead':{'type':'minecraft:crafting_shaped','pattern':['SS ','SL ','  S'],'key':{'S':{'item':'minecraft:string'},'L':{'item':'minecraft:leather'}},'result':{'id':'minecraft:lead','count':1}}
}
for name,recipe in recipes.items():
    write('fieldcraft',f'data/fieldcraft/recipe/{name}.json',recipe)
write('fieldcraft','data/fieldcraft/advancement/recipes.json',{'criteria':{'join':{'trigger':'minecraft:tick'}},'rewards':{'recipes':[f'fieldcraft:{name}' for name in recipes]}})
function('fieldcraft','uninstall','\n'.join('recipe take @a fieldcraft:'+name for name in recipes)+'\ntellraw @a {"text":"Fieldcraft: save and quit, remove the ZIP, then reopen. Crafted items remain yours.","color":"gold"}')
print('Generated Trail Ledger, Hearthside and Fieldcraft source packs.')
