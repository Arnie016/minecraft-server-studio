"""Read-only catalogue operations shared by MCP and tests."""
from pathlib import Path
import hashlib,json,re,zipfile
ROOT=Path(__file__).resolve().parents[1]

def catalog():
    return json.loads((ROOT/'dist/catalog.json').read_text())
def list_packs(query: str='',kind: str='all') -> list[dict]:
    """Search the built catalogue by text and pack type."""
    return [p for p in catalog()['packs'] if (kind=='all' or p['kind']==kind) and query.casefold() in (p['name']+' '+p['description']).casefold()]
def get_pack(pack_id: str) -> dict:
    """Read compatibility, checksum and start commands for a known pack."""
    for pack in catalog()['packs']:
        if pack['id']==pack_id:return pack
    raise ValueError('Unknown pack ID')
def verify_pack(pack_id: str) -> dict:
    """Check a built local archive against the catalogue hash; no identity claim."""
    p=get_pack(pack_id)
    path=ROOT/'dist'/p['filename']
    actual=hashlib.sha256(path.read_bytes()).hexdigest()
    return {'pack':pack_id,'sha256':actual,'matchesCatalog':actual==p['sha256'],'authenticatedPublisher':False,'note':'A checksum proves integrity relative to this catalogue, not publisher identity. Verify a release attestation separately.'}
def installation_plan(pack_ids: list[str],minecraft_version: str='1.21.1') -> dict:
    """Plan installation and include dependencies without writing to a world."""
    if minecraft_version!='1.21.1': raise ValueError('Only Java 1.21.1 is supported by this release.')
    ids=list(dict.fromkeys(pack_ids))
    selected=[get_pack(i) for i in ids]
    for p in list(selected):
        for dep in p['dependencies']:
            if dep not in ids: ids.append(dep);selected.append(get_pack(dep))
    return {'minecraft':minecraft_version,'steps':['Back up your world; use a disposable test world for these alpha packs.','Save and close Minecraft before copying datapacks.','Copy datapack ZIPs into <world>/datapacks. Copy resource-pack ZIPs into resourcepacks and enable them.','Reopen the world. Follow each pack entrypoint.'], 'packs':[{k:p[k] for k in ['id','kind','filename','entrypoint','uninstall','conflicts']} for p in selected],'installsPerformed':False}
