# Storage / partitions

## 1. 挂载模型

本机是传统 A-only 分区，不使用 dynamic partitions / super / vendor。AERA 的存储层按 TWRP 的 fstab + flags 工作。

### recovery.fstab（AOSP 风格，TWRP 解析）

```text
/dev/block/bootdevice/by-name/boot        /boot       emmc  defaults  defaults
/dev/block/bootdevice/by-name/recovery    /recovery   emmc  defaults  defaults
/dev/block/bootdevice/by-name/userdata    /data       f2fs  ...       wait,check,quota,formattable,encryptable=footer
/dev/block/bootdevice/by-name/userdata    /data       ext4  ...       wait,check,quota,formattable,encryptable=footer
/dev/block/bootdevice/by-name/reserve2    /metadata   ext4  ...       wait,check,formattable
/dev/block/bootdevice/by-name/misc        /misc       emmc  defaults  defaults
/dev/block/bootdevice/by-name/config      /frp        emmc  defaults  defaults
```

### twrp.flags（TWRP v1 风格）

| 挂载点 | 类型 | 设备 | 说明 |
|---|---|---|---|
| `/boot` | emmc | `boot` | 备份 boot |
| `/recovery` | emmc | `recovery` | 备份 recovery |
| `/cache` | ext4 | `cache` | 可格式化 |
| `/firmware` | vfat | `modem` | 只读固件 |
| `/modem` | emmc | `modem` | 备份 |
| `/dsp` | emmc | `dsp` | modem 子分区 |
| `/efs1` | emmc | `modemst1` | EFS |
| `/efs2` | emmc | `modemst2` | EFS 子分区 |
| `/fsc` | emmc | `fsc` | EFS 子分区 |
| `/fsg` | emmc | `fsg` | EFS 子分区 |
| `/oppostanvbk` | emmc | `oppostanvbk` | OPPO NV |
| `/oppodycnvbk` | emmc | `oppodycnvbk` | OPPO NV |
| `/persist` | ext4 | `persist` | 备份 |
| `/logo` | emmc | `LOGO` | 备份 |
| `/system_root` | ext4 | `system` | 系统 |
| `/system_image` | emmc | `system` | 原始镜像刷写 |
| `/data` | ext4 | `userdata` | 加密 footer |
| `/metadata` | ext4 | `reserve2` | Lineage 22.1 的 metadata |
| `/misc` | emmc | `misc` | bootloader message |
| `/external_sd` | auto | `mmcblk1p1` | microSD |
| `/usb_otg` | auto | `sda1` | USB OTG |

完整文件见：

- [`device/oppo/r9plus/recovery/root/system/etc/recovery.fstab`](../device/oppo/r9plus/recovery/root/system/etc/recovery.fstab)
- [`device/oppo/r9plus/recovery/root/system/etc/twrp.flags`](../device/oppo/r9plus/recovery/root/system/etc/twrp.flags)

## 2. 文件系统

| 分区 | 文件系统 | 备注 |
|---|---|---|
| system | ext4 | CM14.1 的 2 GiB system |
| userdata | ext4 或 f2fs | CM14.1 默认 ext4；TWRP 双条目 |
| cache | ext4 | 128 MiB |
| persist | ext4 | 32 MiB |
| dsp | ext4 | 16 MiB |
| modem | vfat | 90 MiB，只读挂到 `/firmware` |
| external SD | vfat/exfat | `mmcblk1p1` |
| USB OTG | auto | `sda1` |

LineageOS 22.1 的 system 是 squashfs，但 **CM14.1 是 ext4**。本项目不能用 squashfs 配置。

## 3. 内部存储

CM14.1 使用 `/data/media` 模拟内部存储：

```make
RECOVERY_SDCARD_ON_DATA := true
```

AERA 的 `/sdcard` 应绑定到 `/data/media/0`（或 TWRP 的等价路径）。这需要 `/data` 可挂载；如果 data 被加密且未解密，`/sdcard` 不可用，这是正常行为。

## 4. 分区识别与备份

AERA 依赖：

- `/dev/block/bootdevice/by-name/*` 符号链接；
- `twrp.flags` 的 `backup=1` / `flashimg=1`；
- `recovery.fstab` 的 `wait` / `check` / `formattable`。

本机 by-name 链接齐全（53 个），且 init 会创建：

```text
/dev/block/platform/soc/7824900.sdhci -> /dev/block/bootdevice
```

## 5. 格式化 / 擦除风险

| 操作 | 风险 |
|---|---|
| Format Data | 会清空 `/data` 和内部存储；必须先备份 |
| Format cache | 相对安全 |
| Wipe system | 会清除 Android 系统，需要重新刷 ROM |
| Wipe metadata/reserve2 | Lineage 22.1 可能使用；CM14.1 不使用，但不要默认格式化 |
| Wipe modem/efs/persist | **高风险**，可能导致无基带/传感器丢失；首版不默认暴露 |
| flash recovery | 会替换现有 TWRP/Lineage recovery；必须备份原 recovery |

AERA 的 `twrp.flags` 中 `backup=1` 的分区可用于先备份。首版 UI 不应默认勾选 EFS/modem 的擦除。

## 6. 64 MiB recovery 分区约束

`recovery` 分区只有 64 MiB。AERA 镜像 = 内核 10.56 MiB + 压缩 ramdisk + 1.3 KiB 证书。

可用空间约 **53.4 MiB** 给压缩 ramdisk。AERA 的 UI/工具/库可能接近这个上限；构建后必须检查：

```bash
ls -l out/target/product/r9plus/recovery.img
```

如果超过 67,108,864 字节，优先：

1. 关闭不必要功能（exFAT/NTFS、Python、额外语言、fastbootd、日志）；
2. 压缩 ramdisk（但内核未启用 LZ4/XZ，只能用 gzip）；
3. 裁剪 AERA 预置资源；
4. 最后才考虑修改分区表（**禁止**，不在本项目范围）。

## 7. 结论

存储层可以完全复用 TWRP R9Plus 的 fstab/flags；AERA 不需要新的分区方案。首版优先保证：

- `/dev/block/bootdevice` 存在；
- `/system`、`/data`、`/cache`、`/boot`、`/recovery` 可识别；
- `/sdcard` 在 data 挂载后可用；
- 不做自动格式化。
