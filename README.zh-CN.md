# AERA Recovery — OPPO R9 Plusm A (`r9plus`) 适配研究

本仓库是 **OPPO R9 Plusm A / R9PlustmA（`R9PlusA`，MSM8976）** 的 AERA Recovery 设备适配研究、设备树、构建记录与静态验证材料。

> 当前结论：**FEASIBLE（构建与静态校验层面）**。  
> `recovery.img` 已成功构建并通过静态校验，但**尚未刷入设备**，运行时未验证。

- 仓库：<https://github.com/K3huazhi/android_device_oppo_r9plus-AERA>
- 研究快照：<https://github.com/K3huazhi/android_device_oppo_r9plus-AERA/releases/tag/v0.1-research>
- 构建产物：<https://github.com/K3huazhi/android_device_oppo_r9plus-AERA/releases/tag/v0.2-build>

---

## 1. 设备身份

| 字段 | 值 |
|---|---|
| 市场名 | OPPO R9 Plusm A |
| 设备实际报告 | `OPPO R9 Plustm A`（厂商字符串） |
| Product | `R9PlustmA` |
| Device | `R9PlusA` |
| CM codename | `r9plus` |
| Fingerprint | `OPPO/R9PlusmA/R9PlusA:5.1.1/LMY47V/1390465867:user/release-keys` |
| SoC | Qualcomm **MSM8976**（Snapdragon 652），Adreno 510 |
| 当前 ROM | CyanogenMod 14.1 / Android 7.1 / API 25 |
| 屏幕 | 1080×1920，480 dpi |
| 分区 | A-only，**独立 64 MiB recovery** |

**不是** OPPO R9（MT6755）、R9 Plus 泛称、R9s、R9s Plus 或其他 R9 变体。

---

## 2. 构建结果

| 项目 | 值 |
|---|---|
| 产品 | `twrp_r9plus` |
| AERA | R1.0 / Android 16 / `BP2A.250605.031.A2` |
| 镜像大小 | **45,681,920 B（43.56 MiB）** |
| SHA-256 | `3d9ddd212219f221a100c76942510b266c5a98e2d43bac9f68a0334e6f18df45` |
| header | v0，page 2048 |
| kernel | 10,561,222 B，与 `prebuilt/Image.gz-dtb` SHA-256 一致 |
| ramdisk | 35,116,033 B gzip，3,650 个文件 |
| OPPO 证书 | 尾部 1,280 B（`30 82 04 fc`） |
| 静态检查 | 38/38 PASS |

下载：

<https://github.com/K3huazhi/android_device_oppo_r9plus-AERA/releases/download/v0.2-build/recovery-AERA-R1.0-r9plus.img>

**没有刷入设备。** 没有 `fastboot flash` / `fastboot boot` / `adb reboot` / 格式化 / 修改分区。

---

## 3. 构建思路

### 3.1 先锁定设备

只读读取 `getprop`、`/proc/cpuinfo`、`/proc/partitions`、`by-name`、`wm size`、`getevent -pl`、framebuffer/backlight。用 fingerprint + product/device/codename + SoC + 分区表交叉确认。

### 3.2 用实际分区表建立模型

`boot=mmcblk0p24`、`recovery=mmcblk0p25`，各 64 MiB；`system` 2 GiB；`userdata` 约 55.2 GiB；无 vendor/metadata/dtbo/super/vbmeta。

### 3.3 反解 boot image

v0 header、page 2048、`Image.gz` + 242,901 B FDT、recovery 尾部 1,280 B OPPO DER 证书。`tools/patch_oppo_image.py` 只替换最后一段，不动 header/kernel/ramdisk。

### 3.4 TWRP + Lineage 双基线

TWRP 提供 fstab/flags/亮度/触摸 blacklist；LineageOS 22.1 提供 4.9 内核、FDT、证书与真实启动证据。

### 3.5 差异隔离到 device tree

v0 image、独立 recovery、fbdev、evdev MT-B、configfs ADB、首版关闭 FDE、预编译内核。

### 3.6 用 NVMe swap 硬编译

构建主机只有 16 GB RAM。成功配置：

- WSL VHDX 与 swap 都放在 C: NVMe；
- WSL 12 GB RAM；
- 64 GB swap；
- 8 GB zram；
- `mka -j4`。

Soong 全量分析约 50–60 分钟，峰值 swap 约 27 GiB，未 OOM。此前 HDD swap 方案会严重抖动，无法完成。

---

## 4. 构建系统修补

AERA 的 `build/soong` fork 不注册 clang `Android.bp` 的 `llvm_prebuilt_library_*` 类型。`tools/build-patches/` 用标准 `cc_prebuilt_library_*` 重新暴露：

- `libc++` / `libc++_static` / `libc++abi` / `libc++demangle`；
- `libclang_rt.ubsan_minimal` / `builtins` / `builtins-exported`；
- `libunwind` / `libunwind-exported`；
- noexcept STL 变体；
- 必要的 `apex_available`、`ramdisk_available`、`no_libcrt`、头文件导出。

打包时若 `root/vendor` 符号链接与 TWRP `vendor/etc/vintf` 冲突，把 `out/.../root/vendor` 改为真实目录后直接 `ninja -f out/combined-twrp_r9plus.ninja recoveryimage` 续跑。

---

## 5. 仓库结构

```text
device/oppo/r9plus/       AERA 设备树 + 预编译内核 + OPPO 证书
docs/                     证据与设计文档
comparisons/              AERA vs TWRP、设备树、recovery 方案比较
conclusions/              feasibility、构建成功/失败、风险、静态校验
sources/live/             本机只读 ADB/sysfs 证据
sources/aera/             AERA manifest 快照
sources/device/           CM14.1 / LineageOS 22.1 设备树快照
sources/recovery/         TWRP R9Plus 基线树
sources/kernel/           4.9.337 recovery defconfig + version
tools/                    image parser、OPPO patcher、静态检查、WSL 脚本
tools/build-patches/      构建系统修补
```

---

## 6. 安全边界

- 没有 `fastboot flash`、`erase`、`format`、`reboot`；
- 没有修改 boot/recovery/system/userdata/GPT；
- 没有开启 root 或修改 persist。

刷机前必须备份、确认回退路径并获得明确授权。见 [`docs/bringup.md`](docs/bringup.md)。

---

## 7. 许可

GPL-3.0-or-later。第三方归属见 [`NOTICE`](NOTICE)。
