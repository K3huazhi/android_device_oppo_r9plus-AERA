# Build guide

## 1. 环境

本项目在 Windows 主机上使用 **WSL2 + Ubuntu 24.04** 构建，因为原生 Windows 不能可靠地构建 AOSP。

已验证环境：

| 项目 | 值 |
|---|---|
| Host | Windows 11 26300 |
| WSL | 2.7.14，Ubuntu 24.04.3 |
| RAM | 15.8 GB（WSL 建议限制到 12 GB + swap） |
| CPU | Xeon E5-2673 v3，12C/24T |
| 磁盘 | A: 剩余约 227 GB；WSL VHDX 放在 A: |
| Python | 3.12 |
| Git | 2.43 |

> 16 GB RAM 对 AOSP 16 偏紧。构建时用 `-j4`/`-j6`，并配置 32 GB swap；不要用 `-j24`。

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

## 11. 当前状态与实际结果

- AOSP 16 源码：已同步（BFSU 镜像 + GitHub 代理补 AERA 项目）；
- `lunch twrp_r9plus-bp2a-eng`：通过；
- 全量 Soong 分析：在本机 13.6 GB WSL / 32 GB swap 上超过 20 分钟未完成，随后因内存压力终止；
- 裁剪 AOSP 模块：触发多处 `aconfig_declarations` panic 和 Connectivity/cronet 依赖环，**不可作为正式构建方式**；
- `recovery.img`：**未生成**；
- 设备写入：**未执行**。

完整错误记录见 [`conclusions/build-attempt.md`](../conclusions/build-attempt.md)。

**下一次构建必须在 ≥64 GB RAM 的 Linux 主机上进行，并保留完整 AOSP 树。** 不要用本机裁剪过的 `/root/aosp` 作为最终构建树；请重新 `repo sync` 或恢复 `/root/pruned*`。
