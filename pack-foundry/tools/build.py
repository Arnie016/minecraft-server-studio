"""Deterministic packs + public catalogue. Standard library only."""
from pathlib import Path
import hashlib, json, shutil, subprocess, sys, zipfile
ROOT=Path(__file__).resolve().parents[1]
STAMP=(2026,1,1,0,0,0)

def digest(data): return hashlib.sha256(data).hexdigest()
def archive(target, entries):
    with zipfile.ZipFile(target,'w') as z:
        for name,data in sorted(entries.items()):
            item=zipfile.ZipInfo(name,STAMP)
            item.compress_type=zipfile.ZIP_DEFLATED
            item.external_attr=0o100644 << 16
            z.writestr(item,data)
def main():
    subprocess.run([sys.executable,str(ROOT/'tools/generate.py')],check=True)
    subprocess.run([sys.executable,str(ROOT/'packs/signalkeepers/tools/build.py')],check=True)
    cat=json.loads((ROOT/'catalog.source.json').read_text())
    out=ROOT/'dist'; site=ROOT/'site'
    out.mkdir(exist_ok=True)
    # Only our generated outputs are removed. Sources and user files are never traversed.
    for p in out.glob('*.zip'): p.unlink()
    for pack in cat['packs']:
        folder=ROOT/pack['source']
        entries={p.relative_to(folder).as_posix():p.read_bytes() for p in folder.rglob('*') if p.is_file()}
        pack['version']=cat['version']
        pack['filename']=f"{pack['id']}-{cat['version']}-java-{cat['minecraft']}.zip"
        pack['url']='downloads/'+pack['filename']
        provenance={k:cat[k] for k in ['publisher','repository','version','minecraft','edition','license','aiDisclosure']}
        provenance.update({'pack':pack['id'],'files':{k:digest(v) for k,v in sorted(entries.items())},'authentication':'Metadata is a claim, not a signature. Verify GitHub build attestations when available.'})
        entries['ASHFALL-PROVENANCE.json']=(json.dumps(provenance,sort_keys=True,indent=2)+'\n').encode()
        entries['LICENSE.txt']=(ROOT/'LICENSE').read_bytes()
        entries['INSTALL.txt']=(f"{pack['name']} — {cat['version']}\nMinecraft Java {cat['minecraft']} only.\n"+('Copy ZIP into your world/datapacks folder while the world is closed.\n' if pack['kind']=='datapack' else 'Copy ZIP into resourcepacks and enable it in Options.\n')+f"Start: {pack['entrypoint']}\nRemove: {pack['uninstall']}\nLimits: {pack['conflicts']}\nStatus: {pack['status']}\nPublisher: {cat['publisher']}\nSource: {cat['repository']}\n").encode()
        archive(out/pack['filename'],entries)
        raw=(out/pack['filename']).read_bytes()
        pack['sha256']=digest(raw); pack['bytes']=len(raw)
    bundle_name=f"ashfall-workshop-{cat['version']}-java-{cat['minecraft']}-bundle.zip"
    archive(out/bundle_name,{**{p['filename']:(out/p['filename']).read_bytes() for p in cat['packs']},'READ-ME-FIRST.txt':b'Extract this bundle first. Install each contained pack ZIP separately. All packs are alpha; use a test world. Field Instruments is optional. Java 1.21.1 only.\n'})
    raw=(out/bundle_name).read_bytes()
    cat['bundle']={'filename':bundle_name,'url':'downloads/'+bundle_name,'sha256':digest(raw),'bytes':len(raw)}
    cat['authentication']={'status':'checksummed','note':'Local builds are unsigned. GitHub release workflow generates provenance attestations; check the release before trusting origin.'}
    text=json.dumps(cat,indent=2,ensure_ascii=False)+'\n'
    (out/'catalog.json').write_text(text)
    sums=''.join(f"{p['sha256']}  {p['filename']}\n" for p in [*cat['packs'],cat['bundle']])
    (out/'SHA256SUMS').write_text(sums)
    if site.exists(): shutil.rmtree(site)
    shutil.copytree(ROOT/'web',site)
    shutil.copytree(out,site/'downloads')
    (site/'catalog.json').write_text(text)
    (site/'.nojekyll').write_text('')
    print(f"Built {len(cat['packs'])} packs + bundle; catalogue at {site}")
if __name__=='__main__': main()
