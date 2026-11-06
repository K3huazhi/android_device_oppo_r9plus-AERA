# Hardware

## 1. SoC / CPU / GPU

| 项目 | 值 | 证据 |
|---|---|---|
| SoC | Qualcomm MSM8976 (Snapdragon 652) | `/proc/cpuinfo`: `Hardware: Qualcomm Technologies, Inc MSM8976`; `/sys/devices/soc0/soc_id=278` |
| CPU | 8 核，ARMv8-A，64-bit | `/proc/cpuinfo` 8 个 processor，`CPU architecture: 8` |
| 大小核 | 4×Cortex-A72 + 4×Cortex-A53（R9 Plus 规格） | 现代 R9Plus 设备树 README；本机 `/proc/cpuinfo` 只稳定报告 boot CPU 的 part |
| GPU | Adreno 510 | CM BoardConfig `TARGET_BOARD_PLATFORM_GPU := qcom-adreno510`；Lineage 设备树 |
| RAM | 4 GB 标称，Linux 可见 3,701,092 kB | `/proc/meminfo` |
| 存储 | 64 GB eMMC（本机 61,071,360 KiB ≈ 58.2 GiB 可见） | `/proc/partitions` mmcblk0 |
| 外部存储 | microSD，最高 256 GB（规格） | R9Plus 设备树 README；本机检测到 `mmcblk1` |

**注意：** `ro.board.platform=msm8952` 是 Qualcomm 的平台族字段，不等于 SoC 型号。MSM8952 与 MSM8976 共享大量内核/显示代码；本机 `/proc/cpuinfo` 明确写 MSM8976，且现代 R9Plus 设备树使用 `TARGET_BOARD_PLATFORM := msm8952` 作为平台族。不要在文档里把本机写成“Snapdragon 617”。

## 2. Display

| 项目 | 值 | 证据 |
|---|---|---|
| 分辨率 | 1080×1920 | `wm size`; `fb0/modes` |
| 密度 | 480 dpi | `wm density` |
| 面板 | 6.0" AMOLED（规格） | R9Plus 设备树 README |
| Framebuffer | `/dev/graphics/fb0` | AERA fbdev 后端；`/sys/class/graphics/fb0` |
| bpp | 32 | `fb0/bits_per_pixel` |
| stride | 4352 | `fb0/stride` |
| virtual size | 1080×3840（双缓冲） | `fb0/virtual_size` |
| 像素格式 | RGBX_8888（TWRP 基线） | TWRP `BoardConfig.mk` |
| 背光 | `/sys/class/leds/lcd-backlight/brightness`，max 255 | live sysfs + TWRP `TW_BRIGHTNESS_PATH` |
| 旋转 | 0（portrait） | `dumpsys display` |

Modern Lineage recovery 的 init 写的是 `/sys/class/backlight/panel0-backlight/brightness`，但本机 3.10/CM 暴露的是 `lcd-backlight`。AERA 设备树使用 `lcd-backlight`，并在 init 中先写一次；即使 4.9 内核同时提供 `panel0-backlight`，`lcd-backlight` 仍是 TWRP 已验证路径。

## 3. Touch

| 项目 | 值 | 证据 |
|---|---|---|
| 触摸 IC | Synaptics S3508 | `getevent -pl`: `synaptics-s3508` |
| event 节点 | `/dev/input/event1` | `getevent -pl` |
| 协议 | MT-B（ABS_MT_SLOT / TRACKING_ID） | `getevent -pl` |
| X 范围 | 0..1080 | `ABS_MT_POSITION_X` |
| Y 范围 | 0..1920 | `ABS_MT_POSITION_Y` |
| 触点 | 10 slots | `ABS_MT_SLOT max 9` |
| BTN_TOUCH | 有 | `getevent -pl` |
| 虚拟鼠标 | `hbtp_vm` (`/dev/input/event4`) | 必须 blacklist，否则出现鼠标指针 |
| 触摸包装器 | `input_mt_wrapper` (`event0`) | 不作为主触摸设备 |
| 按键 | `synaptics-s3508-kpd` (`event2`) + `gpio-keys` (`event6`) | HOME/MENU/BACK、VOLUME、POWER |

AERA 的 `minuitwrp/events.cpp` 扫描 `/dev/input/event*`，读取 `EVIOCGABS(ABS_MT_POSITION_X/Y)`，支持 MT-B slot。`AERA_INPUT_BLACKLIST := "hbtp_vm"` 已在设备树中设置。

## 4. Buttons / haptics / battery

| 项目 | 值 | 证据 |
|---|---|---|
| Power | `qpnp_pon` (`event5`), KEY_POWER | `getevent -pl` |
| Volume | `gpio-keys` (`event6`), KEY_VOLUMEUP/DOWN | `getevent -pl` |
| Home/Menu/Back | `synaptics-s3508-kpd` (`event2`) | `getevent -pl` |
| 电池 | 4120 mAh（规格），当前 83% | `/sys/class/power_supply/battery/capacity` |
| 振动 | QPNP vibrator（内核驱动） | TWRP 树未启用 AIDL haptics；AERA 暂不启用 |
| LED | red / white / wled / button-backlight | `/sys/class/leds` |

## 5. USB

| 项目 | 值 | 证据 |
|---|---|---|
| 控制器 | `msm_hsusb` | `/sys/class/udc/msm_hsusb`; `sys.usb.controller` |
| 当前配置 | `mtp,adb` | `sys.usb.config` / `persist.sys.usb.config` |
| 当前 ADB | 可用，`2ad9e8ea` | `adb devices -l` |
| 4.9 内核 configfs | 支持（TWRP 基线使用） | TWRP `init.recovery.usb.rc` |

## 6. 传感器 / 其他（非首版重点）

- 指纹：FPC/OPPO 方案（CM 设备树有 `fpc1020`/`oppo.fingerprints`，具体型号 NEEDS VERIFICATION）。
- 摄像头、Wi-Fi、蓝牙、NFC、红外等：首版 recovery 不依赖；后续按 AERA 功能逐项启用。
- 面板型号、触摸 IC 的具体 firmware 版本：**UNKNOWN / NEEDS VERIFICATION**（不影响 fbdev + input 首版）。

## 7. 硬件结论

- 显示/触摸路径是**传统 fbdev + evdev**，不依赖 DRM/KMS/MSM 的现代 HWC。
- 4.9 recovery 内核已经由 LineageOS 22.1 在此硬件上验证过显示、触摸、ADB、存储。
- 因此 Stage 2/3 的硬件风险较低；主要风险在 Android 16 用户空间与镜像尺寸。
