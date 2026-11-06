# Sources

Snapshots used by the R9 Plusm A AERA port.

| Directory | Content |
|---|---|
| `live/` | Read-only ADB/sysfs evidence from the connected device |
| `aera/` | AERA manifest layers and manifest README |
| `device/cm14.1/` | Key files from the CM14.1 R9Plus device tree |
| `device/lineage21/R9Plus/` | LineageOS 21/22.1 R9Plus device tree snapshot |
| `device/lineage21/thortanium-common/` | LineageOS common tree snapshot |
| `recovery/twrp_thortanium/` | TWRP 3.7.x R9Plus baseline tree |
| `kernel/` | Linux 4.9.337 recovery defconfig and version |
| `other/` | Public LineageOS 22.1 release metadata and hashes |

Large boot/recovery images and the full AOSP checkout are intentionally not
committed. The extracted kernel/FDT and OPPO certificate used by the build are
under `device/oppo/r9plus/prebuilt/`.

The original release images can be re-downloaded from:

- <https://github.com/BlueyfishReleases/R9Plus>

Hashes and extraction results are in `other/lineage-r9plus-release.md`.
