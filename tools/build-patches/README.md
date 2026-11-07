# Build patches for AERA on this host

These files are **build-system overlays**, not device tree files. They are
needed because AERA's `build/soong` fork does not register the upstream clang
`llvm_prebuilt_library_*` module types.

## Apply

From the AOSP root:

```bash
cp tools/build-patches/prebuilts-clang-Android.bp \
   prebuilts/clang/host/linux-x86/Android.bp
cp tools/build-patches/system-extras-fec-Android.bp \
   system/extras/verity/fec/Android.bp
```

`system-extras-fec-Android.bp` is the stock file with one change:

```bp
compile_multilib: "64",
```

This prevents the 32-bit host `fec32` link from pulling the 64-bit sanitizer
runtime. Recovery packaging does not need `fec32`.

## Why

- `libc++` was previously hidden by disabling the clang `Android.bp`.
- Standard `cc_prebuilt_library_*` modules expose the prebuilt files without
  the `llvm_prebuilt_*` types.
- The static libraries need `no_libcrt`, empty `system_shared_libs`, and
  explicit `ramdisk_available` / `apex_available`.
- `libc++` and its noexcept variant must export `include/c++/v1`.

Keep the device tree unchanged; these are host/build-system workarounds.
