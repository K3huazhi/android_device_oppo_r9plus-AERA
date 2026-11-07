# AERA Recovery for OPPO R9 Plusm A (`r9plus`)

> GitHub 仓库：<https://github.com/K3huazhi/android_device_oppo_r9plus-AERA>  
> 研究快照：<https://github.com/K3huazhi/android_device_oppo_r9plus-AERA/releases/tag/v0.1-research>  
> 构建产物：<https://github.com/K3huazhi/android_device_oppo_r9plus-AERA/releases/tag/v0.2-build>

> 目标设备：OPPO R9 Plusm A / OPPO R9 Plustm A
> 设备实际报告：`ro.product.device=R9PlusA`、`ro.product.name=R9PlustmA`、`ro.cm.device=r9plus`
> SoC: Qualcomm MSM8976 (Snapdragon 652), Adreno 510
> 出厂 Android 5.1.1，当前 Android 7.1 / CyanogenMod 14.1

这是一个**独立的 AERA Recovery 设备适配项目**，不是把 AERA 主题套到 TWRP 上，也不是修改现有 Android 系统。最终交付物应是可维护的：

```
android_device_oppo_r9plus-AERA
```

本仓库当前包含研究证据、设备树、预编译内核基线、**已构建的 recovery.img**、构建记录与 bring-up 计划。

---

## 当前状态

| 阶段 | 状态 |
|---|---|
| 设备身份 / 型号锁定 | ✅ 已用只读 ADB 证据锁定 |
| 分区表 / boot-recovery 布局 | ✅ 已确认（独立 recovery，A-only，64 MiB） |
| 现有 TWRP / Lineage recovery 基线 | ✅ 已取得设备树、TWRP flags、Lineage 22.1 镜像 |
| AERA 源码 / 构建系统研究 | ✅ 已拉取 `aera-16.0` |
| AERA 设备树 | ✅ 已建立 `device/oppo/r9plus` |
| AOSP 16 源码同步 | ✅ 已完成（BFSU 镜像 + 局部补齐 prebuilts） |
| AERA recovery 编译 | ✅ 已完成（12 GB WSL + 64 GB NVMe swap + 8 GB zram） |
| 生成 `recovery.img` | ✅ **45,681,920 B**，已追加 OPPO 1,280 B 证书 |
| 设备启动验证 | ⛔ 未执行（按项目规则，需明确授权） |

**最终结论：FEASIBLE（构建与静态校验层面）。** AERA R1.0 `recovery.img` 已成功构建，header v0 / page 2048 / 内核 SHA-256 与预编译 `Image.gz-dtb` 一致 / ramdisk gzip 可解 / 尾部 1,280 B OPPO 证书均验证通过，设备树静态检查 38/38 PASS。**但还没有刷入设备**，AERA 16 用户空间在 4.9 内核上的实际启动、显示、触摸、ADB、分区挂载仍未验证；运行时仍可能失败。详见 [`conclusions/build-success.md`](conclusions/build-success.md)、[`conclusions/feasibility.md`](conclusions/feasibility.md)、[`conclusions/build-attempt.md`](conclusions/build-attempt.md)。

---

## 关键结论（先读）

1. **这台机器确实有独立 `recovery` 分区**：`/dev/block/bootdevice/by-name/recovery -> mmcblk0p25`，64 MiB；`boot` 为 `mmcblk0p24`，同样 64 MiB。
2. 设备是 **A-only**，没有 `vendor`、`metadata`、`dtbo`、`super` 等现代分区。
3. 设备实际是 **MSM8976**，不是 MTK；`ro.board.platform=msm8952` 是 Qualcomm 平台族字段，不能据此误判为 Snapdragon 617。
4. **CM14.1 的 3.10 内核不是必须复用的**。R9Plus 的 LineageOS 22.1（Android 15）已经使用 **4.9 recovery 内核**成功启动；本项目直接复用该 4.9 recovery 内核 + 其 FDT，避免为 Android 16 重写 3.10 内核。
5. **OPPO 的 boot/recovery 镜像在标准 boot header 之后追加了一段 DER 证书**（不是 AVB footer）：boot.img 为 1,276 字节，recovery.img 为 1,280 字节。LineageOS 22.1 的 recovery.img 仍保留该段；AERA 镜像使用 recovery 的 1,280 字节版本。
6. AERA 的 fbdev 后端可以直接使用本机 `/dev/graphics/fb0`（1080×1920，32bpp，stride 4352）。
7. 触摸是 `synaptics-s3508`（MT-B，1080×1920），需要屏蔽 OPPO 的虚拟鼠标 `hbtp_vm`。
8. **64 MiB 分区容量问题已经回答：** 最终 `recovery.img` 为 **45,681,920 B（43.56 MiB）**，装得下。尚未回答的是 **AERA 16 用户空间在 4.9 内核上的实际启动兼容性**，需要设备验证。

