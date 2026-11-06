# Existing recovery baseline

## 1. 设备上已观察到什么

只读拉取的 `/sdcard/TWRP/.twrps`（900 字节）证明这台机器**运行过 TWRP**，并且设置被保存：

| 设置 | 值 |
|---|---|
| `tw_language` | `zh_CN` |
| `tw_backup_list` | `/system;/data;/boot;` |
| `tw_brightness` | 162 |
| `tw_brightness_pct` | 63 |
| `tw_screen_timeout_secs` | 60 |
| `tw_mtp_enabled` | 1 |
| `tw_zip_location` | `/external_sd/14.1...` |
| `tw_time_zone` | `CST6CDT,M3.2.0,M11.1.0` |

这说明：

- 设备曾用 TWRP 备份/刷入 CM14.1；
- 外部 SD 卡路径曾被使用；
- TWRP 的 MTP 曾被启用。

但是 `.twrps` 不含版本号，**不能据此断言当前 recovery 就是某个具体 TWRP 版本**。`ro.recovery_id` 也不能单独作为版本证据。

`/sdcard/TWRP` 下没有备份目录；外部 SD 只有 `Android/` 和 `LOST.DIR/`，没有可直接读取的 boot/recovery 备份。当前 adbd 是 shell，无法 `dd` 分区。因此：

> **当前 recovery 的二进制/版本：UNKNOWN（未直接读取）。**
> **可以确认的是：该设备存在可用的第三方 recovery 使用历史，并且现代 LineageOS 22.1 发布说明明确要求 TWRP 3.7.1_12-Alpha4。**

## 2. 可用的现有 recovery 基线

### 2.1 TWRP 3.7.x 设备树（R9Plus 分支）

来源：<https://codeberg.org/TipzTeam/recovery_device_oppo_thortanium>，分支 `android-12.1`，本地副本：

[`sources/recovery/twrp_thortanium`](../sources/recovery/twrp_thortanium)

R9Plus 配置要点：

```make
TARGET_BOARD_PLATFORM := msm8952
TARGET_BOARD_PLATFORM_GPU := qcom-adreno510
TARGET_BOOTLOADER_BOARD_NAME := MSM8952
TARGET_KERNEL_CONFIG := lineageos_R9Plus_recovery_defconfig
BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb
TARGET_KERNEL_SOURCE := kernel/oppo/msm8937

TW_THEME := portrait_hdpi
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 127
TW_SCREEN_BLANK_ON_BOOT := true
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"
RECOVERY_GRAPHICS_USE_LINELENGTH := true
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_INCLUDE_CRYPTO := true
```

这组配置与 live 设备完全对得上：

- 背光路径 `lcd-backlight`；
- RGBX_8888；
- line length 4352（1080×4 对齐到 1088）；
- 触摸 `hbtp_vm` 虚拟鼠标必须屏蔽。

### 2.2 LineageOS 22.1 recovery（Android 15）

来源：<https://github.com/BlueyfishReleases/R9Plus/releases>，本地镜像：

[`sources/device/r9plus-images/recovery-lineage22.1.img`](../sources/device/r9plus-images/recovery-lineage22.1.img)

这是目前最接近 AERA 16 的**可启动基线**：

- 同一颗 4.9 recovery 内核；
- 同一份 242,901 字节 FDT；
- Android 15 recovery 用户空间；
- 独立 recovery 分区；
- 保留 OPPO 尾部证书；
- 已由设备实际使用（发布说明要求 TWRP 3.7.1_12-Alpha4 刷入）。

AERA 16 可以看作“把 Android 15 recovery 用户空间替换成 AERA 16 + LVGL UI”，内核/DTB/分区/证书路径不变。

### 2.3 CM14.1 的 Android 7.1 recovery（历史基线）

`wuxianlin/android_device_oppo_r9plus` 的 `cm-14.1` 分支：

