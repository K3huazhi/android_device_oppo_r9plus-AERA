# Kernel

## 1. 结论

本项目**不重写内核**。首版直接复用 R9Plus 的 **Linux 4.9.337 recovery 内核**：

```
Linux 4.9.337
  + lineageos_R9Plus_recovery_defconfig
  + R9Plus FDT (242,901 bytes)
  = Image.gz-dtb (10,561,222 bytes)
```

该 blob 来自已验证可在 R9Plus 上启动的 LineageOS 22.1 recovery.img：

- SHA-256：`7c9ac2f052edf435ee83e5a4be9a27529b7de012cca8da8dea21713f54376a2a`
- 路径：[`device/oppo/r9plus/prebuilt/Image.gz-dtb`](../device/oppo/r9plus/prebuilt/Image.gz-dtb)

## 2. 当前系统内核 vs recovery 内核

| 项目 | 当前 CM14.1 系统 | AERA recovery 首版 |
|---|---|---|
| 版本 | `3.10.84-perf-g00c9d0f` | `4.9.337` |
| 来源 | CM14.1 内置 | LineageOS 22.1 R9Plus recovery |
| 用途 | 启动 Android 7.1 system | 启动独立 recovery |
| 是否修改 Android system | 否 | 否 |
| 是否影响 boot 分区 | 否（AERA 只写 recovery） | 否 |

Recovery 是**独立内核**：启动 recovery 时，bootloader 加载 recovery 分区里的 4.9 内核；日常 Android 7.1 仍使用 boot 分区里的 3.10 内核。两者互不替换。

> 这也是本项目避免“为了 AERA 改动正常系统”的关键：只替换 recovery 分区。

## 3. 内核源码

| 项目 | 值 |
|---|---|
| 仓库 | `https://github.com/blueyfish/android_kernel_oppo_msm8937` |
| 分支 | `lineage-22.1`（也提供 lineage-21、lineage-22.0） |
| 版本 | 4.9.337 |
| 目标设备 | MSM8976 / R9Plus（虽名为 msm8937，实际包含 MSM8976 支持） |
| 配置 | `arch/arm64/configs/lineageos_R9Plus_recovery_defconfig` |

本地配置副本：

[`sources/kernel/arch_arm64_configs_lineageos_R9Plus_recovery_defconfig`](../sources/kernel/arch_arm64_configs_lineageos_R9Plus_recovery_defconfig)

## 4. 配置证据（recovery defconfig）

以下配置直接证明“显示、触摸、USB、文件系统”路径成立：

```text
CONFIG_ARCH_MSM8976=y
CONFIG_FB=y
CONFIG_FB_MSM=y
CONFIG_FB_MSM_MDSS=y
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_SYNAPTICS_OPPO=y
CONFIG_INPUT_HBTP_INPUT=y
CONFIG_USB_GADGET=y
CONFIG_USB_CONFIGFS=y
CONFIG_USB_CONFIGFS_F_FS=y
CONFIG_USB_CONFIGFS_F_MTP=y
CONFIG_MMC=y
CONFIG_MMC_SDHCI_MSM=y
CONFIG_EXT4_FS=y
CONFIG_F2FS_FS=y
CONFIG_VFAT_FS=y
CONFIG_EXFAT_FS=y
CONFIG_QSEECOM=y
CONFIG_DM_VERITY=y
CONFIG_SECURITY_SELINUX=y
```

关键限制：

```text
# CONFIG_RD_LZ4 is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZMA is not set
```

因此 **recovery ramdisk 必须使用 gzip**，不能使用 LZ4/LZMA。AERA 设备树中已设置：

```make
AERA_USE_LZ4_COMPRESSION := 0
AERA_USE_LZMA_COMPRESSION := 0
```

## 5. 为什么不复用 3.10 内核

Android 16 用户空间比 Android 7.1 依赖更多新 syscall/内核接口。虽然 recovery 比完整 Android 简单，但仍涉及：

- `getrandom` / `memfd_create` / `statx` 等 bionic 路径；
- `seccomp`、`clone3` 的 fallback；
- 新 linker / libc 的 `futex`、`membarrier` 行为；
- AERA 的 `adbd`、`libfuse`、`libc++` 等。

4.9.337 内核已经在同一硬件上启动 Android 15 recovery，显著降低风险。3.10 内核没有在此设备上验证过 Android 16 用户空间，不应作为首版选择。

## 6. 为什么不需要重新编译内核

R9Plus 的 4.9 recovery 内核已经包含 recovery 所需的一切：

- MDSS fbdev；
- Synaptics S3508 触摸；
- eMMC / SDHCI；
- USB configfs / FunctionFS；
- ext4 / f2fs / vfat / exfat；
- QSEECom / keymaster（FDE 后续可用）；
- SELinux。

AERA 的设备差异可以通过 device tree、fstab、init、SELinux、ramdisk 解决，不需要改内核。

## 7. 如果后续必须改内核

触发条件（只有实际验证失败才做）：

1. AERA 16 二进制因缺少某个 syscall 无法启动；
2. 显示初始化需要特定 panel 参数；
3. 触摸需要不同的 input 协议/固件加载；
4. FDE 需要启用/调整 QSEECom/keymaster 配置；
5. 64 MiB recovery 分区导致必须启用 LZ4 ramdisk 解压。

流程：

1. 克隆 `blueyfish/android_kernel_oppo_msm8937` 的 `lineage-22.1`；
2. 以 `lineageos_R9Plus_recovery_defconfig` 为基线；
3. 最小化修改（只加必要 config/quirks）；
4. 用 AOSP clang 或内核自带工具链编译 `Image.gz-dtb`；
5. 保留当前预编译内核作为 fallback；
6. 不修改 Android 7.1 的 boot 分区。

## 8. 未确认项

- 该 4.9 内核在 AERA 16 用户空间下的实际 syscall 兼容性：**NEEDS VERIFICATION**（首次启动日志）。
- `CONFIG_RD_GZIP` 未在 defconfig 中显式出现，但 gzip initramfs 是默认能力，且原厂 recovery.img 的 ramdisk 就是 gzip；可视为已验证。
- 内核是否包含 AERA 所需的 `CONFIG_ANDROID_BINDERFS` / `CONFIG_ASHMEM` 等：recovery 首版不需要完整 Android binder；AERA 的 adbd/UI 不依赖 system server。若后续功能需要，再补。
