# Feasibility — provisional assessment

> 状态：**AOSP 16 源码已同步，静态验证通过；本机 16 GB RAM 未能完成 Soong 分析，因此没有 `recovery.img`，也没有设备启动。**

## 1. 结论

**PARTIALLY FEASIBLE**

设备树、内核、FDT、OPPO 证书、分区/fstab/显示/触摸/ADB 路径均已建立并通过静态校验。未完成的是**构建主机能力**，不是已证实的 R9 硬件障碍：

- 16 GB 物理 RAM / 13.6 GB WSL 在全量 AOSP 16 Soong 分析阶段耗尽内存与 12–15 GB swap；
- 裁剪 AOSP 模块会触发 `aconfig_declarations` 缺失/依赖环，不能作为受支持的构建方式；
- 需要 ≥64 GB RAM 的 Linux 主机或完整 AERA CI 环境才能产出镜像。

因此本结论不是 **FEASIBLE**（没有镜像/设备证据），也不是 **BLOCKED**（没有证据表明 R9 硬件/内核不可用）。

理由：

1. 设备有独立 64 MiB `recovery` 分区，A-only；
2. 同一硬件的 LineageOS 22.1 已用 4.9 recovery 内核 + fbdev + evdev 启动；
3. AERA 16 有 fbdev 后端和 evdev MT-B 输入；
4. AERA 支持传统 A-only + 独立 recovery；
5. 设备树可以复用 TWRP 的 fstab/flags；
6. 预编译内核和 OPPO 证书路径明确；
7. 不需要修改 Android 7.1 的 boot/system。

如果后续在 64 GB 主机上出现以下任一项，则可能降级为 **BLOCKED**：

- AERA 16 二进制在 4.9 内核上无法启动；
- AERA ramdisk 压缩后超过约 53.4 MiB；
- AERA 16 的 crypto 与 CM14.1 FDE 不兼容（只影响加密功能）；
- OPPO aboot 拒绝未签名的自定义 image（证书路径失败）。

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

## 3. 最终判定条件

升级为 **FEASIBLE**：

- `recovery.img` 构建成功；
- header/ramdisk/证书静态校验通过；
- 设备启动到 AERA UI，显示/触摸/ADB/分区识别正常。

当前 **PARTIALLY FEASIBLE** 的具体原因：

- 设备树/内核/证书/静态布局成立；
- 但本机 16 GB RAM 未能完成 AOSP 16 Soong 分析，镜像未生成；
- 尚无设备启动、显示、触摸、ADB 的运行时证据。

若后续在 64 GB 主机上镜像可构建但出现以下情况，仍为 PARTIALLY FEASIBLE：

- 能启动，但显示/触摸/ADB/分区之一不可用；
- 或镜像可构建但超过 64 MiB，需裁剪；
- 或加密不可用。

**BLOCKED**：

- 4.9 内核无法启动 AERA 16 userspace，且无法通过最小内核修改解决；
- 或 OPPO aboot 拒绝自定义 recovery，且无临时启动/EDL 回退；
- 或 AERA 16 的 ramdisk 无论怎么裁剪都超过 64 MiB。
