# Build guide

## 1. 环境

本项目在 Windows 主机上使用 **WSL2 + Ubuntu 24.04** 构建，因为原生 Windows 不能可靠地构建 AOSP。

已验证环境：

| 项目 | 值 |
|---|---|
| Host | Windows 11 26300 |
| WSL | 2.7.14，Ubuntu 24.04.3 |
| RAM | 15.8 GB（WSL 限制 12 GB；64 GB NVMe swap；8 GB zram） |
| CPU | Xeon E5-2673 v3，12C/24T |
| 磁盘 | **C: NVMe 1 TB**；WSL VHDX 与 swap 都在 C: |
| Python | 3.12 |
| Git | 2.43 |

> 16 GB RAM 对 AOSP 16 偏紧。最终成功配置：12 GB WSL + 64 GB **NVMe** swap + 8 GB zram，`-j4`，Soong 峰值 swap 约 27 GiB。不要用 HDD 上的 swap，也不要用 `-j24`。

### 1.1 关键：把 WSL 与 swap 放到 NVMe

这台主机只有 16 GB RAM；成功构建的关键不是“加大 swap”，而是 **swap 必须在 NVMe 上**。最初 WSL VHDX 在 A: 机械盘，swap 也在 HDD，Soong 阶段会严重抖动。

```ini
# C:\Users\<user>\.wslconfig
[wsl2]
memory=12GB
processors=12
swap=64GB
swapFile=C:\\wsl\\swap.vhdx
```

迁移已有发行版（先用 `wsl --shutdown`）：

```powershell
wsl --manage AERA-BUILD --move C:\wsl\AERA-BUILD
```

启用 zram（WSL 内）：

```bash
apt-get install -y kmod
modprobe zram num_devices=1
zramctl /dev/zram0 --size 8G
mkswap /dev/zram0
swapon -p 100 /dev/zram0
```

> zram 优先级高于磁盘 swap；内存极紧时它可能被回收，此时 64 GB NVMe swap 仍是兜底。

## 2. 网络 / 镜像

本机到 GitHub 的直连不稳定，`raw.githubusercontent.com` / `codeload.github.com` 经常被阻断；实测可用：

- GitHub 代理：`https://ghfast.top/https://github.com/...`（archive 快，git fetch 较慢）
- AOSP 镜像：**`https://mirrors.bfsu.edu.cn/git/AOSP/`**（实测快，无排队）
- 备选 AOSP 镜像：`https://mirrors.ustc.edu.cn/aosp/`（并发会 429）、`https://mirrors.tuna.tsinghua.edu.cn/git/AOSP/`（git 请求排队，不适合大规模 repo sync）
- `repo` 启动器：Tsinghua 的 `git/git-repo`

WSL 中设置：

```bash
git config --global url."https://ghfast.top/https://github.com/".insteadOf "https://github.com/"
git config --global url."https://mirrors.bfsu.edu.cn/git/AOSP/".insteadOf "https://android.googlesource.com/"
```

如果之前设置过 Tsinghua/USTC，先 `git config --global --unset-all` 对应 `insteadOf`，否则 repo 会继续走慢镜像。

## 3. 安装 WSL

> **REQUIRES USER CONFIRMATION** only if installing/altering the host OS is needed. This project already has a working WSL distro.

已使用 Ubuntu base rootfs 导入：

```powershell
wsl --import AERA-BUILD A:\wsl\AERA-BUILD A:\wsl\noble-base-amd64.tar.gz --version 2
```

安装依赖：

```bash
apt-get update
apt-get install -y \
  ca-certificates curl git python3 build-essential zip unzip \
  zlib1g-dev libncurses-dev libx11-dev libgl1-mesa-dev libxml2-utils \
  xsltproc fontconfig rsync bc ccache openjdk-17-jdk-headless \
  libssl-dev libelf-dev lz4 zstd cpio python3-protobuf
```

## 4. 初始化 AERA 源码

```bash
mkdir -p /root/aosp
cd /root/aosp
repo init --depth=1 \
  --repo-url https://mirrors.tuna.tsinghua.edu.cn/git/git-repo \
  --repo-rev main \
  -u https://ghfast.top/https://github.com/AERA-Recovery/android_manifest.git \
  -b aera-16.0
```

AERA 的 manifest 需要把 `default.xml` + `twrp-default.xml` + `aera.xml` + `remove-minimal.xml` 合并。仓库里的脚本：

```bash
python3 tools/wsl/merge-manifests.py
```

生成 `.repo/manifests/merged.xml`，并把 `.repo/manifest.xml` 指向它。注意：
`twrp-default.xml` 的 `<include>` 会按 `.repo/` 解析，不能只放到 `.repo/local_manifests`。

然后：

```bash
repo sync -c --no-clone-bundle --no-tags -j8
```

这一步会下载 AOSP 16 + AERA 项目，约几十 GB。当前 WSL 运行日志：[`sources/aera/recovery-src`](../sources/aera/recovery-src) 之外的实际源码在 `/root/aosp`（不复制进仓库）。

## 5. 放设备树

```bash
mkdir -p device/oppo
cp -a /mnt/a/OPPOR9PlustmA/device/oppo/r9plus device/oppo/r9plus
```

如果从零仓库构建，设备树应作为独立 Git 仓库：

```bash
git clone <your>/android_device_oppo_r9plus-AERA device/oppo/r9plus
```

## 6. 配置与 lunch

```bash
source build/envsetup.sh
lunch twrp_r9plus-bp2a-eng
```

若 `bp2a` 不在可用 release 列表中，用：

```bash
lunch twrp_r9plus-userdebug
```

