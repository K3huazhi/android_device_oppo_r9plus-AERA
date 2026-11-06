# AERA device tree design

## 1. 命名

```
device/oppo/r9plus/
```

对应目标仓库名：

```
android_device_oppo_r9plus-AERA
```

理由：

- `ro.cm.device=r9plus`；
- CM 构建名 `14.1-20161118-UNOFFICIAL-r9plus`；
- `wuxianlin/android_device_oppo_r9plus` 的路径是 `device/oppo/r9plus`；
- `TARGET_OTA_ASSERT_DEVICE` 包含 `r9plus,R9Plus,R9PlusA,R9PlusmA`。

`R9Plus` 是 LineageOS 22.1 设备树使用的产品名，但不是 CM 的 codename；本项目以 `r9plus` 作为稳定 codename，产品名 `twrp_r9plus`，同时在 assert 中保留 `R9Plus` 等别名。

## 2. 文件结构

```text
device/oppo/r9plus/
├── Android.bp
├── Android.mk
├── AndroidProducts.mk
├── BoardConfig.mk
├── device.mk
├── twrp_r9plus.mk
├── aera_r9plus.mk
├── prebuilt/
│   ├── Image.gz-dtb
│   └── oppo_boot.patch
├── recovery/root/
│   ├── init.recovery.qcom.rc
│   ├── init.recovery.usb.rc
│   ├── ueventd.qcom.rc
│   └── system/
│       ├── etc/
│       │   ├── recovery.fstab
│       │   └── twrp.flags
│       └── usr/keylayout/
│           ├── gpio-keys.kl
│           ├── synaptics_dsx.kl
│           └── synaptics_s1302.kl
└── sepolicy/
    └── README
```

## 3. 各文件职责

### `AndroidProducts.mk`

```make
PRODUCT_MAKEFILES := $(LOCAL_DIR)/twrp_r9plus.mk
COMMON_LUNCH_CHOICES := twrp_r9plus-user twrp_r9plus-userdebug twrp_r9plus-eng
```

AERA 的 lunch 目标以 `twrp_` 开头，保持与上游设备树一致。

### `twrp_r9plus.mk`

产品继承：

```make
base.mk
core_64_bit_only.mk
full_base_telephony.mk
vendor/twrp/config/common.mk
device/oppo/r9plus/device.mk
```

产品标识：

```make
PRODUCT_DEVICE := r9plus
PRODUCT_NAME := twrp_r9plus
PRODUCT_MODEL := OPPO R9 Plusm A
PRODUCT_MANUFACTURER := OPPO
```

### `BoardConfig.mk`

关键决策：

| 配置 | 值 | 原因 |
|---|---|---|
| `TARGET_ARCH` | `arm64` | 设备是 arm64-v8a |
| `TARGET_BOARD_PLATFORM` | `msm8952` | 平台族，TWRP/Lineage 基线 |
| `TARGET_BOOTLOADER_BOARD_NAME` | `MSM8952` | 与 aboot 一致 |
| `BOARD_KERNEL_IMAGE_NAME` | `Image.gz-dtb` | kernel 已含 FDT |
| `BOARD_BOOT_HEADER_VERSION` | `0` | 设备使用 v0 header |
| `BOARD_KERNEL_SEPARATED_DT` | `false` | 防止二次 DT |
| `BOARD_RECOVERYIMAGE_PARTITION_SIZE` | `67108864` | 64 MiB |
| `AB_OTA_UPDATER` | `false` | A-only |
| `BOARD_USES_METADATA_PARTITION` | `false` | 无 metadata 分区 |
| `TARGET_PREBUILT_KERNEL` | `prebuilt/Image.gz-dtb` | 复用 4.9 recovery 内核 |
| `AERA_INCLUDE_CRYPTO` | `false` | 首版关闭 FDE |

### `device.mk`

把 recovery 需要的文件放进 `TARGET_COPY_OUT_RECOVERY`：

- `init.recovery.qcom.rc`
- `init.recovery.usb.rc`
- `ueventd.qcom.rc`
- `recovery.fstab`
- `twrp.flags`
- keylayout

不把 TWRP UI/主题拷进来。

### `aera_r9plus.mk`

AERA 产品开关：

