# Build success — AERA R1.0 for OPPO R9 Plusm A

> 状态：**recovery.img 已生成并完成静态校验；实机刷入后卡第一屏，未启动。项目已放弃。**
> 镜像：<https://github.com/K3huazhi/android_device_oppo_r9plus-AERA/releases/download/v0.2-build/recovery-AERA-R1.0-r9plus.img>  
> SHA-256：`3d9ddd212219f221a100c76942510b266c5a98e2d43bac9f68a0334e6f18df45`  
> 大小：45,681,920 B（43.56 MiB，< 64 MiB 分区）

## 1. 构建结果

| 项目 | 值 |
|---|---|
| 产品 | `twrp_r9plus` |
| 版本 | AERA R1.0 / Android 16 / `BP2A.250605.031.A2` |
| 构建变体 | `eng` |
| 构建系统 | AOSP Soong + Kati + ninja |
| 目标 | `adbd recoveryimage` |
| 主机 | Windows 11 + WSL2 Ubuntu 24.04.3 |
| WSL 存储 | `C:` NVMe VHDX（从 `A:` HDD 迁移） |
| RAM | 12 GB（WSL），64 GB NVMe swap，8 GB zram（按需） |
| 编译器 | clang-r547379 |
| 内核 | 预编译 4.9.337 `Image.gz-dtb` |

## 2. 镜像静态校验

```text
magic            ANDROID!
header version   v0
page size        2048
kernel size      10,561,222 B
kernel sha256    7c9ac2f052edf435ee83e5a4be9a27529b7de012cca8da8dea21713f54376a2a
ramdisk size     35,116,033 B
ramdisk format   gzip cpio
ramdisk entries  3,650
trailing cert    1,280 B, starts 30 82 04 fc
image size       45,681,920 B
partition size   67,108,864 B
image sha256     3d9ddd212219f221a100c76942510b266c5a98e2d43bac9f68a0334e6f18df45
```

ramdisk 关键文件：

```text
system/bin/recovery     ELF64 ARM64 PIE, ~10 MiB, contains "AERA Default"/aera.cfg strings
system/etc/recovery.fstab
vendor/etc/vintf/manifest/android.hardware.health@2.1.xml
init.recovery.qcom.rc
init.recovery.usb.rc
init.recovery.service.rc
init.recovery.ldconfig.rc
init.recovery.hlthchrg.rc
```

内核区与 `device/oppo/r9plus/prebuilt/Image.gz-dtb` 字节级一致（SHA-256 相同）。

## 3. 构建路径

最终可复现的主机配置：

```ini
# C:\Users\<user>\.wslconfig
[wsl2]
memory=12GB
processors=12
swap=64GB
swapFile=C:\\wsl\\swap.vhdx
```

关键步骤：

```bash
cd /root/aosp
source build/envsetup.sh
lunch twrp_r9plus-bp2a-eng
mka -j4 adbd recoveryimage

python3 tools/patch_oppo_image.py \
  out/target/product/r9plus/recovery.img \
  device/oppo/r9plus/prebuilt/oppo_boot.patch \
  --partition-size 67108864
```

Soong 全量分析约 **50–60 分钟**；峰值 swap 约 **27 GiB**，没有 OOM。之后进入 Kati 与 ninja 编译，最终完成 AERA 打包脚本：

```text
Finished building AERA R1.0
Recovery image: /AERA-R1.0-Stable-Unofficial-.img
Recovery zip:   /AERA-R1.0-Stable-Unofficial-.zip
```

## 4. 为完成构建所做的构建系统修补

AERA 的 `build/soong` fork 不注册上游 clang `Android.bp` 使用的 `llvm_prebuilt_library_*` 模块类型。为保留上游 clang 预编译库，本项目用标准 `cc_prebuilt_library_*` 重新暴露：

- `libc++` / `libc++_static` / `libc++abi` / `libc++demangle`
- `libclang_rt.ubsan_minimal` / `libclang_rt.builtins`
- `libclang_rt.builtins-exported`（arm/x86）
- `libunwind` / `libunwind-exported`
- `libc++_static_noexcept` / `libc++demangle_noexcept` / `libc++abi_noexcept`

同时：

- 给这些模块补 `recovery_available`、`ramdisk_available`、`apex_available`；
- 给 `libclang_rt.builtins` 加 `no_libcrt: true`，避免自依赖；
- 给 `libc++`/noexcept 变体导出 `include/c++/v1`；
- 将 host `fec` 限制为 64 位，避免 32 位 sanitizer 链接；
- 将 `out/.../root/vendor` 由 `/system/vendor` 符号链接改为真实目录，避免与 TWRP/AERA 的 `vendor/etc/vintf` 冲突。

这些修补文件在 [`tools/build-patches/`](../tools/build-patches/)。

## 5. 运行时结果（已实测，失败）

镜像已由用户刷入 `recovery` 分区。重启 recovery 后：

- 设备**卡在第一屏**，未进入 AERA UI；
- 主机侧 `adb devices` / `fastboot devices` 均无设备；
- 未能抓取 `dmesg`、`logcat` 或 pstore；
- 根因未定位；项目所有者已放弃。

因此：

- 本文档只证明**构建与静态校验成功**；
- **不证明镜像可启动**；
- 不要把该镜像作为可刷写镜像分发。

详见 [`runtime-result.md`](runtime-result.md)。

## 6. 产物

```text
dist/recovery-AERA-R1.0-r9plus.img          已追加 OPPO 证书
dist/recovery-AERA-R1.0-r9plus-unsigned.img 未追加证书，仅用于对比
```

校验：

```bash
sha256sum dist/recovery-AERA-R1.0-r9plus.img
# 3d9ddd212219f221a100c76942510b266c5a98e2d43bac9f68a0334e6f18df45
```
