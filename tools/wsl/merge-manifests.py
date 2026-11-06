#!/usr/bin/env python3
import re
from pathlib import Path
base = Path('/root/aosp/.repo/manifests')
out = ['<?xml version="1.0" encoding="UTF-8"?>', '<manifest>']
for name in ['default.xml', 'twrp-default.xml', 'aera.xml', 'remove-minimal.xml']:
    text = (base / name).read_text()
    text = re.sub(r'<\?xml[^>]*\?>', '', text)
    text = re.sub(r'<manifest[^>]*>', '', text)
    text = text.replace('</manifest>', '')
    text = re.sub(r'<include\s+name="[^"]+"\s*/>', '', text)
    out.append(f'<!-- ===== {name} ===== -->')
    out.append(text)
out.append('</manifest>')
path = Path('/root/aosp/.repo/manifests/merged.xml')
path.write_text('\n'.join(out))
print(path, path.stat().st_size)