---

## 目录

```
README.md
docs/
  device-identity.md
  hardware.md
  partition-layout.md
  boot-recovery-layout.md
  existing-recovery.md
  kernel.md
  display.md
  touch.md
  adb-usb.md
  storage.md
  encryption.md
  aera-architecture.md
  device-tree-design.md
  build-guide.md
  bringup.md
device/oppo/r9plus/           # AERA device tree
sources/
  aera/                       # AERA source + manifests
  device/                     # live evidence, CM14.1, Lineage 22.1 trees
  recovery/                   # TWRP thortanium tree
  kernel/                     # kernel notes / artifacts (metadata only)
  other/                      # release metadata
comparisons/
  aera-vs-twrp.md
  aera-device-trees.md
  r9plusm-recovery-options.md
conclusions/
  feasibility.md
  risks.md
  next-steps.md
  build-attempt.md
  static-validation.txt
dist/
  android_device_oppo_r9plus-AERA.tar.gz
tools/                        # boot image parser / patcher / build helpers
```

---

## 镜像产物

**下载：** [recovery-AERA-R1.0-r9plus.img](https://github.com/K3huazhi/android_device_oppo_r9plus-AERA/releases/download/v0.2-build/recovery-AERA-R1.0-r9plus.img)

```text
size    45,681,920 B (43.56 MiB)
sha256  3d9ddd212219f221a100c76942510b266c5a98e2d43bac9f68a0334e6f18df45
```

- header v0，page 2048；
- kernel 10,561,222 B，与 `prebuilt/Image.gz-dtb` SHA-256 完全一致；
- ramdisk 35,116,033 B gzip，3,650 个文件；
- 尾部 1,280 B OPPO 证书（`30 82 04 fc`）；
- 含 `system/bin/recovery`、`system/etc/recovery.fstab`、`vendor/etc/vintf`、`init.recovery.qcom.rc`。

未签名的对照镜像：`dist/recovery-AERA-R1.0-r9plus-unsigned.img`。  
**没有刷入设备。**

---

## 安全边界

本项目第一阶段**只做只读分析、源码编译和镜像静态验证**。

已执行且只执行过的设备操作：

- `adb devices`
- `adb shell getprop`
- `adb shell cat /proc/...`
- `adb shell ls /sys/...`、`/dev/block/...`
- `adb pull /sdcard/TWRP/.twrps`
- `adb shell getevent -pl`

**没有执行**：`flash`、`erase`、`format`、`fastboot flash`、`fastboot boot`、`adb reboot`、修改分区、修改 boot/recovery/system/userdata。

任何需要写入设备的步骤都在 `docs/bringup.md` 中标记为 **REQUIRES USER CONFIRMATION**。

---

## 复现入口

见 [`docs/build-guide.md`](docs/build-guide.md)。核心命令（在 Linux/AOSP 环境中）：

```bash
source build/envsetup.sh
lunch twrp_r9plus-bp2a-eng
mka adbd recoveryimage
python3 tools/patch_oppo_image.py \
  out/target/product/r9plus/recovery.img \
  device/oppo/r9plus/prebuilt/oppo_boot.patch
```

输出目标：`out/target/product/r9plus/recovery.img`。

---

## 结论口径

最终只会给出以下三者之一：

- **FEASIBLE**：已编译出镜像，且静态校验/可恢复测试路径完整；若设备验证成功则更充分。
- **PARTIALLY FEASIBLE**：设备树/基线大部分成立，但存在明确的构建、运行时或功能缺口。
- **BLOCKED**：存在无法通过设备树/配置解决的硬障碍。

当前结论：**FEASIBLE（构建/静态）**。`recovery.img` 已构建并通过静态校验；未进行设备启动，因此不能声称“已验证可启动”。下一步是获得明确授权后，按 [`docs/bringup.md`](docs/bringup.md) 做可回退的启动验证。运行时若失败，再按 [`conclusions/feasibility.md`](conclusions/feasibility.md) 的降级条件重新判定。
