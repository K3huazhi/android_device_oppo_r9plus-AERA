# ADB / USB

## 1. 当前系统状态

```text
sys.usb.config          = mtp,adb
persist.sys.usb.config  = mtp,adb
sys.usb.controller      = msm_hsusb
/sys/class/udc/msm_hsusb/state = not attached
```

`adb devices -l`：

```text
2ad9e8ea  device product:R9PlustmA model:OPPO_R9_Plustm_A device:R9PlusA
```

说明：

- 设备 USB 控制器是 **`msm_hsusb`**；
- Windows ADB 已能识别；
- 当前不是通过 configfs 属性判断，但 4.9 recovery 内核的 defconfig 明确有 `CONFIG_USB_CONFIGFS=y` / `CONFIG_USB_CONFIGFS_F_FS=y`。

## 2. Recovery 中 AERA 的 ADB 路径

AERA 的 `adbd` 运行在 recovery ramdisk 内，使用 FunctionFS：

```
/config/usb_gadget/g1/functions/ffs.adb
        │
        ▼
/dev/usb-ffs/adb  (functionfs)
        │
        ▼
adbd  (AERA 的 minadbd / adbd)
        │
        ▼
USB UDC msm_hsusb
```

AERA 的 `init.recovery.usb.rc` 负责：

- 创建 `ffs.adb`、`ffs.mtp`、`ffs.fastboot`；
- mount functionfs；
- 在 `sys.usb.config=adb` 时 `start adbd`；
- 在 `sys.usb.ffs.ready=1` 时把 `ffs.adb` 链接到 `b.1/f1` 并写 UDC。

本设备树已复制/适配该 rc，并把 UDC 固定为 `msm_hsusb`。

## 3. 关键属性

设备树 cmdline：

```text
androidboot.usbconfigfs=true
androidboot.usbcontroller=msm_hsusb
```

init rc：

```text
on early-init
    setprop sys.usb.configfs 1
    setprop sys.usb.controller msm_hsusb
```

这样即使 bootloader 没有传 `ro.boot.usbcontroller`，recovery 也能完成 UDC 绑定。

## 4. ADB 安全

AERA recovery 的 adbd 通常以 root 运行，不需要 `adb root`。在 Windows 上首次连接可能出现新 RSA key 提示；如果 recovery 的 `ro.adb.secure=1` 且没有 `adb_keys`，需要把公钥放到 ramdisk 的 `/adb_keys` 或使用 `ro.adb.secure=0`。

**首版建议：** 在 recovery 的 `prop.default` / product property 中确认：

```text
ro.adb.secure=0
ro.debuggable=1
```

AERA 的 build 通常会设置 `ro.debuggable=1`；若没有，在设备树 `system.prop` 中补。当前设备树尚未加 `system.prop`，构建后检查。

## 5. MTP / FastbootD

| 功能 | 首版 | 说明 |
|---|---|---|
| ADB | ✅ 目标 Stage 3 | 优先 |
| ADB sideload | ✅ 目标 Stage 6 | minadbd 需要 FunctionFS |
| MTP | ⏸ Stage 8 | 需要 `ffs.mtp` + AERA MTP 服务；本机 4.9 内核有 `CONFIG_USB_CONFIGFS_F_MTP` |
| FastbootD | ⏸ 延后 | 需要 userspace fastboot + 动态分区；本机无 super，首版关闭 |
| USB 存储 | ⏸ 延后 | 需要 mass_storage 配置；TWRP 有，但 AERA 16 默认 UI 可能不同 |

## 6. 风险

| 风险 | 说明 | 缓解 |
|---|---|---|
| UDC 名称不是 `msm_hsusb` | 4.9 内核可能叫 `msm_hsusb` 或 `a600000.ssusb` | 已硬编码 `msm_hsusb`；启动日志确认后可改 |
| configfs 未挂载 | AERA generic init 可能不挂 `/config` | 在 `init.recovery.qcom.rc` 加 `mount configfs none /config`（如缺失） |
| 默认 USB init 冲突 | AERA generic 也会配置 USB | 设置 `AERA_EXCLUDE_DEFAULT_USB_INIT := true` |
| Windows 驱动 | OPPO VID/PID 可能需要驱动 | ADB 使用 Google VID/PID 0x18D1:0x4EE7，通常免驱 |
| 充电口接触/线材 | 旧设备 | 换线、换口验证 |

## 7. 结论

ADB 是首版最可能一次成功的功能之一：4.9 内核 configfs + FunctionFS 已在 TWRP/Lineage recovery 中验证；AERA 只需要正确的 UDC 名称和 init rc。