AERA 的 README 对 dodge 使用 `twrp_dodge-bp2a-eng`；本设备是 Android 16 构建，`bp2a` 是 AERA 的 release 标识，实际以 `lunch` 输出为准。

## 7. 构建

```bash
mka adbd recoveryimage
```

只构建 recovery，不构建 `bootimage`/`systemimage`，避免无关错误。

输出：

```text
out/target/product/r9plus/recovery.img
```

## 8. 追加 OPPO 证书

```bash
python3 tools/patch_oppo_image.py \
  out/target/product/r9plus/recovery.img \
  device/oppo/r9plus/prebuilt/oppo_boot.patch \
  --partition-size 67108864
```

校验：

```bash
python3 tools/parse_bootimg.py out/target/product/r9plus/recovery.img
ls -l out/target/product/r9plus/recovery.img
```

预期：

- magic `ANDROID!`；
- `kernel_size ≈ 10,561,222`（如果使用预编译内核）；
- `page_size=2048`；
- 尾部 1,280 字节；
- 总大小 < 67,108,864。

## 9. 常见错误

| 错误 | 原因 | 处理 |
|---|---|---|
| `NO KERNEL CONFIG` | 没有 prebuilt kernel / 构建系统仍想编译内核 | 确认 `TARGET_PREBUILT_KERNEL`、`AERA_FORCE_PREBUILT_KERNEL := 1` |
| `BOARD_KERNEL_SEPARATED_DT` 触发 dtbTool | 内核已含 FDT | 设为 false |
| `recovery.img` 超过 64 MiB | AERA ramdisk 太大 | 裁剪功能/资源；不能改分区 |
| `TARGET_COPY_OUT_RECOVERY` 未定义 | 产品继承顺序 | 在 `device.mk` 中确认 `vendor/twrp/config/common.mk` 已继承 |
| `twrp.flags` 未生效 | 文件没进 ramdisk | 检查 `recovery/root` 覆盖与 `TARGET_RECOVERY_FSTAB` |
| `lunch` 找不到产品 | `AndroidProducts.mk` 路径/名称错 | 确认 `PRODUCT_MAKEFILES` 指向 `twrp_r9plus.mk` |
| `repo sync` 卡在 cts/clang | 大仓库/代理慢 | 等待或从 merged manifest 移除不需要的项目 |

## 10. 构建产物验证清单

- [ ] `recovery.img` header v0；
- [ ] kernel 与 `prebuilt/Image.gz-dtb` 一致；
- [ ] ramdisk 可 gunzip，cpio 可列出；
- [ ] ramdisk 内有 `init.recovery.qcom.rc`、`system/etc/recovery.fstab`、`system/etc/twrp.flags`；
- [ ] ramdisk 内有 `system/bin/recovery`、`system/bin/adbd`；
- [ ] `/system/usr/keylayout` 有对应 kl；
- [ ] 尾部 1,280 字节证书存在；
- [ ] 总大小 ≤ 64 MiB。

## 11. 实际构建结果

- AOSP 16 源码：完整树（BFSU 镜像 + GitHub 代理补 AERA 项目）；
- `lunch twrp_r9plus-bp2a-eng`：通过；
- Soong 全量分析：约 50–60 分钟，峰值 swap 约 27 GiB，未 OOM；
- Kati / ninja：完成；
- AERA 打包脚本：`Finished building AERA R1.0`；
- `recovery.img`：**45,681,920 B**，已追加 OPPO 1,280 B 证书；
- 设备写入：**未执行**。

镜像 SHA-256：

```text
3d9ddd212219f221a100c76942510b266c5a98e2d43bac9f68a0334e6f18df45
```

完整记录见 [`conclusions/build-success.md`](../conclusions/build-success.md)。

## 12. 需要的构建系统修补

AERA 的 `build/soong` fork 不注册上游 clang `Android.bp` 的 `llvm_prebuilt_library_*` 类型。这里不是改设备树，而是补构建系统：

```bash
cp tools/build-patches/prebuilts-clang-Android.bp \
   prebuilts/clang/host/linux-x86/Android.bp
cp tools/build-patches/system-extras-fec-Android.bp \
   system/extras/verity/fec/Android.bp
```

修补内容：

- `libc++` / `libc++_static` / `libc++abi` / `libc++demangle`；
- `libclang_rt.ubsan_minimal` / `libclang_rt.builtins` / `builtins-exported`；
- `libunwind` / `libunwind-exported`；
- `libc++_static_noexcept` / `demangle_noexcept` / `abi_noexcept`；
- `recovery_available`、`ramdisk_available`、`apex_available`（含 `com.android.runtime`）；
- `libclang_rt.builtins` 的 `no_libcrt: true`；
- `libc++` 与 noexcept 变体导出 `include/c++/v1`；
- `fec` 只构建 64 位，避免 32 位 sanitizer 链接。

打包时若出现：

```text
could not make way for new symlink: root/vendor
cannot delete non-empty directory: root/vendor
```

把 `out/target/product/r9plus/root/vendor` 从 `/system/vendor` 符号链接改为真实目录，保留 `recovery/root/vendor` 的 vintf；然后直接续跑：

```bash
rm -f out/target/product/r9plus/root/vendor
mkdir -p out/target/product/r9plus/root/vendor
prebuilts/build-tools/linux-x86/bin/ninja \
  -f out/combined-twrp_r9plus.ninja recoveryimage -j4
```

这样可以避免重新执行 50 分钟的 Soong 分析。

## 13. 复现提示

如果重新 `repo sync`，必须保留完整 AOSP 树；本项目的成功构建依赖完整模块图，裁剪会触发 `aconfig_declarations` 缺失和 Connectivity/cronet 依赖环。