- `TARGET_RECOVERY_FSTAB := rootdir/etc/fstab.qcom`
- `TARGET_RECOVERY_DEVICE_MODULES := libinit_r9plus`
- `TARGET_RECOVERY_PIXEL_FORMAT` 未显式设置（CM 默认）；
- `BOARD_KERNEL_SEPARATED_DT` 注释掉；
- `TARGET_KERNEL_APPEND_DTB := true`；
- 使用 3.10 CM 内核。

这是“原厂 CM14.1 自带 recovery”的配置，不是 AERA 的直接基线。AERA 16 不应继续用 3.10 内核，因为 Android 16 用户空间对内核的要求更高；4.9 recovery 内核已被 Lineage 22.1 证明可用。

## 3. Recovery 启动链

```
Power + Volume Down / misc 命令
        │
        ▼
OPPO aboot (bootloader)
        │  读取 recovery 分区 mmcblk0p25
        ▼
boot header v0
  ├─ kernel: Image.gz + appended FDT (242901 B)
  ├─ ramdisk: gzip cpio
  └─ trailing: 1280 B OPPO DER certificate
        │
        ▼
Linux 4.9 kernel
  ├─ 初始化 eMMC (7824900.sdhci)
  ├─ 初始化 MDSS / fb0 (1080x1920x32)
  ├─ 初始化 synaptics touch (event1)
  └─ 初始化 USB UDC msm_hsusb
        │
        ▼
ramdisk /init
  ├─ ro.hardware=qcom -> /init.recovery.qcom.rc
  ├─ /dev/block/bootdevice -> /dev/block/platform/soc/7824900.sdhci
  ├─ 启动 recovery 二进制（AERA / TWRP）
  ├─ AERA minui: overlay -> DRM -> fbdev
  └─ adbd + configfs USB
```

## 4. 为什么 AERA 可以直接复用

| 层 | 现有基线 | AERA 是否需要改 |
|---|---|---|
| bootloader | OPPO aboot，v0 image + cert | 不改 |
| 内核 | 4.9 recovery 内核，含 FDT | 直接复用预编译 blob |
| 显示 | fbdev `/dev/graphics/fb0` | AERA 有 fbdev 后端 |
| 触摸 | evdev MT-B `synaptics-s3508` | AERA minuitwrp events 支持 |
| 分区 | 独立 recovery 64 MiB，A-only | 用 `recovery.img` |
| 文件系统 | ext4 system/data/cache，f2fs data | 用 TWRP fstab/flags |
| USB/ADB | configfs + `msm_hsusb` | 用 AERA USB rc |
| 加密 | CM14.1 FDE footer | 首版关闭，后续评估 |

## 5. 不能直接复用的部分

- **TWRP 的 UI/主题/二进制**不能直接放进 AERA；AERA 有自己的 LVGL 原生 UI。
- **TWRP 的 `twrp.flags` 可以复用**，因为它是分区描述，不是 UI。
- **TWRP 的 `recovery.fstab` 可以复用/裁剪**，但必须确认 AERA 16 的 fstab 解析器能读 v1 格式。
- **TWRP 的 `recovery.patch` 不能盲目复用**：它也是 1,280 字节，但证书内容与 Lineage 22.1 的 recovery 证书不完全相同；优先用后者。
- **TWRP 的 3.10 内核配置不能复用**：AERA 16 首版用 4.9 recovery 内核。

## 6. 结论

“这台 R9 Plusm A 现有 TWRP/CWM/OrangeFox 是如何工作的？”的答案是：

> 它使用独立 `recovery` 分区、v0 boot image、4.9 recovery 内核（现代 TWRP/Lineage 基线）、fbdev 显示、evdev MT-B 触摸、configfs USB，并在镜像尾部附加 OPPO 证书。AERA 可以复用除“recovery 用户空间”以外的全部底层路径。

当前 recovery 的确切版本/二进制仍是 **UNKNOWN**；首次设备测试前应通过 TWRP 界面或 `adb shell getprop ro.twrp.version`（在 recovery 中）确认。
