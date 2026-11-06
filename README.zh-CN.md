# AERA Recovery — OPPO R9 Plusm A (`r9plus`) 适配研究

本仓库是 **OPPO R9 Plusm A / R9PlustmA（`R9PlusA`，MSM8976）** 的 AERA Recovery 设备适配研究、设备树与验证记录。

> 当前结论：**PARTIALLY FEASIBLE**。设备身份、分区表、boot/recovery 格式、4.9 内核/FDT、显示/触摸/USB 路径、OPPO 证书均已验证；设备树静态检查 38/38 通过。由于构建主机只有 16 GB RAM，AOSP 16 Soong 分析未完成，因此仓库中**没有可启动的 `recovery.img`**。这不是已证实的 R9 硬件障碍。

- 仓库：<https://github.com/K3huazhi/android_device_oppo_r9plus-AERA>
- 研究快照：<https://github.com/K3huazhi/android_device_oppo_r9plus-AERA/releases/tag/v0.1-research>

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

## 2. 已验证的关键事实

| 项目 | 结果 |
|---|---|
| 独立 recovery 分区 | `mmcblk0p25`，64 MiB |
| A/B / 动态分区 | 无，A-only |
| boot/recovery header | v0，page size 2048 |
| kernel 格式 | `Image.gz` + 242,901 B appended FDT |
| OPPO 证书 | recovery 尾部 1,280 B DER（`30 82 04 fc`） |
| recovery 内核 | Linux 4.9.337，复用 LineageOS 22.1 |
| 显示 | fbdev `/dev/graphics/fb0`，RGBX_8888，stride 4352 |
| 触摸 | `synaptics-s3508`，MT-B，1080×1920 |
| ADB/USB | configfs + FunctionFS，UDC `msm_hsusb` |
| 存储 | ext4 system/data/cache，f2fs data，SD/OTG |
| 加密 | CM14.1 是 FDE footer，不是 FBE |
| 静态检查 | **38/38 PASS** |

---

## 3. 研发思路

### 3.1 先锁定设备，而不是先找“看起来像”的 ROM

只用只读 ADB/sysfs 读取 `getprop`、`/proc/cpuinfo`、`/proc/partitions`、`by-name`、`wm size`、`getevent`、framebuffer/backlight。用 fingerprint + product/device/codename + SoC + 分区表交叉确认。

### 3.2 用实际分区表建立模型

以本机 `/proc/partitions` 和 `by-name` 为主，CM14.1 的 `partition.txt` 为交叉证据。确认 boot/recovery 各 64 MiB、system 2 GiB、userdata 约 55.2 GiB、无 vendor/metadata/dtbo/super/vbmeta。

### 3.3 反解 boot image，而不是假设格式

解析 LineageOS 22.1 的 `boot.img` / `recovery.img`：v0 header、gzip Image + appended FDT、OPPO DER 尾证书。`tools/patch_oppo_image.py` 可以把提取的证书追加回镜像，并字节级复现原 Lineage recovery.img。

### 3.4 用 TWRP + Lineage 双基线

- TWRP 3.7.x R9Plus：fstab、twrp.flags、亮度、像素格式、触摸 blacklist；
- LineageOS 22.1 recovery：4.9 内核、FDT、OPPO 证书、真实启动验证。

不复制现代 OnePlus/Qualcomm 设备树。

### 3.5 把差异全部放进 device tree

AERA core 不改；只做：

- v0 boot image；
- 独立 recovery；
- fbdev；
- evdev MT-B；
- configfs ADB（`msm_hsusb`）；
- 首版关闭 FDE；
- 预编译 4.9 recovery 内核。

### 3.6 分阶段 bring-up

Stage 1 启动 → Stage 2 显示/触摸/按键 → Stage 3 ADB/USB → Stage 4 分区/挂载 → Stage 5 system/vendor/data → Stage 6 ZIP/image/sideload → Stage 7 加密 → Stage 8 MTP/WiFi/其他。

---

## 4. 为什么没有 `recovery.img`

构建主机：Windows 11 + WSL2，13.6 GB RAM，32 GB swap。AOSP 16 全量 Soong 分析耗尽内存并持续使用 12–15 GB swap，20+ 分钟未完成；裁剪 AOSP 模块会触发 `aconfig_declarations` 缺失和 `Connectivity` ↔ `cronet` 依赖环。

完整记录：[`conclusions/build-attempt.md`](conclusions/build-attempt.md)。

需要在 **≥64 GB RAM 的 Linux 主机**上，保留完整 AOSP 树：

```bash
source build/envsetup.sh
lunch twrp_r9plus-bp2a-eng
mka -j16 adbd recoveryimage

python3 tools/patch_oppo_image.py \
  out/target/product/r9plus/recovery.img \
  device/oppo/r9plus/prebuilt/oppo_boot.patch

python3 tools/static_check.py
python3 tools/parse_bootimg.py out/target/product/r9plus/recovery.img
```

预期：header v0、kernel ≈10.56 MiB、page 2048、gzip ramdisk、1,280 B 证书、≤64 MiB。

---

## 5. 仓库结构

```text
device/oppo/r9plus/       AERA 设备树 + 预编译内核 + OPPO 证书
docs/                     证据与设计文档
comparisons/              AERA vs TWRP、设备树、recovery 方案比较
conclusions/              feasibility、风险、构建日志、静态校验
sources/live/             本机只读 ADB/sysfs 证据
sources/aera/             AERA manifest 快照
sources/device/           CM14.1 / LineageOS 22.1 设备树快照
sources/recovery/         TWRP R9Plus 基线树
sources/kernel/           4.9.337 recovery defconfig + version
sources/other/            公开 release 元数据与 hash
tools/                    image parser、OPPO patcher、静态检查、WSL 脚本
```

---

## 6. 安全边界

本阶段没有执行任何设备写入：

- 没有 `fastboot flash`、`erase`、`format`、`reboot`；
- 没有修改 boot/recovery/system/userdata/GPT；
- 没有开启 root 或修改 persist。

刷机前必须备份、确认回退路径，并获得明确授权。见 [`docs/bringup.md`](docs/bringup.md)。

---

## 7. 主要来源

- AERA Recovery: <https://github.com/AERA-Recovery/android_bootable_recovery>
- AERA 官网: <https://aera-recovery.com/>
- LineageOS 22.1 R9Plus: <https://github.com/BlueyfishReleases/R9Plus>
- TWRP R9Plus 基线: <https://codeberg.org/TipzTeam/recovery_device_oppo_thortanium>
- CM14.1 R9Plus: <https://github.com/wuxianlin/android_device_oppo_r9plus>
- LineageOS 21/22.1 R9Plus: <https://github.com/blueyfish/android_device_oppo_R9Plus>
- Kernel: <https://github.com/blueyfish/android_kernel_oppo_msm8937>（`lineage-22.1`）

---

## 8. 许可

GPL-3.0-or-later。第三方归属见 [`NOTICE`](NOTICE)。
