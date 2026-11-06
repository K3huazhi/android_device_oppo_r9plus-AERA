# Touch / input

## 1. 设备树

本机 `getevent -pl`：

```text
add device 1: /dev/input/event1
  name: "synaptics-s3508"
  events:
    KEY: BTN_TOUCH, KEY_HOME, KEY_MENU, KEY_BACK, ...
    ABS_MT_SLOT          min 0 max 9
    ABS_MT_POSITION_X    min 0 max 1080
    ABS_MT_POSITION_Y    min 0 max 1920
    ABS_MT_TRACKING_ID   min 0 max 65535
    ABS_MT_TOUCH_MAJOR   min 0 max 255
  input props: INPUT_PROP_DIRECT
```

| 设备 | event | 作用 | 处理 |
|---|---|---|---|
| `synaptics-s3508` | `event1` | 主触摸，MT-B，1080×1920 | AERA 使用 |
| `synaptics-s3508-kpd` | `event2` | 触摸按键 HOME/MENU/BACK | keylayout |
| `synaptics,s1302` | `event3` | 另一触摸节点/旧面板 | 备用 |
| `hbtp_vm` | `event4` | OPPO 虚拟鼠标 | **blacklist** |
| `input_mt_wrapper` | `event0` | MT 包装器 | 不作为主设备 |
| `qpnp_pon` | `event5` | Power | 按键 |
| `gpio-keys` | `event6` | Volume/Home | 按键 |
| ALSA jacks | `event7/8` | 耳机/按键 | 忽略 |

## 2. AERA 输入实现

`minuitwrp/events.cpp`：

- 打开 `/dev/input`，遍历 `event*`；
- `EVIOCGNAME` 读取设备名；
- 读取 `EVIOCGBIT(EV_ABS)` 和 `EVIOCGABS(ABS_MT_POSITION_X/Y)`；
- 支持 `ABS_MT_SLOT`（MT-B）；
- 读取 `EVIOCGBIT(EV_KEY)` 判断 `BTN_TOUCH`；
- 支持 `TW_INPUT_BLACKLIST`（按设备名，`\n` 分隔）；
- 读取 `/system/usr/keylayout/<device>.kl` 做按键映射。

AERA 16 的 `events.cpp` 还包含鼠标检测、`qcom-hv-haptics` 排除等逻辑；对本机没有影响。

## 3. 设备树配置

```make
AERA_INPUT_BLACKLIST := "hbtp_vm"
```

`hbtp_vm` 是 OPPO 的虚拟鼠标节点（`event4`，REL_X/REL_Y + BTN_MOUSE）。如果不屏蔽，AERA 可能把它当成鼠标，显示光标并干扰触摸。

## 4. Keylayout

已复制到 recovery root：

- `gpio-keys.kl`：VOLUME_UP/DOWN、HOME、FOCUS、CAMERA
- `synaptics_s1302.kl`：APP_SWITCH、BACK（虚拟）
- `synaptics_dsx.kl`：备用

AERA 的按键处理不依赖 system 的 `Generic.kl`；这些文件放在：

```text
/recovery/root/system/usr/keylayout/
```

构建后应出现于 ramdisk 的 `/system/usr/keylayout/`。

## 5. 触摸坐标 / 旋转

- 面板原生 portrait：X 0..1080，Y 0..1920；
- AERA `portrait_hdpi` 主题按 1080×1920 布局；
- 不需要 `TW_ROTATION` 或坐标交换；
- 如果实际触摸 Y 轴反向，优先检查 kernel DT 的 `synaptics,swap-axes`，不要在 AERA core 里改。

## 6. 风险

| 风险 | 说明 | 缓解 |
|---|---|---|
| AERA 选中 `input_mt_wrapper` | 它也有 ABS_MT 但无 BTN_TOUCH | 若触摸无效，把 `input_mt_wrapper` 加入 blacklist |
| 4.9 内核设备名变化 | 可能变成 `synaptics-s3508` 或 `synaptics_s3508` | keylayout 同时提供两种命名；AERA 按设备名查找 |
| 触摸按键映射错误 | CM keylayout 使用 `VIRTUAL` | 首版依赖屏幕 UI；硬件键仅作 fallback |
| 多触点抖动 | OPPO 触摸固件 | AERA MT-B slot 处理；必要时在 DT 调整 |
| 触摸唤醒/双击 | 非 recovery 必需 | 不启用 |

## 7. 结论

**触摸路径可行性高。** 4.9 recovery defconfig 明确包含：

```text
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_SYNAPTICS_OPPO=y
CONFIG_INPUT_HBTP_INPUT=y
```

并且 TWRP 3.7.x 在同一设备上已经使用 `hbtp_vm` blacklist。首版最可能需要调的只是 blacklist 是否要再加 `input_mt_wrapper`。
