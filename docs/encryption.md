# Encryption

## 1. 先确认 Android 7.1 的方案

CM14.1 的 R9Plus fstab：

```text
/dev/block/bootdevice/by-name/userdata  /data  ext4  ...  wait,check,resize,encryptable=footer
```

`encryptable=footer` 表示 **FDE（Full Disk Encryption）**：加密元数据/密钥材料放在 userdata 分区末尾的 crypto footer，而不是现代 FBE 的 `/metadata` + per-file keys。

当前设备状态：

```text
ro.crypto.state = unencrypted
ro.crypto.type  = (空)
vold.decrypt    = (空)
```

所以首版启动、挂载 `/data` 不需要解密。Stage 7 才处理加密。

## 2. FDE 组件

| 组件 | 作用 | 本机情况 |
|---|---|---|
| `crypto footer` | 存放 FDE 密钥/参数 | userdata 尾部 |
| `vold` | 管理加密卷 | Android 7.1 vold |
| `qseecomd` | QSEECom 安全服务 | 4.9 内核 `CONFIG_QSEECOM=y` |
| `keymaster` | 密钥派生/验证 | OPPO QSEE keymaster 3.0 |
| `gatekeeper` | 锁屏凭据验证 | QSEE gatekeeper |
| `libcryptfs_hw` | QCOM 硬件加密适配 | TWRP 树有 `cryptfs_hw` |

TWRP 3.7.x 设备树同时启用了：

```make
TW_INCLUDE_CRYPTO := true
BOARD_USES_QCOM_FBE_DECRYPTION := true
TW_USE_FSCRYPT_POLICY := 1
BOARD_USES_QCOM_DECRYPTION := true
TARGET_CRYPTFS_HW_PATH := device/oppo/thortanium/cryptfs_hw
TARGET_HW_DISK_ENCRYPTION := true
```

这说明该设备在 TWRP 中同时具备 FDE/FBE 的构建路径；但 CM14.1 实际用的是 FDE footer。

## 3. AERA 16 的加密支持

AERA 16 的代码基座来自 TWRP/OrangeFox，但 Android 16 的 `vold`/`keymint` 主要面向 FBE。需要区分：

- **FBE**：不适用于 CM14.1 的 `encryptable=footer`；不要按现代 `/metadata` + `keydirectory` 配置。
- **FDE**：TWRP 的 legacy crypto 路径可能仍在 AERA 中，但 AERA 16 是否保留 `cryptfs`/`libcryptfs_hw` 需要源码确认。

首版设备树：

```make
AERA_INCLUDE_CRYPTO := false
AERA_INCLUDE_CRYPTO_FBE := false
AERA_USE_FSCRYPT_POLICY := 0
```

这是**故意关闭**，避免在 Stage 1 因 crypto 初始化失败而卡住启动。Stage 7 再打开并逐项调试。

## 4. FDE 解密需要什么

如果后续启用 FDE，最小闭环是：

1. 内核：QSEECom、dm-crypt、ext4 加密支持（4.9 defconfig 已有 `CONFIG_QSEECOM=y`、`CONFIG_DM_CRYPT` 需确认）；
2. ramdisk：`qseecomd`、`libQSEEComAPI.so`、`libcryptfs_hw.so`、keymaster/gatekeeper HAL；
3. init：启动 `qseecomd`，等待 `/dev/qseecom`；
4. AERA：`TW_INCLUDE_CRYPTO` + `TW_INCLUDE_CRYPTO_FBE`（按实际方案）+ 正确的 fstab `encryptable=footer`；
5. 用户输入密码 -> `cryptfs` 解密 -> 挂载 `/data`。

本机 4.9 recovery defconfig 已包含：

```text
CONFIG_QSEECOM=y
CONFIG_DM_VERITY=y
CONFIG_DM_VERITY_FEC=y
CONFIG_SECURITY_SELINUX=y
```

但 `CONFIG_DM_CRYPT`、`CONFIG_BLK_DEV_DM` 的具体行需要在完整 config 中确认（defconfig 片段有 `CONFIG_BLK_DEV_DM=y`）。

## 5. 风险

| 风险 | 影响 | 处理 |
|---|---|---|
| AERA 16 移除了 FDE 路径 | 无法解密 CM14.1 的加密 data | 需要移植 legacy cryptfs，或明确不支持 |
| keymaster HAL 版本不匹配 | 解密失败 | 使用 TWRP 树的 keymaster 3.0 组合 |
| `/metadata` 被误用 | 格式化 reserve2 可能破坏 Lineage 22.1 的 metadata | CM14.1 不用；首版不默认格式化 |
| 密码键盘/UI | AERA 16 的加密 UI 可能只支持 FBE | 需要设备树/主题适配 |
| 加密状态下误刷 | 数据不可恢复 | 任何写操作前备份；首版不自动 format |

## 6. 结论

- **CM14.1 是 FDE，不是 FBE。**
- 当前设备未加密，所以 Stage 1–6 不受影响。
- AERA 16 的 FDE 支持是**明确的风险项**，需要在 Stage 7 单独验证；不要把它作为首版启动的前置条件。
- 如果最终只能支持未加密 data，则结论应写成“PARTIALLY FEASIBLE（加密功能缺失）”，而不是“完全成功”。
