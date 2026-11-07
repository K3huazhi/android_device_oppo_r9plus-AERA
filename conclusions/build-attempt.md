# Build attempt log

## Result

**`recovery.img` was produced successfully after moving the WSL VHDX to C: NVMe and using 12 GB RAM + 64 GB NVMe swap + 8 GB zram.**

Final image and hashes are in [`build-success.md`](build-success.md). This file keeps the earlier failure history because it explains why the build-host changes were necessary.

## Environment (final successful build)

- Windows 11 + WSL2 Ubuntu 24.04
- 16 GB physical RAM → WSL limit 12 GB
- 64 GB NVMe swap on C: (`swapFile=C:\\wsl\\swap.vhdx`), 8 GB zram
- 12 vCPU
- AOSP 16.0.0_r1 + AERA `aera-16.0`
- WSL VHDX moved from A: HDD to C: NVMe

## What worked

1. `repo init` / `repo sync` of the AERA manifest (BFSU AOSP mirror).
2. AERA device tree `device/oppo/r9plus` accepted by `lunch twrp_r9plus-bp2a-eng`.
3. Product configuration reached `TARGET_PRODUCT=twrp_r9plus` with Android 16 / arm64.
4. `prebuilts/sdk` and `prebuilts/clang/host/linux-x86/clang-r547379` obtained (partial sparse clone for clang; full checkout for SDK).
5. Static validation of the device tree passes: 38 checks, 0 failures.

## What failed

### 1. Clang prebuilt was incomplete at first

The GitHub `KiTTYsh` clang mirror stores large binaries in Git LFS, and its LFS server (`git.i5.wtf`) is dead. A workaround was found: partial clone from the AOSP BFSU mirror with sparse checkout of `clang-r547379`:

```bash
git clone --filter=blob:none --no-checkout --depth=1 \
  --branch android-16.0.0_r1 \
  https://mirrors.bfsu.edu.cn/git/AOSP/platform/prebuilts/clang/host/linux-x86
cd linux-x86
git sparse-checkout init --cone
git sparse-checkout set clang-r547379
git checkout
```

This produced a working `clang-r547379` (140 MB `clang-20`).

### 2. `prebuilts/sdk` missing

Soong failed with:

```text
libcore/JavaLibrary.bp:1150:1: module "art.module.public.api" ... missing tracking files
```

Fix: partial clone + full checkout of `prebuilts/sdk`.

### 3. Full-tree Soong analysis exceeds 13.6 GB

With the full AOSP tree, `soong_build` ran for more than 20 minutes, used all 13.6 GB RAM plus 12–15 GB swap, and did not complete. On 2026-11-06 the host was effectively thrashing. Example:

```text
Mem: 13Gi total, 13Gi used, 112Mi free
Swap: 32Gi total, 15Gi used
soong_build ... 204% CPU
```

### 4. Pruning the tree produces aconfig panics

To reduce memory, non-recovery AOSP projects were moved out. Soong then failed on modules whose `aconfig_declarations` had been removed:

```text
internal error: panic in GenerateBuildActions for module "telecom_flags_core_java_lib"
Exactly one aconfig_declarations property required
```

Restoring `packages/services` fixed that, but then:

```text
module "libaconfig_android_hardware_biometrics_rust" ... Exactly one aconfig_declarations property required
```

A further cycle appeared between `packages/modules/Connectivity` and `external/cronet`:

```text
httpclient_impl -> httpclient_impl_internal -> framework-connectivity -> framework-connectivity.impl -> httpclient_impl
```

Conclusion: the AERA manifest expects a **complete AOSP module graph**. Arbitrary pruning is not a supported build mode.

### 5. `WITH_DEXPREOPT := false`

This removed the `dex2oat` dependency panic for `apache-xml`, but did not solve the memory/aconfig problems.

## Why this is not a hardware conclusion

- The 4.9 recovery kernel, FDT, display, touch, USB, and partition data are all validated.
- The device tree has the correct AOSP product/lunch identity.
- No compile error was caused by R9-specific code or missing hardware support.
- The failures are AOSP host/toolchain completeness issues.

## Recommended next attempt

1. Use a Linux host with **≥64 GB RAM** (AOSP 16 recommendation) and 250 GB free SSD.
2. Sync the **full** AERA manifest, not a pruned tree.
3. Keep `WITH_DEXPREOPT := false`.
4. Build:
   ```bash
   source build/envsetup.sh
   lunch twrp_r9plus-bp2a-eng
   mka -j16 adbd recoveryimage
   ```
5. Append the OPPO certificate:
   ```bash
   python3 tools/patch_oppo_image.py \
     out/target/product/r9plus/recovery.img \
     device/oppo/r9plus/prebuilt/oppo_boot.patch
   ```
6. Verify with `tools/static_check.py` and `tools/parse_bootimg.py`.

No device write has been performed.
