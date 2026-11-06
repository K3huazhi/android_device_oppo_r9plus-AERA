# Partition layout — OPPO R9 Plusm A (`r9plus`)

## 1. 结论

- 存储设备：`/dev/block/mmcblk0`，eMMC，61,071,360 KiB（约 58.2 GiB）。
- **A-only**：没有 `_a` / `_b` 后缀，没有 `slotselect`。
- **存在独立 `recovery` 分区**：`mmcblk0p25`，65,536 KiB = 64 MiB。
- **存在独立 `boot` 分区**：`mmcblk0p24`，64 MiB。
- **没有** `vendor`、`metadata`、`dtbo`、`super`、`init_boot`、`vbmeta` 分区。
- `system` 为 ext4，2 GiB；`userdata` 约 55.2 GiB；`cache` 128 MiB。
- `reserve2`（16 MiB）在现代 LineageOS 22.1 中被当作 `/metadata` 使用；**CM14.1 原厂并不使用它作为 metadata**，所以不能把“reserve2 就是 metadata”当成历史事实。

## 2. 完整分区表

数据来自本机只读 `/proc/partitions` 与 `/dev/block/bootdevice/by-name` 符号链接；`by-name` 名称与 CM14.1 设备树 `partition.txt` 完全一致。

| # | by-name | 块设备 | 大小 (KiB) | 大小 | 备注 |
|---:|---|---|---:|---|---|
| 1 | modem | mmcblk0p1 | 92,160 | 90 MiB | 基带固件（vfat） |
| 2 | fsc | mmcblk0p2 | 1 | 1 KiB | 文件系统计数器 |
| 3 | ssd | mmcblk0p3 | 8 | 8 KiB | SSD |
| 4 | sbl1 | mmcblk0p4 | 512 | 512 KiB | 二级 bootloader |
| 5 | sbl1bak | mmcblk0p5 | 512 | 512 KiB | 备份 |
| 6 | rpm | mmcblk0p6 | 512 | 512 KiB | RPM |
| 7 | rpmbak | mmcblk0p7 | 512 | 512 KiB | 备份 |
| 8 | tz | mmcblk0p8 | 2,048 | 2 MiB | TrustZone |
| 9 | tzbak | mmcblk0p9 | 2,048 | 2 MiB | 备份 |
| 10 | hyp | mmcblk0p10 | 512 | 512 KiB | Hypervisor |
| 11 | hypbak | mmcblk0p11 | 512 | 512 KiB | 备份 |
| 12 | dsp | mmcblk0p12 | 16,384 | 16 MiB | DSP（ext4） |
| 13 | modemst1 | mmcblk0p13 | 1,536 | 1.5 MiB | 基带 EFS |
| 14 | modemst2 | mmcblk0p14 | 1,536 | 1.5 MiB | 基带 EFS |
| 15 | oppodycnvbk | mmcblk0p15 | 10,240 | 10 MiB | OPPO NV |
| 16 | oppostanvbk | mmcblk0p16 | 10,240 | 10 MiB | OPPO NV |
| 17 | LOGO | mmcblk0p17 | 16,384 | 16 MiB | 开机 logo |
| 18 | DDR | mmcblk0p18 | 32 | 32 KiB | DDR 参数 |
| 19 | fsg | mmcblk0p19 | 1,536 | 1.5 MiB | FSG |
| 20 | sec | mmcblk0p20 | 16 | 16 KiB | 安全分区 |
| 21 | splash | mmcblk0p21 | 11,264 | 11 MiB | splash |
| 22 | aboot | mmcblk0p22 | 1,024 | 1 MiB | AP bootloader |
| 23 | abootbak | mmcblk0p23 | 1,024 | 1 MiB | 备份 |
| **24** | **boot** | **mmcblk0p24** | **65,536** | **64 MiB** | Android boot |
| **25** | **recovery** | **mmcblk0p25** | **65,536** | **64 MiB** | **独立 recovery** |
| 26 | devinfo | mmcblk0p26 | 1,024 | 1 MiB | device info |
| 27 | cache | mmcblk0p27 | 131,072 | 128 MiB | ext4 |
| 28 | system | mmcblk0p28 | 2,097,152 | 2 GiB | ext4 |
| 29 | persist | mmcblk0p29 | 32,768 | 32 MiB | ext4 |
| 30 | misc | mmcblk0p30 | 1,024 | 1 MiB | bootloader message |
| 31 | keystore | mmcblk0p31 | 512 | 512 KiB | keystore |
| 32 | config | mmcblk0p32 | 32 | 32 KiB | FRP/config |
| 33 | oem | mmcblk0p33 | 65,536 | 64 MiB | OPPO OEM |
| 34 | limits | mmcblk0p34 | 32 | 32 KiB | limits |
| 35 | mota | mmcblk0p35 | 512 | 512 KiB | MOTA |
| 36 | devcfg | mmcblk0p36 | 256 | 256 KiB | devcfg |
| 37 | dip | mmcblk0p37 | 1,024 | 1 MiB | DIP |
| 38 | mdtp | mmcblk0p38 | 32,768 | 32 MiB | MDTP |
| 39 | syscfg | mmcblk0p39 | 512 | 512 KiB | syscfg |
| 40 | mcfg | mmcblk0p40 | 4,096 | 4 MiB | MCFG |
| 41 | cmnlib | mmcblk0p41 | 256 | 256 KiB | common lib |
| 42 | keymaster | mmcblk0p42 | 256 | 256 KiB | keymaster |
| 43 | cmnlibbak | mmcblk0p43 | 256 | 256 KiB | 备份 |
| 44 | keymasterbak | mmcblk0p44 | 256 | 256 KiB | 备份 |
| 45 | apdp | mmcblk0p45 | 256 | 256 KiB | APDP |
| 46 | msadp | mmcblk0p46 | 256 | 256 KiB | MSADP |
| 47 | dpo | mmcblk0p47 | 8 | 8 KiB | DPO |
| 48 | DRIVER | mmcblk0p48 | 32,768 | 32 MiB | DRIVER |
| 49 | reserve1 | mmcblk0p49 | 2,048 | 2 MiB | 保留 |
| 50 | reserve2 | mmcblk0p50 | 16,384 | 16 MiB | 保留；Lineage 22.1 用作 /metadata |
| 51 | reserve3 | mmcblk0p51 | 2,048 | 2 MiB | 保留 |
| 52 | reserve4 | mmcblk0p52 | 16,384 | 16 MiB | 保留 |
| **53** | **userdata** | **mmcblk0p53** | **57,855,463** | **~55.2 GiB** | ext4/f2fs，含 /data/media |

