# Feasibility — provisional assessment

> 状态：**AERA R1.0 `recovery.img` 已构建并通过静态校验；实机刷入后卡第一屏，无 ADB/fastboot；项目已放弃。**

## 1. 结论

**PARTIALLY FEASIBLE（构建成功，运行时失败；项目已放弃）**

设备树、内核、FDT、OPPO 证书、分区/fstab/显示/触摸/ADB 路径均已建立；AOSP 16 全量构建已完成，产出：

```text
dist/recovery-AERA-R1.0-r9plus.img
45,681,920 B
sha256 3d9ddd212219f221a100c76942510b266c5a98e2d43bac9f68a0334e6f18df45
```

构建使用 12 GB WSL + 64 GB NVMe swap + 8 GB zram，Soong 峰值 swap 约 27 GiB，未 OOM。镜像 header v0 / page 2048、内核 SHA-256 与预编译 `Image.gz-dtb` 一致、ramdisk gzip 可解、尾部 1,280 B OPPO 证书存在，设备树静态检查 38/38 PASS。

**设备验证结果：失败。** 用户刷入 `recovery` 后重启，设备卡在第一屏，未进入 AERA UI；主机侧 `adb devices` 与 `fastboot devices` 均无设备，未能抓取日志。项目所有者已放弃继续 bring-up。

因此最终不是“可启动的 FEASIBLE”，而是 **构建成功、运行时失败** 的 PARTIALLY FEASIBLE。失败记录见 [`runtime-result.md`](runtime-result.md)。

理由：

1. 设备有独立 64 MiB `recovery` 分区，A-only；
2. 同一硬件的 LineageOS 22.1 已用 4.9 recovery 内核 + fbdev + evdev 启动；
3. AERA 16 有 fbdev 后端和 evdev MT-B 输入；
4. AERA 支持传统 A-only + 独立 recovery；
5. 设备树可以复用 TWRP 的 fstab/flags；
6. 预编译内核和 OPPO 证书路径明确；
7. 不需要修改 Android 7.1 的 boot/system。

如果设备验证出现以下任一项，则可能降级为 **PARTIALLY FEASIBLE / BLOCKED**：

- AERA 16 二进制在 4.9 内核上无法启动；
- OPPO aboot 拒绝该自定义 image（证书/签名路径失败）；
- 能启动但显示、触摸、ADB、分区挂载之一不可用；
- AERA 16 的 crypto 与 CM14.1 FDE 不兼容（只影响加密功能）。

容量问题已排除：最终 ramdisk 35,116,033 B，镜像 45,681,920 B，小于 64 MiB。

## 2. Q1–Q14

### Q1. 真实 codename、SoC、boot/recovery 架构？

- codename：`r9plus`（CM）；产品名 `R9PlusA` / `R9PlustmA`；
- SoC：Qualcomm MSM8976（Snapdragon 652），Adreno 510；
- 架构：A-only，v0 boot image，独立 `boot`/`recovery` 分区，kernel `Image.gz` + appended FDT，无 AVB/vbmeta。

### Q2. 是否存在独立 recovery 分区？

**是。** `/dev/block/bootdevice/by-name/recovery -> mmcblk0p25`，65,536 KiB = 64 MiB。

### Q3. 现有 TWRP/CWM/OrangeFox 如何启动？

- bootloader 加载 recovery 分区；
- v0 header，4.9 recovery 内核（现代 TWRP/Lineage 基线）；
- ramdisk init → `init.recovery.qcom.rc`；
- fbdev `/dev/graphics/fb0`；
- evdev `synaptics-s3508`；
- configfs USB `msm_hsusb`；
- 尾部 1,280 字节 OPPO 证书（recovery 镜像）。

当前具体 recovery 版本：**UNKNOWN**（只确认使用过 TWRP，且有 TWRP 3.7.x 设备树/发布说明）。

### Q4. AERA 当前 build system 能否直接适配？

**可以，需新增设备树，不能直接套用现成设备。** AERA 16 使用 AOSP `mka recoveryimage` + `twrp_<device>` 产品 + `AERA_*` 配置；R9 需要：

- 预编译 4.9 kernel/FDT；
- v0 header；
- 64 MiB recovery 分区；
- 传统 fstab/flags；
- fbdev/evdev 配置。

### Q5. 需要新建哪些 device tree 文件？

见 [`docs/device-tree-design.md`](device-tree-design.md)：

```
AndroidProducts.mk
BoardConfig.mk
device.mk
twrp_r9plus.mk
aera_r9plus.mk
Android.bp / Android.mk
prebuilt/Image.gz-dtb
prebuilt/oppo_boot.patch
recovery/root/init.recovery.qcom.rc
recovery/root/init.recovery.usb.rc
recovery/root/ueventd.qcom.rc
recovery/root/system/etc/recovery.fstab
recovery/root/system/etc/twrp.flags
recovery/root/system/usr/keylayout/*.kl
sepolicy/
```

### Q6. 哪些现有 TWRP / CM14.1 文件可以直接复用？

