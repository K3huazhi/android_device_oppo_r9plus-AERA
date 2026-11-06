# AERA vs TWRP

## 1. 关系

AERA 不是从零写的 recovery；它继承了 TWRP/OrangeFox 的大量基础设施：

- 分区管理 / fstab / twrp.flags；
- ZIP / image / sideload 刷写；
- backup / restore / tar；
- crypto 基座；
- minui / minuitwrp / pixelflinger；
- adbd / minadbd；
- 设备树构建约定。

AERA 的差异主要在：

- 原生 LVGL UI（`aeraui`）；
- AERA 自己的 OTA / 网络 / 插件 / 远程；
- Android 16 的构建基线；
- 新的 `AERA_*` 配置命名；
- 更现代的 SoC/设备支持（GKI、vendor_boot、A/B）。

## 2. 对本项目的意义

| 方面 | TWRP 3.7.x | AERA 16 |
|---|---|---|
| 设备树格式 | `BoardConfig.mk` + `twrp_<device>.mk` | 类似，但 `AERA_*` |
| fstab / flags | 支持 | 支持 |
| fbdev | 支持 | 支持（`graphics_fbdev.cpp`） |
| evdev MT-B | 支持 | 支持 |
| Android 版本 | 12.1 基线 | 16 |
| 内核 | 4.9 recovery | 4.9 recovery（复用） |
| FDE | TWRP legacy crypto | 需验证 |
| 分区 | 传统 A-only | 传统 A-only 可用 |
| UI | TWRP 主题 | LVGL 原生 |

## 3. 为什么不能直接把 TWRP 当 AERA

- AERA 的 UI 不是 TWRP 主题，不能通过换主题得到；
- AERA 的构建系统和 Android 16 用户空间不同；
- AERA 的 OTA/网络/插件不是 TWRP 的功能；
- 但**底层设备适配可以大量复用 TWRP**，这正是本项目的策略。

## 4. 为什么 AERA 比 TWRP 更适合作为长期目标

- 原生 UI，不依赖 TWRP 主题/分辨率适配；
- 设备感知 OTA；
- 网络/远程/插件；
- 更活跃的 Android 16 基线；
- 更容易维护独立的 `android_device_oppo_r9plus-AERA`。

## 5. 风险对比

| 风险 | TWRP 3.7.x | AERA 16 |
|---|---|---|
| 老内核兼容 | 已验证 | 待验证（4.9 已启动 Android 15） |
| 镜像大小 | 23.9 MB recovery | 可能更大，需 ≤64 MiB |
| UI 分辨率 | 现成主题 | LVGL 自适应，但需验证 |
| 加密 | 已有 FDE/FBE 组合 | FDE 需验证 |
| 维护性 | TWRP 12.1 基线 | Android 16 基线，长期更好 |

## 6. 结论

AERA 是“TWRP 的设备适配经验 + 原生 UI/现代 recovery 功能”的组合。对 R9 这种老设备，正确做法是：

> 用 TWRP/Lineage 验证过的底层（内核、fstab、display、touch、USB），加上 AERA 的 recovery 用户空间和 UI。

而不是把 TWRP 主题伪装成 AERA，也不是把现代 GKI 设备树硬套到 R9。
