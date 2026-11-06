# Boot / recovery image layout

## 1. 结论

R9 Plusm A 使用 **Qualcomm legacy boot image header v0**，不是 GKI `boot.img` / `vendor_boot.img`，也不是 A/B。

AERA 最终产物应为：

```
recovery.img   (header v0 + Image.gz-dtb + gzip ramdisk + appended OPPO certificate)
```

写入 `recovery` 分区（`mmcblk0p25`，64 MiB）。

## 2. 实测 header（LineageOS 22.1 R9Plus 发布镜像）

### boot.img

| 字段 | 值 |
|---|---|
| 文件大小 | 15,803,644 bytes |
| magic | `ANDROID!` |
| kernel_size | 12,503,301 |
| kernel_addr | `0x80008000` |
| ramdisk_size | 3,293,633 |
| ramdisk_addr | `0x81000000` |
| second_size | 0 |
| tags_addr | `0x80000100` |
| page_size | 2048 |
| dt_size | 0 |
| name | 空 |
| cmdline | `androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 androidboot.bootdevice=7824900.sdhci loop.max_part=7 androidboot.init_fatal_reboot_target=recovery androidboot.boot_devices=soc/7824900.sdhci` |
| trailing | 1,276 bytes DER certificate |

### recovery.img

| 字段 | 值 |
|---|---|
| 文件大小 | 23,981,312 bytes |
| magic | `ANDROID!` |
| kernel_size | 10,561,222 |
| kernel_addr | `0x80008000` |
| ramdisk_size | 13,415,525 |
| ramdisk_addr | `0x81000000` |
| second_size | 0 |
| tags_addr | `0x80000100` |
| page_size | 2048 |
| dt_size | 0 |
| trailing | 1,280 bytes DER certificate |

## 3. kernel / DTB

kernel blob 不是纯 gzip：

```
[ gzip-compressed Image ][ uncompressed FDT ]
```

| 镜像 | gzip 部分 | FDT | 合计 |
|---|---:|---:|---:|
| boot.img | 12,260,400 | 242,901 | 12,503,301 |
| recovery.img | 10,318,321 | 242,901 | 10,561,222 |

FDT 头为 `d0 0d fe ed`，`totalsize=242901`。两个镜像的 FDT 完全相同（同一份 242,901 字节 DTB）。

因此：

- 不能设置 `BOARD_KERNEL_SEPARATED_DT := true`；
- 不能让构建系统再跑 `dtbTool`，否则会追加第二份 DT；
- 直接把 `Image.gz-dtb` 作为 `TARGET_PREBUILT_KERNEL`，由 `mkbootimg` 原样打包。

## 4. ramdisk

| 镜像 | 压缩大小 | 解压大小 | 格式 |
|---|---:|---:|---|
| boot.img | 3,293,633 | 7,006,464 | gzip + cpio newc |
| recovery.img | 13,415,525 | 30,708,992 | gzip + cpio newc |

recovery ramdisk 是 Lineage recovery（Android 15）的 30.7 MiB 用户空间。AERA 的 ramdisk 预计更大（LVGL UI、字体、工具、库），必须确保压缩后 + 10.56 MiB 内核 + 1.3 KiB 证书 ≤ 64 MiB。

**当前估算：** 64 MiB - 10.56 MiB ≈ 53.4 MiB 可用于压缩 ramdisk。AERA 在 100 MiB 分区设备上通常能控制在 30–50 MiB；本项目需要实际构建后测量。若超过，需裁剪 AERA 功能/资源或压缩 ramdisk（lz4），但内核必须支持对应解压算法。

## 5. OPPO 尾部证书

两个发布镜像末尾都有 DER 证书，但长度不同：

- boot.img：**1,276 字节**，开头 `30 82 04 f8 02 01 01 30 82 03 d1 ...`
- recovery.img：**1,280 字节**，开头 `30 82 04 fc 02 01 01 30 82 03 d1 ...`

证书主体包含：

- `CN=Guangdong`
- `ST=Shenzhen`
- `O=OPPO`
- `emailAddress=wlz@oppo.com`
- 有效期 2016-08-22 ~ 2026-09-21

这不是标准 AVB footer，也不是 Android `boot_signer` 的 AVB 结构；它是 OPPO 工程 bootloader 所需的附加证书/签名段。TWRP 设备树的 `boot/recovery.patch` 也是 1,280 字节、同样以 `30 82 04 fc` 开头，但证书序列号/内容与 Lineage recovery 的版本不完全相同。

**策略：** AERA 是 recovery 镜像，直接追加 LineageOS 22.1 **recovery.img** 末尾的 1,280 字节（已由真实设备验证可启动），而不是 TWRP 的旧 patch。首版构建后必须比较 `mkbootimg` 输出与 Lineage recovery 的 header/尾部，确保只差 ramdisk。

## 6. 构建参数

AERA 设备树中对应：

```make
BOARD_KERNEL_BASE := 0x80000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_TAGS_OFFSET := 0x00000100
BOARD_RAMDISK_OFFSET := 0x01000000
BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb
BOARD_BOOT_HEADER_VERSION := 0
BOARD_KERNEL_SEPARATED_DT := false
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := false
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
TARGET_PREBUILT_KERNEL := device/oppo/r9plus/prebuilt/Image.gz-dtb
```

`mkbootimg` 后处理：

```bash
python3 tools/patch_oppo_image.py \
  out/target/product/r9plus/recovery.img \
  device/oppo/r9plus/prebuilt/oppo_boot.patch
```

## 7. 证据文件

- [`sources/device/r9plus-images/boot-lineage22.1.img`](../sources/device/r9plus-images/boot-lineage22.1.img)
- [`sources/device/r9plus-images/recovery-lineage22.1.img`](../sources/device/r9plus-images/recovery-lineage22.1.img)
- [`sources/device/r9plus-images/recovery-lineage22.1.img.unpacked.kernel.bin`](../sources/device/r9plus-images/recovery-lineage22.1.img.unpacked.kernel.bin)
- [`sources/device/r9plus-images/recovery-lineage22.1.img.unpacked.dtb`](../sources/device/r9plus-images/recovery-lineage22.1.img.unpacked.dtb)
- [`tools/parse_bootimg.py`](../tools/parse_bootimg.py)
- [`tools/split_boot.py`](../tools/split_boot.py)

## 8. 未确认项

- OPPO bootloader 是否对尾部证书做密码学验证：**UNKNOWN**。现代 LineageOS 22.1 使用同一段证书可以启动，说明“原样保留”是充分条件；本项目不尝试修改证书。
- `fastboot boot recovery.img` 是否可用：**UNKNOWN / NEEDS VERIFICATION**。OPPO 的 aboot 可能不支持 `fastboot boot`；首次测试必须准备 EDL/官方恢复路径。
- 4.9 内核是否支持 AERA 16 所需的全部 syscall：需实际启动验证，见 [`conclusions/risks.md`](../conclusions/risks.md)。
