"""Verify a release ZIP against a separately obtained trusted SHA-256 value."""
import argparse,hashlib,hmac
p=argparse.ArgumentParser();p.add_argument('file');p.add_argument('--sha256',required=True);a=p.parse_args()
if len(a.sha256)!=64 or any(c not in '0123456789abcdefABCDEF' for c in a.sha256):p.error('Expected 64 hexadecimal characters')
h=hashlib.sha256()
with open(a.file,'rb') as f:
    for chunk in iter(lambda:f.read(1024*1024),b''):h.update(chunk)
if not hmac.compare_digest(h.hexdigest(),a.sha256.lower()):raise SystemExit('FAILED: checksum mismatch')
print('Checksum matches. Publisher identity still requires a trusted source or verified attestation.')
