# Display

## 1. 硬件路径

```
MSM8976 MDSS
   └─ qcom,mdss_fb_primary
        └─ /dev/graphics/fb0
             ├─ 1080 × 1920
             ├─ 32 bpp
             ├─ stride 4352 (1088 px × 4)
             └─ virtual 1080 × 3840 (double buffer)
```

本机 sysfs：

```text
/sys/class/graphics/fb0/virtual_size = 1080,3840
/sys/class/graphics/fb0/stride       = 4352
/sys/class/graphics/fb0/bits_per_pixel = 32
/sys/class/graphics/fb0/modes        = U:1080x1920p-0
```

背光：

```text
/sys/class/leds/lcd-backlight/max_brightness = 255
/sys/class/leds/lcd-backlight/brightness     = 0 (息屏)
```

## 2. AERA 图形后端

AERA 的 `minuitwrp/graphics.cpp` 初始化顺序：

1. `open_overlay()` — MSM overlay（旧设备通常失败/不可用）；
2. `open_drm()` — `/dev/dri/card0`（本机 4.9 kernel 没有可用的 DRM/KMS 用户空间路径）；
3. `open_fbdev()` — `/dev/graphics/fb0`。

本机没有 `/dev/dri`，所以会走 **fbdev**。这不是降级方案，而是 TWRP/Lineage 在该设备上一直使用的路径。

`graphics_fbdev.cpp` 关键行为：

- 打开 `/dev/graphics/fb0`（重试 20 次，每次 100 ms，等待 init 创建节点）；
- `FBIOGET_VSCREENINFO` / `FBIOGET_FSCREENINFO`；
- 用 `fi.line_length` 作为 `row_bytes`；
- 32bpp 时选择 `GGL_PIXEL_FORMAT_RGBX_8888`；
- 如果 `smem_len >= yres * line_length * 2`，启用双缓冲；
- 通过 `FBIOPUT_VSCREENINFO` 的 `yoffset` 翻页。

这与本机 `stride=4352`、`virtual_size=1080x3840` 完全匹配。

## 3. AERA 设备树配置

```make
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
RECOVERY_GRAPHICS_USE_LINELENGTH := true
AERA_THEME := portrait_hdpi
AERA_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
AERA_MAX_BRIGHTNESS := 255
AERA_DEFAULT_BRIGHTNESS := 127
AERA_SCREEN_H := 1920
AERA_STATUS_H := 72
AERA_FRAMERATE := 60
AERA_SCREEN_BLANK_ON_BOOT := true
```

`AERA_SCREEN_BLANK_ON_BOOT` 对应 TWRP 的 `TW_SCREEN_BLANK_ON_BOOT`，用于规避部分 MSM 面板在 recovery 首次打开时的花屏/黑屏。

## 4. init 处理

`init.recovery.qcom.rc` 在 `on init` 写一次：

```text
write /sys/class/leds/lcd-backlight/brightness 127
```

AERA 启动后由 `TW_BRIGHTNESS_PATH` 接管亮度调节。`graphics_fbdev.cpp` 的 `fbdev_blank()` 会用 `TW_BRIGHTNESS_PATH` 写 `000` / `127`，所以路径必须是 `lcd-backlight`，不能照抄现代 Lineage 的 `panel0-backlight`。

## 5. 风险

| 风险 | 说明 | 缓解 |
|---|---|---|
| 首次打开黑屏 | MSM fb 在 bootloader 交接时可能保持 blank | `AERA_SCREEN_BLANK_ON_BOOT` + init 写亮度 |
| 颜色错乱 | 面板可能实际为 BGRA/BGRX | 先用 RGBX_8888（TWRP 已验证）；若红蓝反了改 `RECOVERY_BGRA` |
| 行宽错位 | 1080 不是 32 字节对齐，stride 4352 | `RECOVERY_GRAPHICS_USE_LINELENGTH` + AERA 读取 `fi.line_length` |
| 双缓冲花屏 | `smem_len` 不足或 yoffset 不支持 | AERA 已检测 `smem_len`；失败时退回单缓冲 |
| 亮度节点不存在 | 4.9 内核可能同时暴露 `panel0-backlight` | 以 `lcd-backlight` 为准；必要时在 init 里做 fallback |

## 6. 结论

**显示路径可行性高。** 本机 fbdev 参数、TWRP 配置、AERA fbdev 后端三者一致；真正需要设备验证的是颜色顺序和首次 blank 行为。
