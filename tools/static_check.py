#!/usr/bin/env python3
"""Static validation of the AERA R9Plus device tree (no device access)."""
import hashlib
import os
import struct
import sys
import zlib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEV = os.path.join(ROOT, "device", "oppo", "r9plus")
FAIL = []
OK = []


def check(cond, msg):
    (OK if cond else FAIL).append(msg)


def sha(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


required = [
    "AndroidProducts.mk", "BoardConfig.mk", "device.mk", "twrp_r9plus.mk",
    "aera_r9plus.mk", "prebuilt/Image.gz-dtb", "prebuilt/oppo_boot.patch",
    "recovery/root/init.recovery.qcom.rc",
    "recovery/root/init.recovery.usb.rc",
    "recovery/root/ueventd.qcom.rc",
    "recovery/root/system/etc/recovery.fstab",
    "recovery/root/system/etc/twrp.flags",
    "recovery/root/system/usr/keylayout/gpio-keys.kl",
]
for rel in required:
    check(os.path.isfile(os.path.join(DEV, rel)), f"exists: {rel}")

board = open(os.path.join(DEV, "BoardConfig.mk"), encoding="utf-8").read()
for token in [
    "TARGET_BOARD_PLATFORM := msm8952",
    "BOARD_BOOT_HEADER_VERSION := 0",
    "BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864",
    "BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb",
    "TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image.gz-dtb",
    "WITH_DEXPREOPT := false",
    "AERA_BRIGHTNESS_PATH := \"/sys/class/leds/lcd-backlight/brightness\"",
    "AERA_INPUT_BLACKLIST := \"hbtp_vm\"",
]:
    check(token in board, f"BoardConfig contains: {token}")

fstab = open(os.path.join(DEV, "recovery/root/system/etc/recovery.fstab"), encoding="utf-8").read()
for token in ["/boot", "/recovery", "/data", "/metadata", "encryptable=footer"]:
    check(token in fstab, f"recovery.fstab contains: {token}")

flags = open(os.path.join(DEV, "recovery/root/system/etc/twrp.flags"), encoding="utf-8").read()
for token in ["/system_root", "/cache", "/boot", "/recovery", "/data", "LOGO"]:
    check(token in flags, f"twrp.flags contains: {token}")

kpath = os.path.join(DEV, "prebuilt/Image.gz-dtb")
k = open(kpath, "rb").read()
check(k[:2] == b"\x1f\x8b", "kernel starts with gzip magic")
d = zlib.decompressobj(16 + zlib.MAX_WBITS)
img = d.decompress(k) + d.flush()
rest = d.unused_data
check(len(img) > 10_000_000, f"gunzipped Image size = {len(img)}")
check(rest[:4] == b"\xd0\x0d\xfe\xed", "appended data starts with FDT magic")
if rest[:4] == b"\xd0\x0d\xfe\xed":
    check(struct.unpack_from(">I", rest, 4)[0] == len(rest), "FDT totalsize matches trailing length")

patch = open(os.path.join(DEV, "prebuilt/oppo_boot.patch"), "rb").read()
check(len(patch) == 1280, f"OPPO recovery patch length = {len(patch)}")
check(patch[:4] == b"\x30\x82\x04\xfc", "OPPO recovery patch starts with DER 30 82 04 fc")

print("PASS")
for m in OK:
    print("  [ok]", m)
if FAIL:
    print("FAIL")
    for m in FAIL:
        print("  [FAIL]", m)
print("\nartifacts:")
for rel in ["prebuilt/Image.gz-dtb", "prebuilt/oppo_boot.patch"]:
    p = os.path.join(DEV, rel)
    if os.path.exists(p):
        print(f"  {rel}: {os.path.getsize(p)} bytes  sha256={sha(p)}")
print(f"\nresult: {'PASS' if not FAIL else 'FAIL'} ({len(OK)} checks, {len(FAIL)} failures)")
sys.exit(0 if not FAIL else 1)
