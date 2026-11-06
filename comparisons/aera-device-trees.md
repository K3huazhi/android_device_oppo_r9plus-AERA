# AERA device trees — what to learn, what not to copy

## 1. AERA 官方设备树清单（截至 2026-11）

AERA GitHub 组织下列出了多个设备树，主要包括：

- OnePlus 13 (`dodge`)
- OnePlus 15 (`infiniti`)
- OnePlus 12 (`waffle`)
- OnePlus 10 Pro (`instantnoodlep`)
- OnePlus Ace 系列 (`macan`)
- Xiaomi (`peridot`, `dada`, `garnet`, `myron`, `chiron`)
- OPPO Find X9 Ultra (`lighthouse`)
- realme (`lafa`)
- Nothing (`froggerpro`)
- 以及 `device/qcom/twrp-common`

本项目重点研究了 `dodge`（OnePlus 13）作为“现代 AERA 设备树结构”的样本。

## 2. `dodge` 树的结构

```text
device/oneplus/dodge/
├── Android.bp
├── Android.mk
├── AndroidProducts.mk
├── BoardConfig.mk
├── device.mk
├── twrp_dodge.mk
├── aera_dodge.mk
├── system.prop
├── vendorsetup.sh
├── recovery/root/
│   ├── init.recovery.qcom.rc
│   ├── init.recovery.usb.rc
│   ├── init.recovery.wifi.rc
│   ├── init.recovery.fingerprint.rc
│   └── system/etc/
│       ├── recovery.fstab
│       ├── twrp.flags
│       └── ...
└── ...
```

关键配置：

```make
TARGET_ARCH := arm64
TARGET_BOARD_PLATFORM := sm8750
BOARD_BOOT_HEADER_VERSION := 4
TARGET_PREBUILT_KERNEL := kernel/prebuilts/6.6/arm64/kernel-6.6
BOARD_RAMDISK_USE_LZ4 := true
AB_OTA_UPDATER := true
BOARD_AVB_ENABLE := true
BOARD_USES_METADATA_PARTITION := true
AERA_INCLUDE_CRYPTO_FBE := true
AERA_USE_FSCRYPT_POLICY := 2
AERA_INCLUDE_FASTBOOTD := true
AERA_UI_ADAPTIVE_RESOLUTION := true
```

## 3. 可以学习的部分

| 结构/做法 | 对 R9 的启发 |
|---|---|
| `twrp_<device>.mk` + `AndroidProducts.mk` | 直接用 |
| `aera_<device>.mk` 分离 AERA 选项 | 直接用 |
| `recovery/root/system/etc/recovery.fstab` | 直接用 |
| `twrp.flags` | 直接用 |
| `init.recovery.qcom.rc` / `init.recovery.usb.rc` | 用模板，改 UDC/VID/PID |
| `AERA_*` 配置命名 | 直接用 |
| 预编译 kernel 路径 | 改成 `prebuilt/Image.gz-dtb` |
| `AERA_INPUT_BLACKLIST` | 本机 `hbtp_vm` |

## 4. 不能复制的部分

| dodge 配置 | 为什么不能用于 R9 |
|---|---|
| `sm8750` / Adreno 830 | R9 是 MSM8976 / Adreno 510 |
| GKI 6.6 + `vendor_boot` | R9 是 v0 boot + 独立 recovery |
| A/B + dynamic partitions | R9 是 A-only，无 super |
| AVB / vbmeta | R9 无 vbmeta，使用 OPPO 尾部证书 |
| FBE / metadata | R9 CM14.1 是 FDE footer |
| `panel0-backlight` | R9 是 `lcd-backlight` |
| AIDL vibrator/touch | R9 是 evdev + 旧 QSEE |
| `AERA_UI_ADAPTIVE_RESOLUTION` | R9 是固定 1080×1920，可先关闭 |
| LZ4 ramdisk | R9 recovery 内核未启用 `CONFIG_RD_LZ4` |

## 5. AERA 设备树命名惯例

- 设备树仓库：`android_device_<vendor>_<codename>-AERA`
- 路径：`device/<vendor>/<codename>`
- 产品：`twrp_<codename>.mk`
- lunch：`twrp_<codename>-<release>-eng`
- 配置前缀：`AERA_*`

本项目采用：

```text
android_device_oppo_r9plus-AERA
device/oppo/r9plus
twrp_r9plus.mk
lunch twrp_r9plus-bp2a-eng
```

## 6. 结论

AERA 的现代设备树是**结构参考**，不是硬件参考。R9 的硬件参数必须来自 R9Plus 的 CM14.1 / Lineage 22.1 / TWRP 树和 live 设备。任何把 `dodge` 的 SoC/分区/加密/显示配置直接复制到 R9 的做法都会导致不可启动。
