"""Real 1.21.1 server checks in a NEW disposable directory; never deletes saves.
Provide an official server.jar, Java 21, and tests/node_modules (npm ci).
"""
import argparse,json,os,re,secrets,shutil,subprocess,time,tempfile
from pathlib import Path
from rcon import Rcon
ROOT=Path(__file__).resolve().parents[1]
a=argparse.ArgumentParser();a.add_argument('--server-jar',required=True);a.add_argument('--java',default='java');a.add_argument('--node-modules',default=str(Path(__file__).parent/'node_modules'));args=a.parse_args()
jar=Path(args.server_jar).resolve();java=str(Path(args.java).resolve()) if '/' in args.java else args.java
r=Path(tempfile.mkdtemp(prefix='ashfall-pack-test-'));(r/'SIGNALKEEPERS_TEST_WORLD').touch()
(r/'eula.txt').write_text('eula=true\n')
settings={'layers':[{'block':'minecraft:bedrock','height':1},{'block':'minecraft:dirt','height':2},{'block':'minecraft:grass_block','height':1}],'biome':'minecraft:plains','structures':{}}
(r/'server.properties').write_text('server-ip=127.0.0.1\nserver-port=25576\nonline-mode=false\nenforce-secure-profile=false\nenable-rcon=true\nrcon.port=25577\nrcon.password='+secrets.token_hex(24)+'\nlevel-type=minecraft:flat\ngenerator-settings='+json.dumps(settings)+'\nspawn-protection=0\nview-distance=2\nsimulation-distance=2\nmax-players=3\nspawn-monsters=false\ngamemode=survival\n')
(r/'world/datapacks').mkdir(parents=True)
cat=json.loads((ROOT/'dist/catalog.json').read_text())
for p in cat['packs']:
    if p['kind']=='datapack':shutil.copy(ROOT/'dist'/p['filename'],r/'world/datapacks'/p['filename'])
log=(r/'output.log').open('w');clientlog=(r/'clients.log').open('w');bot=None;server=None;rc=None;results=[]
def check(name,value):
    results.append({'check':name,'passed':bool(value)})
    print(('PASS ' if value else 'FAIL ')+name,flush=True)
    if not value:raise AssertionError(name)
def command(s):return rc.command(s)
def action(s):bot.stdin.write(json.dumps(s)+'\n');bot.stdin.flush()
def has_adv(name):return 'FOUND' in command('execute if entity KeeperTest[advancements={trail_ledger:'+name+'=true}] run say FOUND')
try:
    server=subprocess.Popen([java,'-XX:ActiveProcessorCount=2','-Xms256M','-Xmx1100M','-jar',str(jar),'nogui'],cwd=r,stdin=subprocess.PIPE,stdout=log,stderr=subprocess.STDOUT,text=True)
    deadline=time.monotonic()+150
    while time.monotonic()<deadline:
        text=(r/'output.log').read_text()
        if 'Done (' in text:break
        if server.poll() is not None:raise RuntimeError('Server exited: '+text[-3000:])
        time.sleep(.5)
    else:raise TimeoutError('Server startup timed out: '+(r/'output.log').read_text()[-2000:])
    check('server accepted pack functions/recipes/advancements',not re.search(r'Failed to (load|parse)|Parsing error|Couldn.t load',text))
    rc=Rcon(r);command('gamerule doMobSpawning false');command('gamerule doWeatherCycle false');command('gamerule doDaylightCycle false')
    env=dict(os.environ,NODE_PATH=str(Path(args.node_modules).resolve()))
    bot=subprocess.Popen(['node',str(ROOT/'tests/protocol_client.cjs'),'25576'],env=env,cwd=r,stdin=subprocess.PIPE,stdout=clientlog,stderr=subprocess.STDOUT,text=True)
    for _ in range(60):
        if 'KeeperTest' in command('list') and 'PartnerTest' in command('list'):break
        time.sleep(.25)
    check('two protocol players connected','2 of' in command('list'))
    command('op KeeperTest');command('tp KeeperTest 0.5 -60 0.5');command('tp PartnerTest 8.5 -60 8.5');time.sleep(2)
    for biome in ['forest','desert','jungle','snowy_plains','swamp','badlands','mushroom_fields']:
        command(f'fillbiome -4 -64 -4 4 0 4 minecraft:{biome}')
        time.sleep(1.2)
        check('journal records '+biome,has_adv(biome))
    check('journal completion recorded',has_adv('complete'))
    check('completion awards one compass','Found 1 matching item' in command('clear KeeperTest minecraft:compass 0'))
    time.sleep(1.2)
    check('completion reward does not repeat','Found 1 matching item' in command('clear KeeperTest minecraft:compass 0'))
    for recipe in ['string','flint','leather','name_tag','saddle','lead']:
        check('recipe unlocked '+recipe,'FOUND' in command('execute if entity KeeperTest[nbt={recipeBook:{recipes:["fieldcraft:'+recipe+'"]}}] run say FOUND'))
    command('setblock 0 -62 0 minecraft:campfire[lit=true]');command('setblock 0 -61 0 minecraft:hay_block');command('tp KeeperTest 0.5 -60 0.5')
    command('effect give KeeperTest minecraft:saturation 1 10 true');time.sleep(1.2)
    action({'action':'chat','text':'/trigger hearth_toggle'});time.sleep(1.2)
    check('campfire opt-in works','hs.enabled' in command('tag KeeperTest list'))
    action({'action':'crouch','value':True});time.sleep(2.2)
    timer=command('scoreboard players get KeeperTest hs.timer');check('crouching at warm camp advances rest',bool(re.search(r'has [1-9] ',timer)))
    action({'action':'crouch','value':False});time.sleep(1.2)
    check('standing resets rest','has 0 ' in command('scoreboard players get KeeperTest hs.timer'))
    action({'action':'crouch','value':True});time.sleep(.2);command('scoreboard players set KeeperTest hs.timer 9');time.sleep(1.2)
    check('completed rest applies regeneration','minecraft:regeneration' in command('data get entity KeeperTest active_effects'))
    check('other player not auto-enrolled','hs.enabled' not in command('tag PartnerTest list'))
    action({'action':'chat','text':'/trigger hearth_toggle'});time.sleep(1.2)
    check('campfire opt-out works','hs.enabled' not in command('tag KeeperTest list'))
    command('reload');time.sleep(2)
    check('journal survives reload',has_adv('complete'))
    command('function hearthside:uninstall');command('function fieldcraft:uninstall')
    check('uninstall removes campfire objectives','hs.timer' not in command('scoreboard objectives list'))
finally:
    if bot:
        try:action({'action':'quit'});bot.wait(timeout=5)
        except Exception:bot.kill();bot.wait()
    if server:
        try:server.stdin.write('stop\n');server.stdin.flush();server.wait(timeout=20)
        except Exception:server.kill();server.wait()
    log.close();clientlog.close()
    (ROOT/'verification').mkdir(exist_ok=True)
    (ROOT/'verification/server-results.json').write_text(json.dumps({'minecraft':'1.21.1','java':'21','checks':results,'passed':len(results)>=25 and all(x['passed'] for x in results),'limitations':['No graphical Minecraft client','Recipe output interaction not exercised','Campfire completion timer accelerated after initial real ticks','Full Signalkeepers campaign uses historical report'],'testWorld':'Disposable temporary world; not included'},indent=2)+'\n')
    print('Disposable server stopped. Evidence written.',flush=True)
