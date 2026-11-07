# Risks

## 1. 风险矩阵

| # | 风险 | 概率 | 影响 | 证据 | 缓解 |
|---|---:|---|---|---|---|
| R1 | AERA 16 用户空间无法在 4.9 内核启动 | 中 | 致命 | Android 16 bionic/linker 依赖新 syscall；4.9 未在此设备跑过 Android 16 | 先构建、静态检查依赖；失败时最小内核 backport/启用 config |
| R2 | AERA ramdisk > 64 MiB 分区 | 中 | 致命 | recovery 分区固定 64 MiB；内核 10.56 MiB | 裁剪功能/语言/工具；gzip；关闭 fastbootd/WiFi/Python |
| R3 | OPPO aboot 拒绝自定义镜像 | 低-中 | 致命 | 只验证过 Lineage 22.1 的证书；AERA 镜像可能不同 | 原样复用 1,280 B recovery 证书；先 `fastboot boot`；保留 TWRP/EDL 回退 |
| R4 | 首次显示黑屏/花屏/颜色错 | 中 | 高 | 老 MSM fbdev，首次 blank 行为 | `SCREEN_BLANK_ON_BOOT`、`RGBX_8888`、`line_length`；必要时 `RECOVERY_BGRA` |
| R5 | 触摸不工作/选错设备 | 中 | 高 | `hbtp_vm`、`input_mt_wrapper` 干扰 | blacklist；检查 `getevent`；备选 keylayout |
| R6 | ADB 不识别 | 低-中 | 中 | UDC 名称/VID/PID/configfs | 硬编码 `msm_hsusb`；Google VID/PID；检查 `sys.usb.state` |
| R7 | FDE 无法解密 | 高 | 中 | AERA 16 主要面向 FBE；CM14.1 是 FDE | 首版关闭 crypto；Stage 7 单独移植/验证 |
| R8 | `reserve2` 被误格式化 | 中 | 中 | Lineage 22.1 用作 metadata；CM14.1 不用 | 首版不自动格式化；UI 不默认勾选 |
| R9 | system 挂载失败 | 低 | 高 | CM14.1 system 是 ext4，不是 squashfs | fstab 用 ext4；不要套 Lineage 22.1 的 squashfs |
| R10 | 构建环境 RAM 不足 | 已缓解 | 低 | 16 GB 主机；AOSP 16 需要较大内存 | 12 GB WSL + 64 GB **NVMe** swap + 8 GB zram；`-j4`；已成功产出镜像 |
| R11 | 源码同步失败/被墙 | 中 | 中 | GitHub 直连不稳定；AOSP 镜像可用 | ghfast 代理 + Tsinghua AOSP 镜像；断点重试 |
| R12 | 镜像写入错误分区 | 低 | 致命 | 用户误操作 | 只允许 `fastboot flash recovery`；明确分区表；禁止 `erase`/GPT |
| R13 | 设备变砖/无法回退 | 低-中 | 致命 | 老设备、无 EDL 验证 | 备份 boot/recovery；确认 TWRP/EDL；先临时启动 |

## 2. 最高优先级

### R1 — Android 16 on 4.9

这是“能不能启动”的核心。4.9.337 是较新的 4.9 LTS，包含许多 backport；LineageOS 22.1（Android 15）已在此内核上启动 recovery。Android 16 的主要新增依赖：

- `clone3`（5.3）— bionic 有 fallback；
- `faccessat2`（5.8）— 有 fallback；
- `statx`（4.11）— 4.9 没有，bionic 可能 fallback 到 `stat`；
- `memfd_create`（3.17）/ `getrandom`（3.17）— 4.9 有；
- `membarrier`（4.3）— 4.9 有；
- `pidfd`（5.3）— 非必需。

实际结果要看 AERA 二进制的动态依赖和启动日志。**不能仅凭“Android 15 能跑”就断定 Android 16 一定能跑。**

### R2 — 64 MiB

这是硬约束。64 MiB 分区不能通过设备树变大；只能裁剪 ramdisk 或改分区表（禁止）。AERA 的 UI/字体/工具/库可能接近上限。构建后第一件事是 `ls -l recovery.img`。

## 3. 中低风险

- 显示/触摸/ADB 都有 TWRP 3.7.x 与 Lineage 22.1 的双重验证；
- 分区表/fstab 已由 live 设备确认；
- OPPO 证书已由 Lineage 22.1 验证；
- 内核 config 已确认 fbdev/evdev/configfs/f2fs/ext4/exfat。

## 4. 不能忽略的“未知”

- AERA 16 是否保留 FDE（不是 FBE）；
- OPPO aboot 是否支持 `fastboot boot`；
- 4.9 内核是否包含 AERA 16 的某个新 syscall；
- AERA 16 的 LVGL UI 在 1080×1920 上的实际布局/字体大小；
- 64 MiB 下 AERA 完整功能是否装得下。

## 5. 风险处置顺序

1. 先构建，回答 R2；
2. 静态检查 AERA 二进制依赖，回答 R1 的一部分；
3. 再设备启动，回答 R1/R3/R4/R5/R6；
4. 最后做 R7（加密）和 Stage 8 功能。
