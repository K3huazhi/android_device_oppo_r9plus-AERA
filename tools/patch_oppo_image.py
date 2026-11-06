#!/usr/bin/env python3
"""
Append/replace the OPPO boot certificate on a legacy (header v0) recovery.img.

The R9 Plusm A bootloader accepts the image produced by the stock/Lineage
mkbootimg plus a 1276-byte DER certificate appended after the ramdisk.  This
script deliberately does not touch the Android boot header, kernel, FDT, or
ramdisk; it only replaces the bytes after the last packed section.

Usage:
  python3 patch_oppo_image.py <recovery.img> <oppo_boot.patch> [--partition-size N]
"""
import argparse
import hashlib
import os
import struct
import sys
import tempfile


def align(value, page):
    return (value + page - 1) // page * page


def image_end(data):
    if data[:8] != b"ANDROID!":
        raise ValueError("not an Android boot image (missing ANDROID! magic)")
    kernel_size = struct.unpack_from("<I", data, 8)[0]
    ramdisk_size = struct.unpack_from("<I", data, 16)[0]
    second_size = struct.unpack_from("<I", data, 24)[0]
    page_size = struct.unpack_from("<I", data, 36)[0]
    dt_size = struct.unpack_from("<I", data, 40)[0]
    if page_size not in (2048, 4096, 8192, 16384, 32768, 65536, 131072):
        raise ValueError(f"implausible page size: {page_size}")
    end = page_size
    end += align(kernel_size, page_size)
    end += align(ramdisk_size, page_size)
    end += align(second_size, page_size)
    if dt_size:
        end += align(dt_size, page_size)
    return end, {
        "kernel_size": kernel_size,
        "ramdisk_size": ramdisk_size,
        "second_size": second_size,
        "page_size": page_size,
        "dt_size": dt_size,
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("image")
    ap.add_argument("patch")
    ap.add_argument("--partition-size", type=int, default=67108864)
    args = ap.parse_args()

    data = open(args.image, "rb").read()
    patch = open(args.patch, "rb").read()
    if not patch:
        raise SystemExit("empty OPPO patch")

    end, hdr = image_end(data)
    if end > len(data):
        raise SystemExit(f"image is truncated: header end {end} > file size {len(data)}")
    core = data[:end]
    out = core + patch

    print(f"header: {hdr}")
    print(f"core:   {len(core)} bytes")
    print(f"patch:  {len(patch)} bytes")
    print(f"output: {len(out)} bytes / partition {args.partition_size} bytes")
    if len(out) > args.partition_size:
        raise SystemExit("output exceeds recovery partition size")

    fd, tmp = tempfile.mkstemp(dir=os.path.dirname(os.path.abspath(args.image)),
                               prefix=".oppo-patch-", suffix=".img")
    try:
        with os.fdopen(fd, "wb") as f:
            f.write(out)
        os.replace(tmp, args.image)
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)

    print("sha256:", hashlib.sha256(out).hexdigest())
    print("OK")


if __name__ == "__main__":
    sys.exit(main())
