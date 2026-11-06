# AERA Recovery for OPPO R9 Plusm A (`r9plus`)

**AERA Recovery bring-up research + device tree for the OPPO R9 Plusm A / R9PlustmA (`R9PlusA`, MSM8976).**

- Repository: <https://github.com/K3huazhi/android_device_oppo_r9plus-AERA>
- Research snapshot: <https://github.com/K3huazhi/android_device_oppo_r9plus-AERA/releases/tag/v0.1-research>
- 中文说明: [`README.zh-CN.md`](README.zh-CN.md)

> Current verdict: **PARTIALLY FEASIBLE** — the device identity, partition map, boot format, kernel/FDT, display/touch/USB paths, and OPPO certificate are verified and the device tree passes static validation. A complete AOSP 16 build was **not** finished on the 16 GB build host, so no bootable `recovery.img` is included. This is a build-host limitation, not a proven R9 hardware blocker.

---

## 1. Target identity is locked

This repository is **not** for the OPPO R9 (MT6755), R9 Plus in general, R9s, R9s Plus, or any other R9 variant.

| Field | Verified value |
|---|---|
| Marketing name | OPPO R9 Plusm A |
| Device-reported model | `OPPO R9 Plustm A` (vendor string) |
| Product | `R9PlustmA` |
| Device | `R9PlusA` |
| CM codename | `r9plus` |
| Fingerprint | `OPPO/R9PlusmA/R9PlusA:5.1.1/LMY47V/1390465867:user/release-keys` |
| SoC | Qualcomm **MSM8976** (Snapdragon 652), Adreno 510 |
| Current ROM | CyanogenMod 14.1, Android 7.1, API 25 |
| Display | 1080×1920, 480 dpi |
| Partition scheme | A-only, **independent 64 MiB recovery** |

Evidence: [`docs/device-identity.md`](docs/device-identity.md), [`sources/live/getprop.txt`](sources/live/getprop.txt).

---

## 2. What is verified

| Item | Result | Evidence |
|---|---|---|
| Independent `recovery` partition | ✅ `mmcblk0p25`, 64 MiB | [`docs/partition-layout.md`](docs/partition-layout.md) |
| A/B / dynamic partitions | ❌ none; A-only | same |
| boot/recovery header | v0, page size 2048 | [`docs/boot-recovery-layout.md`](docs/boot-recovery-layout.md) |
| Kernel format | `Image.gz` + appended FDT (242,901 B) | same |
| OPPO certificate | 1,280 B DER at end of recovery.img | same |
| Recovery kernel | Linux 4.9.337, reused from LineageOS 22.1 | [`docs/kernel.md`](docs/kernel.md) |
| Display | fbdev `/dev/graphics/fb0`, RGBX_8888, stride 4352 | [`docs/display.md`](docs/display.md) |
| Touch | `synaptics-s3508`, MT-B, 1080×1920 | [`docs/touch.md`](docs/touch.md) |
| ADB/USB | configfs + FunctionFS, UDC `msm_hsusb` | [`docs/adb-usb.md`](docs/adb-usb.md) |
| Storage | ext4 system/data/cache, f2fs data, SD/OTG | [`docs/storage.md`](docs/storage.md) |
| Encryption | CM14.1 FDE footer, not FBE | [`docs/encryption.md`](docs/encryption.md) |
| Device tree static check | **38/38 pass** | [`conclusions/static-validation.txt`](conclusions/static-validation.txt) |

The kernel/FDT blob and OPPO certificate are included under [`device/oppo/r9plus/prebuilt/`](device/oppo/r9plus/prebuilt).

---

## 3. Research approach

This project deliberately works as an evidence chain, not as a copy of another device tree.

### Step 1 — Lock the exact device

Read-only ADB only: `getprop`, `/proc/cpuinfo`, `/proc/partitions`, `/dev/block/bootdevice/by-name`, `wm size`, `getevent -pl`, `sysfs` framebuffer and backlight. The running device reports `R9PlusA` / `R9PlustmA` / `r9plus`, with an MSM8976 and a 1080×1920 panel. The model string “OPPO R9 Plustm A” is a vendor spelling variant of the requested R9 Plusm A; the fingerprint disambiguates it.

### Step 2 — Build the partition model from the live device

The live `/proc/partitions` and `by-name` links were cross-checked against the CM14.1 device tree `partition.txt`. This established:

- `boot = mmcblk0p24`, `recovery = mmcblk0p25`, both 64 MiB;
- `system` 2 GiB ext4, `cache` 128 MiB, `userdata` ~55.2 GiB;
- no `vendor`, `metadata`, `dtbo`, `super`, `vbmeta`;
- `reserve2` is used as `/metadata` only by modern LineageOS, not by CM14.1.

### Step 3 — Reverse the boot image instead of assuming a format

