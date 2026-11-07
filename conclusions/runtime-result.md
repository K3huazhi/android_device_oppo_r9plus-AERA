# Runtime result — recovery stuck on first screen

> 日期：2026-11-07  
> 设备：OPPO R9 Plusm A / `R9PlusA` / `r9plus` / MSM8976  
> 镜像：`recovery-AERA-R1.0-r9plus.img`  
> SHA-256：`3d9ddd212219f221a100c76942510b266c5a98e2d43bac9f68a0334e6f18df45`

## 结果

1. 用户将镜像刷入 `recovery` 分区。
2. 重启到 recovery。
3. 设备**卡在第一屏**，未进入 AERA UI。
4. 主机侧检查：

```text
adb devices -l      -> 无设备
fastboot devices    -> 无设备
```

5. 因此无法在卡屏状态抓取 `dmesg`、`logcat`、`ps`、init 日志或 pstore。
6. 项目所有者决定放弃该项目，未继续做回退/日志抓取/二次构建。

## 能确定什么

- 镜像被写入后，设备至少没有立即黑屏重启/进入 bootloader；但“第一屏”的具体内容未记录。
- **adbd 没有在可被主机发现的时间内启动**，或者 USB/UDC/init 在 adbd 之前就停住了。
- 构建产物本身通过了静态校验：header v0、page 2048、kernel 与预编译 `Image.gz-dtb` 一致、ramdisk gzip 可解、OPPO 1,280 B 证书存在。
- 不能从这次结果判断是：
  - OPPO aboot 证书/签名拒绝；
  - 4.9 内核与 AERA 16 userspace 不兼容；
  - init/USB/adbd 配置问题；
  - AERA UI 首屏/显示/触摸死锁；
  - 或其他运行时问题。

## 对后人的建议

1. **不要直接刷这个镜像**，除非你在做故障研究并有完整回退方案。
2. 若要继续，先恢复原 recovery / TWRP，再抓：
   - `/sys/fs/pstore`（如果内核崩溃）；
   - `dmesg` / `last_kmsg`；
   - `logcat`；
   - `/proc/device-tree`、`/sys/class/udc`、`/dev/graphics/fb0`。
3. 优先验证 **adbd 是否在 init 早期启动**，以及 `init.recovery.qcom.rc` / `init.recovery.usb.rc` 是否被正确 import。
4. 若第一屏是 AERA 启动图，说明内核和部分 init 已工作，问题更可能在 AERA UI 首屏、输入/显示或 4.9 内核兼容性；若是黑屏/内核 logo，优先查内核/ABOOT。
5. 可参考仓库中的 `tools/build-patches/` 复现构建，但不要把“构建成功”误认为“可启动”。

## 结论

**PARTIALLY FEASIBLE — build OK, runtime failed, project abandoned.**

构建和静态证据保留；运行时失败，未定位根因。