- TWRP R9Plus `recovery.fstab`；
- TWRP R9Plus `twrp.flags`；
- CM14.1 keylayout（`gpio-keys.kl`、`synaptics_s1302.kl`、`synaptics_dsx.kl`）；
- CM14.1 codename/assert/分区表；
- TWRP/Lineage init rc 模板；
- Lineage 22.1 的 4.9 recovery kernel + FDT；
- Lineage 22.1 的 OPPO 尾部证书。

### Q7. 哪些 kernel / vendor blobs 可以复用？

- kernel：`Image.gz-dtb`（4.9.337 + 242,901 B FDT）；
- vendor blobs：首版不需要；FDE 阶段需要 QSEECom/keymaster/gatekeeper 相关库；
- GPU/Adreno 用户空间：首版 fbdev 软件渲染不需要；AERA 浏览器/GPU 功能后续再加。

### Q8. 最大技术风险？

按优先级：

1. **Android 16 用户空间在 4.9 内核上的兼容性**；
2. **AERA ramdisk 超过 64 MiB recovery 分区**；
3. **AERA 16 对 CM14.1 FDE 的支持**；
4. **OPPO 尾部证书/aboot 接受度**；
5. 显示颜色/首次 blank、触摸 blacklist。

### Q9. 最小可启动 AERA recovery 需要哪些组件？

- 4.9 recovery kernel + FDT；
- gzip AERA ramdisk；
- `init` + `init.recovery.qcom.rc`；
- `system/bin/recovery`（AERA core）；
- fbdev 显示 + evdev 触摸；
- `adbd` + USB configfs；
- `recovery.fstab` / `twrp.flags`；
- OPPO 1,280 B 证书；
- 64 MiB 内的 `recovery.img`。

### Q10. 第一版应该实现哪些功能，哪些延后？

第一版：

- 启动；
- 显示；
- 触摸；
- ADB；
- 分区识别/挂载；
- 基本文件管理/重启。

延后：

- ZIP/image 刷写；
- sideload；
- MTP；
- 加密；
- Wi-Fi/Remote；
- 插件/终端/备份高级功能。

### Q11. 最终 recovery image 应该是什么格式？

`recovery.img`：

- Android boot header v0；
- page size 2048；
- `Image.gz` + 242,901 B FDT；
- gzip cpio ramdisk；
- 1,280 B OPPO 证书；
- ≤ 67,108,864 B；
- 写入 `mmcblk0p25`。

不是 `boot.img`，不是 `vendor_boot.img`。

### Q12. 从源码到第一次成功启动需要修改哪些代码？

- 新增设备树（主要工作）；
- 不修改 AERA core；
- 不修改 CM14.1 system；
- 预编译内核/证书；
- 可能需要修：
  - `init.recovery.qcom.rc` 的 UDC/背光路径；
  - `recovery.fstab` 的 `/system` 类型；
  - `AERA_INPUT_BLACKLIST`；
  - product 继承/包名；
  - `twrp.flags` 的 `/metadata` 策略。

### Q13. 是否存在明显的硬件/内核/Android 版本兼容性障碍？

- **硬件**：无根本障碍；fbdev/evdev/USB 都有验证。
- **内核**：4.9 已在同硬件启动 Android 15 recovery；Android 16 需实测，但比 3.10 风险低。
- **Android 版本**：AERA 16 的 userspace 是主要不确定项；64 MiB 分区是硬约束；FDE 是功能缺口风险。
- **bootloader**：OPPO 自定义证书路径已由 Lineage 22.1 验证；`fastboot boot` 支持未知。

### Q14. 如果完全适配，预估工作量和难度？

- 设备树 + 首次构建：2–4 个工作日（含源码同步/排错）；
- Stage 1–4（启动/显示/触摸/ADB/分区）：3–7 个工作日；
- Stage 5–6（刷写/sideload）：3–5 个工作日；
- Stage 7（FDE）：3–10 个工作日，取决于 AERA 16 是否保留 legacy crypto；
- Stage 8（MTP/WiFi/Remote/插件）：1–3 周。

难度：**中高**。不是“改个设备名”的难度，但也不是“重写 recovery/kernel”的难度。关键路径是 Android 16 userspace 与 64 MiB 分区。

## 3. 最终判定

当前：**PARTIALLY FEASIBLE（构建成功，运行时失败；项目已放弃）**。

已满足：

- `recovery.img` 构建成功；
- header v0 / page 2048；
- kernel 与预编译 `Image.gz-dtb` SHA-256 一致；
- ramdisk gzip 可解，含 `system/bin/recovery`、fstab、vintf、init rc；
- 尾部 1,280 B OPPO 证书；
- 总大小 45,681,920 B < 67,108,864 B；
- 设备树静态检查 38/38 PASS。

**未满足**：设备刷入后卡第一屏，未进入 AERA UI；`adb` / `fastboot` 均不可见，未取得日志。根因未定位。

项目所有者已放弃继续 bring-up；本仓库保留构建与失败记录，供后续研究者参考。**该镜像不应作为可刷写镜像分发。**
