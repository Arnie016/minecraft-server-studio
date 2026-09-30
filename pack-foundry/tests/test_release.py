import hashlib,json,subprocess,sys,tempfile,unittest,zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from catalog_api import catalog,get_pack,list_packs,verify_pack,installation_plan
class ReleaseTests(unittest.TestCase):
    def test_archive_integrity_and_provenance(self):
        for p in catalog()['packs']:
            with self.subTest(pack=p['id']):
                self.assertTrue(verify_pack(p['id'])['matchesCatalog'])
                with zipfile.ZipFile(ROOT/'dist'/p['filename']) as z:
                    self.assertIsNone(z.testzip());self.assertIn('pack.mcmeta',z.namelist())
                    self.assertTrue(all(not n.startswith('/') and '..' not in Path(n).parts for n in z.namelist()))
                    provenance=json.loads(z.read('ASHFALL-PROVENANCE.json'))
                    self.assertEqual(provenance['publisher'],'Arnie016')
                    for name,sha in provenance['files'].items():self.assertEqual(hashlib.sha256(z.read(name)).hexdigest(),sha)
                    for name in z.namelist():
                        if name.endswith(('.json','.mcmeta')):json.loads(z.read(name))
    def test_reproducibility(self):
        before=(ROOT/'dist/SHA256SUMS').read_bytes()
        subprocess.run([sys.executable,str(ROOT/'tools/build.py')],check=True,stdout=subprocess.DEVNULL)
        self.assertEqual(before,(ROOT/'dist/SHA256SUMS').read_bytes())
    def test_broken_hash_detected(self):
        p=get_pack('fieldcraft');path=ROOT/'dist'/p['filename'];original=path.read_bytes()
        try:
            path.write_bytes(original+b'tampered')
            self.assertFalse(verify_pack('fieldcraft')['matchesCatalog'])
        finally:path.write_bytes(original)
    def test_selection_and_dependencies(self):
        self.assertEqual(len(list_packs(kind='resourcepack')),1)
        self.assertEqual(list_packs('compass')[0]['id'],'trail-ledger')
        plan=installation_plan(['signalkeepers-models'])
        self.assertEqual({p['id'] for p in plan['packs']},{'signalkeepers','signalkeepers-models'})
        self.assertFalse(plan['installsPerformed'])
        with self.assertRaises(ValueError):installation_plan(['fieldcraft'],'1.21.2')
        with self.assertRaises(ValueError):get_pack('../../secret')
    def test_local_function_links(self):
        import re
        for p in catalog()['packs']:
            folder=ROOT/p['source']
            for f in folder.rglob('*.mcfunction'):
                for ns,name in re.findall(r'\bfunction ([a-z0-9_]+):([a-z0-9_/]+)',f.read_text()):
                    if ns!='minecraft':self.assertTrue((folder/f'data/{ns}/function/{name}.mcfunction').exists(),str(f)+' -> '+ns+':'+name)
    def test_bundle_contains_exact_archives(self):
        with zipfile.ZipFile(ROOT/'dist'/catalog()['bundle']['filename']) as z:
            for p in catalog()['packs']:self.assertEqual(z.read(p['filename']),(ROOT/'dist'/p['filename']).read_bytes())
if __name__=='__main__':unittest.main()
