# Next steps

> 构建阶段已完成：`recovery.img` 已生成并通过静态校验，见 [`build-success.md`](build-success.md)。下面是设备验证步骤；后面的“重新构建”仅作为复现参考。

## 立即（设备验证，需明确授权）

1. **先备份并可回退**：确认 `boot`、`recovery`、`system`、`userdata` 的现状；准备 TWRP/Lineage recovery 回退镜像。
2. **只验证 recovery 分区**：不要动 `boot`/`system`/`userdata`/GPT。
3. **建议顺序**：
   - `fastboot boot` 临时启动（若 OPPO aboot 支持）；
   - 或只 `fastboot flash recovery`，失败时立即回刷原 recovery；
   - 记录串口/UART 或 `last_kmsg`/`pstore`（若可用）。
4. **Stage 1 目标**：AERA UI 点亮、触摸、ADB、分区识别。
5. 任何写入前再次确认；不要在未备份时格式化或解锁。

## 如需重新构建（复现）

1. **使用 NVMe 上的 WSL + 64 GB swap**  
   本机 16 GB RAM 曾无法在 HDD swap 上完成 Soong；最终用 12 GB WSL + 64 GB NVMe swap + 8 GB zram 成功。见 `conclusions/build-success.md`。不要在裁剪过的树上继续硬试；裁剪会触发 aconfig/依赖环错误。

2. **重新同步完整 AERA manifest**  
   ```bash
   mkdir -p ~/aosp && cd ~/aosp
   repo init --depth=1 \
     --repo-url https://mirrors.tuna.tsinghua.edu.cn/git/git-repo \
     -u https://github.com/AERA-Recovery/android_manifest.git -b aera-16.0
   ```
   然后按 `tools/wsl/merge-manifests.py` 的方式合并 default/twrp/aera/remove-minimal，或直接按 AERA README 的完整 manifest 同步。

3. **把设备树放进源码树**
   ```bash
   mkdir -p /root/aosp/device/oppo
   cp -a /mnt/a/OPPOR9PlustmA/device/oppo/r9plus /root/aosp/device/oppo/r9plus
   ```

4. **首次 lunch**
   ```bash
   cd ~/aosp
   source build/envsetup.sh
   lunch twrp_r9plus-bp2a-eng
   ```
   如果 `bp2a` 不存在，改用 `twrp_r9plus-userdebug`。

5. **首次构建**
   ```bash
   mka adbd recoveryimage
   ```
   逐项修：
   - product 继承；
   - `TARGET_COPY_OUT_RECOVERY`；
   - `TARGET_PREBUILT_KERNEL`；
   - header v0；
   - 64 MiB 限制；
   - 缺少的 AERA 依赖。

6. **追加证书**
   ```bash
   python3 tools/patch_oppo_image.py \
     out/target/product/r9plus/recovery.img \
     device/oppo/r9plus/prebuilt/oppo_boot.patch
   ```

7. **静态校验**
   ```bash
   python3 tools/parse_bootimg.py out/target/product/r9plus/recovery.img
   ls -l out/target/product/r9plus/recovery.img
   ```
   目标：`ANDROID!`、kernel≈10.56 MiB、page 2048、尾部 1,280 B、总大小 ≤ 64 MiB。

## 构建通过后（设备前）

1. 解包 ramdisk，确认：
   - `/init.recovery.qcom.rc`
   - `/system/etc/recovery.fstab`
   - `/system/etc/twrp.flags`
   - `/system/bin/recovery`
   - `/system/bin/adbd`
   - `/system/usr/keylayout/*.kl`
2. 确认 `recovery` 二进制是 arm64、动态依赖都在 ramdisk；
3. 确认 `fb0` uevent 权限；
4. 确认 `init.rc` 会 import `init.recovery.qcom.rc` / `init.recovery.usb.rc`；
5. 记录镜像 SHA-256。

## 设备验证前（必须用户确认）

- [ ] 备份原 boot/recovery（TWRP 或 root dd）；
- [ ] 确认能进入 TWRP；
- [ ] 确认能进入 bootloader；
- [ ] 确认 EDL/深刷回退；
- [ ] 确认镜像 ≤ 64 MiB；
- [ ] 确认分区 `recovery = mmcblk0p25`；
- [ ] 阅读 [`docs/bringup.md`](docs/bringup.md)。

## 首版成功后

1. 记录启动日志；
2. 修显示/触摸/ADB/分区；
3. 再启用 ZIP/sideload；
4. 最后评估 FDE/MTP/WiFi；
5. 更新 `conclusions/feasibility.md` 的最终结论。

## 不需要做的事

- 不要重写 3.10 内核；
- 不要修改 CM14.1 system；
- 不要改 GPT；
- 不要为了 AERA 改 AERA core；
- 不要在没有备份时刷 recovery。
