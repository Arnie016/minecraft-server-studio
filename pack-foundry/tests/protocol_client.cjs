// Two offline protocol clients for an isolated localhost integration world.
// No Microsoft account or credentials are used.
const mc = require('minecraft-protocol');
const readline = require('node:readline');
const clients = {};
const port = Number(process.argv[2] || 25574);
for (const username of ['KeeperTest', 'PartnerTest']) {
  const c = mc.createClient({host:'127.0.0.1', port, username, auth:'offline', version:'1.21.1'});
  clients[username] = c;
  c.on('login', p => { c.entityId = p.entityId; console.log(JSON.stringify({event:'login', username})); });
  c.on('position', p => {
    c.pos = p;
    c.write('teleport_confirm', {teleportId:p.teleportId});
    c.write('position_look', {x:p.x,y:p.y,z:p.z,yaw:p.yaw,pitch:p.pitch,onGround:true});
  });
  c.on('error', e => console.log(JSON.stringify({event:'error',username,error:e.message})));
  c.on('system_chat', p => {
    const text=JSON.stringify(p);
    if (text.includes('QUIET ENDING') || text.includes('STORM ENDING')) console.log(JSON.stringify({event:'ending',username,message:text}));
  });
  c.on('end', reason => console.log(JSON.stringify({event:'end',username,reason})));
}
readline.createInterface({input:process.stdin}).on('line', line => {
  try {
    const p=JSON.parse(line), c=clients[p.player || 'KeeperTest'];
    if (p.action==='chat') c.chat(p.text);
    if (p.action==='crouch') c.write('entity_action',{entityId:c.entityId,actionId:p.value?'start_sneaking':'stop_sneaking',jumpBoost:0});
    if (p.action==='use') c.write('use_item',{hand:0,sequence:0,rotation:{x:c.pos?.yaw||0,y:c.pos?.pitch||0}});
    if (p.action==='quit') { for (const client of Object.values(clients)) client.end(); setTimeout(()=>process.exit(0),100); }
    console.log(JSON.stringify({event:'sent',action:p.action}));
  } catch (e) { console.log(JSON.stringify({event:'error',error:e.message})); }
});
