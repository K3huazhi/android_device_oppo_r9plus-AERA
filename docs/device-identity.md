# Device identity — OPPO R9 Plusm A

## 1. 结论

本项目的目标设备，就是当前通过 ADB 连接的这一台：

| 字段 | 值 | 来源 |
|---|---|---|
| Manufacturer | OPPO | `ro.product.manufacturer` |
| Model（用户写法） | OPPO R9 Plusm A | 用户描述 |
| Model（设备实际报告） | **OPPO R9 Plustm A** | `ro.product.model` |
| Product name | **R9PlustmA** | `ro.product.name` |
| Device | **R9PlusA** | `ro.product.device` |
| CM device codename | **r9plus** | `ro.cm.device` |
| Build fingerprint | `OPPO/R9PlusmA/R9PlusA:5.1.1/LMY47V/1390465867:user/release-keys` | `ro.build.fingerprint` |
| ROM | CyanogenMod 14.1 | `ro.cm.version` |
| CM build | `14.1-20161118-UNOFFICIAL-r9plus` | `ro.cm.version` |
| Android | 7.1 / API 25 | `ro.build.version.release`, `sdk` |
| Kernel（当前系统） | `3.10.84-perf-g00c9d0f` | `uname -a` |
| SoC | Qualcomm **MSM8976** (Snapdragon 652) | `/proc/cpuinfo Hardware`, `soc_id=278` |
| Platform field | `msm8952` | `ro.board.platform` |
| RAM | 3.7 GiB 可见（4 GB 标称） | `/proc/meminfo` |
| Display | 1080×1920，480 dpi | `wm size`, `wm density` |

设备名称存在一个**厂商字符串差异**：设备自身写的是 **“OPPO R9 Plustm A”**，而用户/社区常写 **“OPPO R9 Plusm A”**。两者不是两个型号：`ro.product.name` 是 `R9PlustmA`，`ro.build.fingerprint` 是 `OPPO/R9PlusmA/R9PlusA`，CM codename 是 `r9plus`。本项目统一使用：

- 对外文档名：**OPPO R9 Plusm A**
- 设备树 codename：**`r9plus`**
- 构建 product：**`twrp_r9plus`**
- OTA assert：`r9plus,R9Plus,R9PlusA,R9PlusmA,R9PlustmA`

## 2. 型号隔离（非常重要）

不能因为网页标题写 “R9 Plus” 就认为适用于本机。以下型号必须分开：

| 型号 | 平台 | 本项目是否适用 | 说明 |
|---|---|---|---|
| OPPO R9 | MT6755 (Helio P10) | ❌ | 完全不同平台，不能复用 |
| OPPO R9 Plus | MSM8976 | ⚠️ 仅作为同硬件家族参考 | 需用本机 fingerprint/分区交叉验证 |
| **OPPO R9 Plusm A / R9 Plustm A** | **MSM8976** | ✅ **本项目目标** | `R9PlusA` / `R9PlustmA` / `r9plus` |
| OPPO R9s | MSM8953 | ❌ | 不同 SoC、不同内核 |
| OPPO R9s Plus | MSM8976 | ❌ | 同 SoC 但不同面板/分区/设备树，不能直接套用 |
| 其他 MTK/Qualcomm R9 变体 | 多种 | ❌ | 必须逐项验证 |

本项目的设备树只从以下与 **R9PlusA** 直接相关的来源派生：

- `wuxianlin/android_device_oppo_r9plus`（CM 14.1，`TARGET_OTA_ASSERT_DEVICE` 明确包含 `r9plus,R9Plus,R9PlusA,R9PlusmA`）
- `blueyfish/android_device_oppo_R9Plus`（LineageOS 21/22.1，fingerprint 为 `OPPO/R9PlusmA/R9PlusA`）
- `blueyfish/android_device_oppo_thortanium-common`（同硬件家族 common）
- `TipzTeam/recovery_device_oppo_thortanium` 的 `R9Plus` 分支（TWRP 3.7.x 基线）

## 3. 只读证据

原始输出保存在：

- [`sources/device/live/getprop.txt`](../sources/device/live/getprop.txt)
- [`sources/device/live/proc-full.txt`](../sources/device/live/proc-full.txt)
- [`sources/device/live/by-name.txt`](../sources/device/live/by-name.txt)
- [`sources/device/live/cpu.txt`](../sources/device/live/cpu.txt)
- [`sources/device/live/memory-soc.txt`](../sources/device/live/memory-soc.txt)
- [`sources/device/live/display-input.txt`](../sources/device/live/display-input.txt)
- [`sources/device/live/getevent.txt`](../sources/device/live/getevent.txt)
- [`sources/device/live/fb-detail.txt`](../sources/device/live/fb-detail.txt)

关键命令：

```bash
adb shell getprop
adb shell uname -a
adb shell cat /proc/cpuinfo
adb shell cat /proc/partitions
adb shell ls -l /dev/block/bootdevice/by-name
adb shell wm size
adb shell wm density
adb shell getevent -pl
adb shell cat /sys/class/graphics/fb0/virtual_size
adb shell cat /sys/class/graphics/fb0/bits_per_pixel
```

## 4. 不能从本机直接取得的证据

本机 `adbd` 是 `shell`（uid 2000），`su` 不可用，`/dev/block/mmcblk0p24`、`/proc/cmdline` 均被 SELinux/权限拒绝。因此：

- **没有**从本机 `dd` 出 boot/recovery；
- **没有**读取本机 `/proc/cmdline`；
- **没有**修改 `persist.sys.root_access` 或开启 root。

本项目的 boot/recovery 基线来自公开的 **LineageOS 22.1 R9Plus** 发布镜像，并用其 `boot.img` / `recovery.img` 的 header、kernel、FDT、fstab 与设备树交叉验证。原始镜像在：

- [`sources/device/r9plus-images/boot-lineage22.1.img`](../sources/device/r9plus-images/boot-lineage22.1.img)
- [`sources/device/r9plus-images/recovery-lineage22.1.img`](../sources/device/r9plus-images/recovery-lineage22.1.img)

## 5. 身份判定

```
用户描述: OPPO R9 Plusm A
   │
   ├─ ro.product.model  = OPPO R9 Plustm A   （厂商字符串差异）
   ├─ ro.product.name   = R9PlustmA
   ├─ ro.product.device = R9PlusA
   ├─ ro.cm.device      = r9plus
   ├─ fingerprint       = OPPO/R9PlusmA/R9PlusA:5.1.1/...
   ├─ Hardware          = Qualcomm MSM8976
   ├─ soc_id            = 278
   ├─ board             = MSM8952 (platform family)
   └─ partition table   = mmcblk0, 53 partitions, boot/recovery 64 MiB
```

结论：**目标机 = R9PlusA / R9PlustmA / r9plus，MSM8976，独立 recovery 分区。** 不是 R9、R9s、R9s Plus，也不是 MTK R9。