The project obtained the public LineageOS 22.1 R9Plus `boot.img` / `recovery.img`, parsed the v0 headers, split the gzip member from the appended FDT, and checked the OPPO tail:

- recovery kernel blob: 10,561,222 B;
- gzip Image: 10,318,321 B;
- FDT: 242,901 B (`d00dfeed`, totalsize matches);
- trailing OPPO certificate: 1,280 B (`30 82 04 fc ...`).

The included `tools/patch_oppo_image.py` reproduces the original Lineage recovery image byte-for-byte when given the extracted certificate.

### Step 4 — Establish a working recovery baseline

Two independent baselines were used:

- TWRP 3.7.x R9Plus device tree (fstab, twrp.flags, brightness, pixel format, touch blacklist);
- LineageOS 22.1 recovery (4.9 kernel, FDT, OPPO certificate, actual boot on the same hardware).

This avoids guessing display/touch/partition details.

### Step 5 — Map modern AERA onto a legacy device

AERA `aera-16.0` is Android 16 + LVGL, with TWRP/OrangeFox ancestry. The port keeps AERA core untouched and puts every hardware difference in the device tree:

- v0 boot image instead of GKI/vendor_boot;
- independent recovery instead of A/B;
- fbdev instead of DRM;
- evdev MT-B touch;
- configfs ADB with `msm_hsusb`;
- FDE disabled for the first boot;
- 4.9 prebuilt recovery kernel.

### Step 6 — Build and statically validate, then bring up in stages

`lunch twrp_r9plus-bp2a-eng` succeeds. Static checks validate the device tree, kernel/FDT, fstab/flags, and OPPO certificate. Device writes remain prohibited until explicit authorization and a backup/rollback path exist.

See [`docs/bringup.md`](docs/bringup.md) for the staged plan.

---

## 4. Why no `recovery.img` in this repo

The AOSP 16 Soong analysis exhausted the 13.6 GB WSL limit plus 12–15 GB swap on the build host and did not complete. Pruning non-recovery AOSP modules is not a supported workaround: it produces missing `aconfig_declarations` panics and a `Connectivity` ↔ `cronet` dependency cycle.

A full log is in [`conclusions/build-attempt.md`](conclusions/build-attempt.md).

To finish on a suitable host (≥64 GB RAM recommended):

```bash
source build/envsetup.sh
lunch twrp_r9plus-bp2a-eng
mka -j16 adbd recoveryimage

python3 tools/patch_oppo_image.py \
  out/target/product/r9plus/recovery.img \
  device/oppo/r9plus/prebuilt/oppo_boot.patch

python3 tools/static_check.py
python3 tools/parse_bootimg.py out/target/product/r9plus/recovery.img
```

Expected output: `recovery.img`, header v0, kernel ≈10.56 MiB, page 2048, gzip ramdisk, 1,280 B certificate, ≤64 MiB.

---

## 5. Repository layout

```text
device/oppo/r9plus/       AERA device tree + prebuilt kernel + OPPO certificate
docs/                     evidence and design documents
comparisons/              AERA vs TWRP, device trees, recovery options
conclusions/              feasibility, risks, build log, static validation
sources/live/             read-only ADB/sysfs evidence from the device
sources/aera/             AERA manifest snapshots
sources/device/           CM14.1 / LineageOS 22.1 device tree snapshots
sources/recovery/         TWRP R9Plus baseline tree
sources/kernel/           4.9.337 recovery defconfig + version
sources/other/            public release metadata and hashes
tools/                    image parser, OPPO patcher, static checker, WSL helpers
```

---

## 6. Key source references

- AERA Recovery: <https://github.com/AERA-Recovery/android_bootable_recovery> (branch `aera-16.0`)
- AERA project site: <https://aera-recovery.com/>
- LineageOS 22.1 R9Plus release: <https://github.com/BlueyfishReleases/R9Plus>
- TWRP R9Plus baseline: <https://codeberg.org/TipzTeam/recovery_device_oppo_thortanium>
- CM14.1 R9Plus tree: <https://github.com/wuxianlin/android_device_oppo_r9plus>
- LineageOS 21/22.1 R9Plus tree: <https://github.com/blueyfish/android_device_oppo_R9Plus>
- Kernel source: <https://github.com/blueyfish/android_kernel_oppo_msm8937> (branch `lineage-22.1`)

Third-party attribution is in [`NOTICE`](NOTICE).

---

## 7. Safety

No device write was performed during this research:

- no `fastboot flash`, `erase`, `format`, `reboot`;
- no modification of boot/recovery/system/userdata/GPT;
- no root enabling or `persist` changes.

The device tree is ready for the next phase, but **flashing requires a verified backup, a rollback path, and explicit user authorization**. See [`docs/bringup.md`](docs/bringup.md).

---

## 8. License

GPL-3.0-or-later. See [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE).
