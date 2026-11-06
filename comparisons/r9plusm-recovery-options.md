# R9 Plusm A recovery options

## 1. 可选方案

| 方案 | 来源 | 内核 | Android 用户空间 | 显示/触摸 | 加密 | 维护性 | 结论 |
|---|---|---|---|---|---|---|---|
| 原厂 OPPO recovery | 出厂 | 3.10 | OPPO 5.1 | 可用 | 原厂 | 低 | 仅作回退 |
| CM14.1 自带 recovery | CM 构建 | 3.10 | CM 7.1 | 可用 | FDE | 已停止 | 仅作历史基线 |
| TWRP 3.7.1_12-Alpha4 | TipzTeam | 4.9 | TWRP 12.1 | 已验证 | FDE/FBE 组合 | 中 | 当前最稳 |
| LineageOS 22.1 recovery | Blueyfish | 4.9 | Lineage 15 | 已验证 | FBE/FDE? | 中 | 现代基线 |
| **AERA 16** | AERA | **4.9（复用）** | **Android 16** | **fbdev/evdev 可行** | **待验证** | **高** | **本项目目标** |

## 2. 为什么不是“直接刷 TWRP”

TWRP 3.7.x 已验证，但：

- 不是 AERA UI；
- 没有 AERA 的 OTA/网络/插件；
- Android 12.1 基线，长期维护性不如 AERA 16；
- 不能作为“AERA 设备适配”的最终产物。

TWRP 的价值是**基线**：它证明了内核、显示、触摸、USB、分区路径。

## 3. 为什么不是“Lineage recovery”

LineageOS 22.1 recovery：

- 已验证 4.9 内核 + FDT + 显示/触摸/USB；
- 但 UI 是 AOSP/Lineage recovery，不是 AERA；
- 没有 AERA 的功能；
- 作为“内核/分区/证书”基线非常有价值。

## 4. 为什么 AERA 16 可行

- 4.9 内核已经在同一硬件上启动 Android 15 recovery；
- AERA 有 fbdev 后端；
- AERA 有 evdev MT-B 输入；
- AERA 支持传统 A-only + 独立 recovery；
- 设备树可以复用 TWRP 的 fstab/flags；
- 预编译内核 + OPPO 证书路径明确。

## 5. 为什么仍有风险

- Android 16 用户空间比 Android 15 更依赖新内核接口；
- AERA ramdisk 可能超过 64 MiB 分区；
- AERA 16 的 FDE 支持未确认；
- OPPO aboot 的 `fastboot boot` 支持未知；
- 老设备的 panel/触摸第一次启动可能需要调参。

## 6. 推荐路线

```
TWRP/Lineage 4.9 kernel + FDT
        +
AERA 16 recovery ramdisk
        +
R9 device tree (fstab/flags/init/display/touch)
        +
OPPO 1,280-byte recovery certificate
        =
recovery.img (v0, 64 MiB)
```

首版只追求：

1. 能启动；
2. 显示；
3. 触摸；
4. ADB；
5. 分区识别。

ZIP/刷写/sideload/加密/MTP 逐阶段加入。

## 7. 不推荐路线

- 把 OnePlus/Qualcomm 现代设备树直接改个名字；
- 用 3.10 内核硬跑 Android 16；
- 把 AERA 主题塞进 TWRP 冒充 AERA；
- 改 GPT 以“适配” AERA；
- 未备份就刷 recovery。
