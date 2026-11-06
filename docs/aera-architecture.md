# AERA architecture

## 1. 项目定位

AERA Recovery 是一个**独立的 Android recovery 环境**，不是 TWRP 主题包：

- 原生 recovery 二进制；
- LVGL 界面（`aeraui`）；
- 设备感知 OTA；
- 网络（Wi-Fi / 远程）；
- 运行时插件；
- 备份、刷写、文件管理、终端、root 管理。

官方网站：<https://aera-recovery.com/>
源码组织：<https://github.com/AERA-Recovery>

## 2. 源码基线

| 项目 | 值 |
|---|---|
| 分支 | `aera-16.0` |
| Android 平台 | Android 16（API 36） |
| 基线 | AOSP recovery + TWRP/OrangeFox 继承代码 |
| recovery core | `AERA-Recovery/android_bootable_recovery` |
| vendor build system | `AERA-Recovery/android_vendor_recovery` |
| TWRP build system fork | `AERA-Recovery/android_vendor_twrp` |
| UI | `external/lvgl` + `aeraui` |
| manifest | `AERA-Recovery/android_manifest` |
| 设备树 | 独立仓库，不放进公共 manifest |

本地源码：[`sources/aera/recovery-src`](../sources/aera/recovery-src)

## 3. manifest 结构

AERA manifest 分四层：

```text
default.xml          AOSP Android 16.0.0_r1 全量项目
twrp-default.xml     TWRP/Lineage/AERA 覆盖；替换 recovery 相关项目
aera.xml             AERA 专属 recovery/LVGL/工具项目
remove-minimal.xml   删除 recovery 不需要的 AOSP 项目
```

`twrp-default.xml` 本身不包含 AOSP 基础项目，必须叠加在 `default.xml` 上。我们的 WSL 构建脚本把四层合并成 `.repo/manifests/merged.xml`，按以下顺序展开：

```text
default.xml
twrp-default.xml (去掉 <include>)
aera.xml
remove-minimal.xml
```

这样避免了 repo 对 `<include>` 相对路径和 `remove-project` 顺序的歧义。

## 4. 构建系统

AERA 使用 AOSP `m`/`mka`，不是独立的 CMake/Meson：

```bash
source build/envsetup.sh
lunch twrp_<device>-bp2a-eng
mka adbd recoveryimage
```

设备树采用 TWRP 命名惯例：

```text
device/<vendor>/<codename>/
  AndroidProducts.mk
  BoardConfig.mk
  device.mk
  twrp_<codename>.mk
  aera_<codename>.mk
  recovery/root/...
  prebuilt/...
```

配置前缀：

- `AERA_*`：设备树公开配置（推荐）；
- `TW_*` / `OF_*`：AERA 内部兼容名，由 `aera_config.mk` 映射。

例：

```make
AERA_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
AERA_MAX_BRIGHTNESS := 255
AERA_INPUT_BLACKLIST := "hbtp_vm"
```

映射到：

```make
TW_BRIGHTNESS_PATH := ...
TW_MAX_BRIGHTNESS := ...
TW_INPUT_BLACKLIST := ...
```

## 5. 图形栈

AERA 的 `minuitwrp/graphics.cpp` 依次尝试：

1. `open_overlay()` — MSM overlay；
2. `open_drm()` — DRM/KMS；
3. `open_fbdev()` — `/dev/graphics/fb0`。

R9 Plusm A 没有现代 DRM 用户空间路径，走 fbdev。AERA 的 `graphics_fbdev.cpp` 与本机 fb0 参数匹配（1080×1920×32，stride 4352，双缓冲）。

## 6. 输入栈

AERA 的 `minuitwrp/events.cpp`：

- 扫描 `/dev/input/event*`；
- 读取 `EVIOCGNAME` / `EVIOCGBIT` / `EVIOCGABS`；
- 支持 MT-B（`ABS_MT_SLOT`）；
- 读取 `/system/usr/keylayout/<name>.kl`；
- 支持 `TW_INPUT_BLACKLIST`。

## 7. USB / ADB

AERA 使用：

- `adbd`（recovery 版本）；
- FunctionFS + configfs；
- `init.recovery.usb.rc`；
- `sys.usb.config` 属性状态机。

R9 的 4.9 内核有 `CONFIG_USB_CONFIGFS_F_FS`，所以 ADB 路径成立。

## 8. 存储 / 刷写

AERA 继承 TWRP 的：

- `recovery.fstab`（AOSP 风格）；
- `twrp.flags`（TWRP v1 风格）；
- `TWPartitionManager`；
- ZIP / image / sideload 刷写；
- backup/restore。

设备树只需提供正确的 fstab/flags，不需要改 AERA core。

## 9. 加密

AERA 16 的 crypto 代码基座来自 TWRP/OrangeFox，但 Android 16 的 `vold` 主要面向 FBE。R9 的 CM14.1 是 FDE footer，因此：

- 首版关闭 crypto；
- Stage 7 再验证 FDE 是否仍被 AERA 16 支持；
- 不把 FBE 配置强加到 FDE 设备。

## 10. 修改原则

优先顺序：

1. device tree（BoardConfig / product / fstab / init / sepolicy / prebuilt）；
2. kernel（预编译复用，必要时最小修改）；
3. vendor blobs；
4. AERA core（只有确认是设备无关的框架 bug 才改）。

本项目目前**没有修改 AERA core**。

## 11. 版本

`aera_build.mk` 定义：

```make
AERA_INTERNAL_RELEASE := R1.0
AERA_BUILD_TYPE := Alpha/Beta/Nightly/Stable
AERA_BUILD_STATUS := Official/Unofficial
```

本项目使用 `Alpha` + `Unofficial`，避免冒充官方构建。

## 12. 结论

AERA 的架构对 R9 这种“老平台 + 独立 recovery + fbdev + evdev”设备是友好的：

- 不需要 GKI / vendor_boot / dynamic partitions；
- 不需要 DRM；
- 不需要 A/B；
- 可以通过预编译 kernel + device tree 完成首版。

真正的架构风险在 Android 16 用户空间与 4.9 内核的兼容性，而不是 AERA 的 recovery 框架本身。
