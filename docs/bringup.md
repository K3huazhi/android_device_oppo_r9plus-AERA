# Bring-up plan

> **当前未执行任何设备写入。** 以下所有 `fastboot flash` / `adb reboot` / `dd` / `format` 步骤都标记为 **REQUIRES USER CONFIRMATION**，在执行前必须逐项确认。

## Stage 0 — 静态与可恢复性准备

目标：在没有写入设备的情况下，确认镜像、分区、回退路径。

- [x] 设备身份、分区表、boot/recovery header 已确认；
- [x] 现有 TWRP 使用痕迹已确认；
- [x] LineageOS 22.1 recovery 基线已取得；
- [x] AERA 设备树已建立；
- [ ] `recovery.img` 构建完成；
- [ ] 镜像 header / ramdisk / 尾部证书静态校验；
- [ ] 备份原厂 boot / recovery（**REQUIRES USER CONFIRMATION**）。

### 备份（在 TWRP 中执行，需用户操作）

TWRP → Backup → 勾选 `Boot`、`Recovery`、`System`、`Data`（至少 Boot/Recovery），备份到外部 SD 或 OTG。

或在已 root 的 CM14.1 中：

```bash
adb shell su -c 'dd if=/dev/block/bootdevice/by-name/boot of=/sdcard/boot-original.img'
adb shell su -c 'dd if=/dev/block/bootdevice/by-name/recovery of=/sdcard/recovery-original.img'
adb pull /sdcard/boot-original.img
adb pull /sdcard/recovery-original.img
```

> 当前 adbd 是 shell，`su` 不可用；这一步需要用户先在开发者选项启用 root，或在 TWRP 中完成。

### 回退路径确认

- [ ] 能进入 TWRP（Power + Volume Down 或 `adb reboot recovery`）；
- [ ] 能进入 bootloader（Power + Volume Up? 需确认）；
- [ ] 能进入 EDL（OPPO 组合键/深刷工具，**UNKNOWN / NEEDS VERIFICATION**）；
- [ ] 有可用的原厂 recovery.img / boot.img；
- [ ] 有可用的 USB 线/Windows 驱动。

## Stage 1 — Recovery 启动

目标：kernel → init → AERA UI。

### 1.1 临时启动（优先）

如果 OPPO aboot 支持：

```bash
adb reboot bootloader
fastboot devices
fastboot boot recovery.img
```

**REQUIRES USER CONFIRMATION**：`fastboot boot` 不写分区，但会重启设备；且 OPPO aboot 是否支持 `fastboot boot` 未知。

如果返回：

```text
FAILED (remote: unknown command)
```

则说明不支持临时启动，必须进入 Stage 1.2。

### 1.2 写入 recovery 分区（仅在确认备份/回退后）

```bash
fastboot flash recovery recovery.img
fastboot reboot recovery
```

**REQUIRES USER CONFIRMATION**，并且必须满足：

1. 已备份原 recovery；
2. 已确认 `recovery` 分区为 `mmcblk0p25`，大小 64 MiB；
3. 已确认镜像 header v0 / 尾部证书；
4. 已确认能进入 TWRP/EDL；
5. 已确认镜像大小 ≤ 64 MiB。

### 1.3 观察点

- 屏幕是否亮起（背光/Logo）；
- AERA splash / UI 是否出现；
- 无显示时，通过 `adb devices` 是否能看到设备；
- 通过串口/`/proc/last_kmsg` 不可用，改用 `adb shell dmesg`（若 adbd 已起）。

### 1.4 失败处理

- 黑屏但 ADB 可用：Stage 2 显示问题；
- 无 ADB 且无显示：kernel/ramdisk/init 问题；
- 反复重启：检查 cmdline、fstab、SELinux、ramdisk init；
- 无法启动：恢复原 recovery 备份。

## Stage 2 — Display / Touch / Buttons

- [ ] 背光点亮；
- [ ] 1080×1920 无花屏/偏移；
- [ ] 颜色正确（红蓝不反）；
- [ ] 触摸坐标正确；
- [ ] 多点触摸可用；
- [ ] 音量键/电源键可用；
- [ ] 无鼠标指针（`hbtp_vm` 已屏蔽）。

调试：

```bash
adb shell dmesg | grep -i -E 'fb|mdss|synaptics|input'
adb shell getevent -pl
adb shell cat /sys/class/graphics/fb0/virtual_size
```

## Stage 3 — ADB / USB

- [ ] `adb devices` 能看到 recovery；
- [ ] `adb shell` 可进入；
- [ ] `adb pull` / `adb push` 可读写 `/tmp`；
- [ ] `adb sideload` 可进入 sideload 模式（Stage 6 验证）。

调试：

```bash
adb devices -l
adb shell getprop sys.usb.config
adb shell getprop sys.usb.state
adb shell ls /sys/class/udc
```

## Stage 4 — /dev/block、fstab、mount

- [ ] `/dev/block/bootdevice/by-name` 存在；
- [ ] `boot`、`recovery`、`system`、`userdata`、`cache`、`misc` 可识别；
- [ ] `/system` 可挂载（ext4）；
- [ ] `/cache` 可挂载；
- [ ] `/data` 可挂载（未加密时）；
- [ ] `/sdcard` 可用（data 挂载后）；
- [ ] 外部 SD 可挂载。

调试：

```bash
adb shell ls -l /dev/block/bootdevice/by-name
adb shell cat /proc/mounts
adb shell mount /system
adb shell mount /data
```

## Stage 5 — system / vendor / userdata

- [ ] `/system` 内容可读；
- [ ] `/system/vendor` 可读（CM14.1 的 vendor 在 system 下）；
- [ ] `/data` 可读写（未加密）；
- [ ] `/data/media/0` 可见；
- [ ] 备份/恢复 boot/recovery 可用。

## Stage 6 — ZIP / image / sideload

- [ ] 刷入 boot.img / recovery.img（先备份）；
- [ ] 刷入一个测试 ZIP；
- [ ] `adb sideload` 刷入 ZIP；
- [ ] 校验刷入后的分区 hash；
- [ ] 失败可回退。

**所有写入操作 REQUIRES USER CONFIRMATION。**

## Stage 7 — Encryption

- [ ] 确认 CM14.1 是 FDE footer；
- [ ] 确认 AERA 16 是否仍支持 FDE；
- [ ] 备份 data；
- [ ] 测试解锁/挂载；
- [ ] 失败可回退（不要 format）。

## Stage 8 — MTP / Wi-Fi / backup / 其他

- [ ] MTP；
- [ ] USB OTG；
- [ ] Wi-Fi（需要 wlan.ko/firmware，可能不在 recovery defconfig）；
- [ ] AERA Remote；
- [ ] 备份/恢复完整流程；
- [ ] 插件/终端/文件管理。

## 每阶段记录

每次测试记录：

- 镜像 SHA-256；
- 设备当前 boot/recovery 备份路径；
- 启动结果（屏幕/ADB/日志）；
- 失败时的最后一条 kernel/init 日志；
- 回退操作。

## 禁止事项

- 不要在 Stage 1 未通过时同时调十几个功能；
- 不要为了“让它启动”而修改 AERA core；
- 不要在没有备份的情况下 `fastboot flash recovery`；
- 不要 `fastboot erase` / `format` / 改 GPT；
- 不要把 R9s/R9s Plus 的镜像刷到本机。