```make
AERA_FORCE_PREBUILT_KERNEL := 1
AERA_USE_LZ4_COMPRESSION := 0
AERA_USE_LZMA_COMPRESSION := 0
AERA_NO_TREBLE_COMPATIBILITY_CHECK := 1
AERA_SKIP_ADDITIONAL_FSTAB := 1
AERA_EXCLUDE_APEX := 1
AERA_INPUT_BLACKLIST := "hbtp_vm"
```

### `prebuilt/Image.gz-dtb`

从 LineageOS 22.1 `recovery.img` 提取的 10,561,222 字节 kernel blob：

- SHA-256 `7c9ac2f052edf435ee83e5a4be9a27529b7de012cca8da8dea21713f54376a2a`；
- gzip Image 10,318,321 字节；
- appended FDT 242,901 字节。

### `prebuilt/oppo_boot.patch`

从 LineageOS 22.1 `recovery.img` 末尾提取的 1,280 字节 DER 证书。构建后追加到 `recovery.img`。SHA-256：`0bac771b663ebb077b87f2ae1a588a3e5f89192a10dea1bee93c3b252af7eab5`。

### `recovery.fstab` / `twrp.flags`

直接复用 TWRP R9Plus 分区描述，因为：

- 分区表由 live 设备确认；
- TWRP 3.7.x 已在同设备验证；
- AERA 的 `TWPartitionManager` 解析同一格式。

### `init.recovery.qcom.rc`

- 设 `sys.usb.configfs=1`；
- 设 `sys.usb.controller=msm_hsusb`；
- 写背光；
- 创建 `/dev/block/bootdevice` 符号链接；
- CPU governor。

### `init.recovery.usb.rc`

- 创建 `ffs.adb` / `ffs.mtp` / `ffs.fastboot`；
- mount functionfs；
- `sys.usb.config=adb` 时启动 adbd；
- 写 UDC `msm_hsusb`。

### `ueventd.qcom.rc`

从 TWRP 树复制，提供 `/dev/graphics/fb0`、`/dev/input`、`/dev/qseecom`、块设备等权限。

## 4. 为什么不直接复制 OnePlus/Qualcomm 设备树

AERA 官方设备树（如 `dodge`）使用：

- SM8750 / Adreno 830；
- GKI 6.6 内核；
- `vendor_boot`；
- A/B + dynamic partitions；
- FBE / keymint；
- `panel0-backlight`；
- AIDL vibrator/touch。

R9 是：

- MSM8976 / Adreno 510；
- 4.9 非 GKI；
- 独立 recovery；
- A-only；
- FDE footer；
- `lcd-backlight`；
- evdev 触摸。

两者只有“AERA core 接口”相同，硬件配置不能复制。本项目只复用 AERA 的设备树**结构**，硬件参数全部来自 R9 证据。

## 5. 与 TWRP/Lineage 树的关系

| 来源 | 复用什么 | 不复用什么 |
|---|---|---|
| `wuxianlin/android_device_oppo_r9plus` (CM14.1) | codename、assert、分区表、keylayout、system.prop 参考 | 3.10 内核、CM recovery 配置 |
| `blueyfish/android_device_oppo_R9Plus` (Lineage 22.1) | 4.9 kernel/FDT、fstab 参考、设备身份 | squashfs system、dynamic partitions、FBE |
| `TipzTeam/recovery_device_oppo_thortanium` (TWRP 3.7.x) | fstab、twrp.flags、亮度/触摸/像素格式、OPPO 证书思路 | TWRP UI/主题、TWRP 二进制 |
| AERA `dodge` | 设备树结构、AERA 配置命名、USB rc 模板 | 所有硬件参数 |

## 6. 待办

- [ ] 构建 `twrp_r9plus`，修复产品继承/包名错误；
- [ ] 确认 `TARGET_COPY_OUT_RECOVERY` 路径在 AERA 16 中有效；
- [ ] 确认 `twrp.flags` 的 `/system_root` 与 AERA 16 的挂载逻辑兼容；
- [ ] 测量 `recovery.img` 大小；
- [ ] 追加 OPPO 证书并校验 header；
- [ ] 静态检查 ramdisk 内 `init.recovery.qcom.rc`、`fb0` 权限、adbd；
- [ ] 设备测试（需授权）。