`mmcblk0rpmb`（4 MiB）为 RPMB 独立块设备，不是普通分区。

## 3. 缺失的现代分区

以下分区**不存在**，因此 AERA/Android 16 的默认 GKI、AVB、动态分区、FBE 方案不能照搬：

- `vendor`：不存在。CM14.1 的 vendor 文件在 `/system/vendor`。
- `metadata`：不存在。Lineage 22.1 把 `reserve2` 映射为 `/metadata`。
- `dtbo`：不存在。DTB 追加在 kernel 后面（`Image.gz-dtb`）。
- `super` / `system_ext` / `product` / `odm`：不存在。
- `init_boot` / `vendor_boot`：不存在。Android 13+ 的 GKI 启动链不适用。
- `vbmeta`：不存在。OPPO 使用自定义 boot 镜像尾部证书，不是标准 AVB。

## 4. 证据

- 本机：`/proc/partitions`、`/dev/block/bootdevice/by-name`（[`sources/device/live/by-name.txt`](../sources/device/live/by-name.txt)）
- CM14.1 设备树：`partition.txt`（[`sources/device/android_device_oppo_r9plus/partition.txt`](../sources/device/android_device_oppo_r9plus/partition.txt)）
- CM14.1 BoardConfig：`BOARD_BOOTIMAGE_PARTITION_SIZE`、`BOARD_RECOVERYIMAGE_PARTITION_SIZE`、`BOARD_USERDATAIMAGE_PARTITION_SIZE`（[`sources/device/r9plus_BoardConfig.mk`](../sources/device/r9plus_BoardConfig.mk)）
- LineageOS 22.1 设备树：`rootdir/etc/fstab.qcom` 使用 `reserve2` 作为 `/metadata`（[`sources/device/lineage21/R9Plus/rootdir/etc/fstab.qcom`](../sources/device/lineage21/R9Plus/rootdir/etc/fstab.qcom)）
- TWRP 3.7.x 设备树：`twrp.flags` 的 `/metadata` 指向 `reserve2`（[`sources/recovery/twrp_thortanium/R9Plus/recovery/root/system/etc/twrp.flags`](../sources/recovery/twrp_thortanium/R9Plus/recovery/root/system/etc/twrp.flags)）

## 5. 对 AERA 设备树的约束

1. 目标镜像必须是 **`recovery.img`**，写入 `recovery` 分区；不能改成 `boot.img`。
2. `BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864`。
3. 不能启用 `AB_OTA_UPDATER`、`PRODUCT_USE_DYNAMIC_PARTITIONS`、`BOARD_USES_METADATA_PARTITION`。
4. `system` 按 ext4 处理，不能按 Lineage 22.1 的 squashfs 处理（CM14.1 的 system 是 ext4）。
5. `userdata` 同时支持 ext4 和 f2fs；CM14.1 使用 FDE footer，不是 FBE。
6. `/metadata` 在首版不格式化、不默认挂载；等 FDE/FBE 策略确定后再启用。
