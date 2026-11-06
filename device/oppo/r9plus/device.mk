#
# AERA Recovery device package for OPPO R9 Plusm A (r9plus)
#

LOCAL_PATH := device/oppo/r9plus

# Inherit AERA-specific options.
$(call inherit-product, $(LOCAL_PATH)/aera_r9plus.mk)

# Recovery ADB: no host-side authorization for first bring-up. The build is
# already userdebug/eng, but make the intent explicit.
ADDITIONAL_DEFAULT_PROPERTIES += \
    ro.adb.secure=0 \
    ro.secure=0

# All recovery-root overlays (init rc, ueventd, fstab, twrp.flags, keylayout)
# live under recovery/root/ and are copied by the TWRP/AERA recovery build.
# Do not duplicate them through PRODUCT_COPY_FILES: TWRP's recovery-root
# overlay is applied after the generic ramdisk and must be allowed to replace
# AERA's own init.recovery.usb.rc.

# AERA recovery does not need the full telephony stack at this stage, but
# base product inclusions above can pull it in; keep the image lean later.
