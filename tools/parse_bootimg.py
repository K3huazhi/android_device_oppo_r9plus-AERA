import struct, sys, os, hashlib, gzip, lzma, subprocess

def u32(b, o): return struct.unpack_from('<I', b, o)[0]

def parse(path):
    b = open(path,'rb').read()
    print('='*70)
    print(path, len(b), 'sha256', hashlib.sha256(b).hexdigest())
    print('head', b[:64].hex())
    if b[:8] != b'ANDROID!':
        print('NOT ANDROID BOOT IMAGE'); return
    vals = struct.unpack_from('<8I', b, 8)
    names = ['kernel_size','kernel_addr','ramdisk_size','ramdisk_addr','second_size','second_addr','tags_addr','page_size']
    h = dict(zip(names, vals))
    dt_size = u32(b, 40)
    unused = u32(b, 44)
    name = b[48:64].split(b'\0')[0]
    cmdline = b[64:576].split(b'\0')[0]
    print('header', h)
    print('dt_size', dt_size, 'unused', unused, 'name', name, 'cmdline', cmdline)
    off = h['page_size']
    def align(x): return (x + h['page_size'] - 1) // h['page_size'] * h['page_size']
    k = b[off:off+h['kernel_size']]
    off2 = off + align(h['kernel_size'])
    rd = b[off2:off2+h['ramdisk_size']]
    off3 = off2 + align(h['ramdisk_size'])
    sec = b[off3:off3+h['second_size']]
    off4 = off3 + align(h['second_size'])
    dt = b[off4:off4+dt_size] if dt_size else b''
    end = off4 + align(dt_size) if dt_size else off4 + align(h['second_size'])
    print('offsets kernel', off, 'ramdisk', off2, 'second', off3, 'dt', off4, 'end', end, 'trailing', len(b)-end)
    for label, data in [('kernel',k),('ramdisk',rd),('second',sec),('dt',dt)]:
        if data:
            print(label, len(data), data[:16].hex(), 'tail', data[-16:].hex())
            open(os.path.join(os.path.dirname(path), os.path.basename(path)+'.'+label+'.bin'),'wb').write(data)
    tail = b[end:]
    if tail:
        print('TRAILING first 128', tail[:128].hex())
        print('TRAILING ascii', ''.join(chr(c) if 32<=c<127 else '.' for c in tail[:512]))
    # detect compression
    for label, data in [('kernel',k),('ramdisk',rd)]:
        if data[:2] == b'\x1f\x8b':
            print(label, 'gzip')
            try:
                d = gzip.decompress(data)
                print(label, 'gunzipped', len(d), d[:16].hex())
                open(os.path.join(os.path.dirname(path), os.path.basename(path)+'.'+label+'.gz.bin'),'wb').write(d)
            except Exception as e: print('gunzip failed', e)
        elif data[:4] == b'\x04\x22\x4d\x18':
            print(label, 'lz4')
        elif data[:6] == b'\xfd7zXZ\x00':
            print(label, 'xz')
        elif data[:4] == b'\x02\x21\x4c\x18':
            print(label, 'lz4 legacy')
    if dt:
        print('dt magic', dt[:4].hex(), 'possible qcdt count', u32(dt,4) if len(dt)>=8 else None)

for p in sys.argv[1:]:
    parse(p)
