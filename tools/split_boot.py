import struct, zlib, os, sys

def split_kernel(path, outprefix):
    b = open(path,'rb').read()
    # header parse as before
    ksize = struct.unpack_from('<I', b, 8)[0]
    rsize = struct.unpack_from('<I', b, 16)[0]
    page = struct.unpack_from('<I', b, 36)[0]
    k = b[page:page+ksize]
    # decompress first gzip member, keep unused
    d = zlib.decompressobj(16 + zlib.MAX_WBITS)
    img = d.decompress(k) + d.flush()
    rest = d.unused_data
    print(path)
    print('gzip member compressed', len(k)-len(rest), 'uncompressed', len(img), 'unused', len(rest))
    open(outprefix+'.Image','wb').write(img)
    open(outprefix+'.dtb','wb').write(rest)
    print('Image head', img[:16].hex(), 'dtb head', rest[:16].hex())
    if rest[:4] == b'\xd0\x0d\xfe\xed':
        totalsize = struct.unpack_from('>I', rest, 4)[0]
        print('FDT totalsize', totalsize, 'rest len', len(rest))
    # ramdisk
    roff = page + (ksize + page - 1)//page*page
    r = b[roff:roff+rsize]
    dr = zlib.decompressobj(16 + zlib.MAX_WBITS)
    ram = dr.decompress(r) + dr.flush()
    print('ramdisk compressed', len(r), 'uncompressed', len(ram), 'unused', len(dr.unused_data))
    open(outprefix+'.ramdisk.cpio','wb').write(ram)
    print('ramdisk head', ram[:16].hex())

for p in sys.argv[1:]:
    split_kernel(p, p+'.unpacked')
