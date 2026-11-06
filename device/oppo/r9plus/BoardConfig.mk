#
# AERA Recovery device configuration for OPPO R9 Plusm A (r9plus)
#
# Verified target identity (read-only ADB):
#   ro.product.device   = R9PlusA
#   ro.product.name     = R9PlustmA
#   ro.cm.device        = r9plus
#   ro.board.platform   = msm8952
#   Hardware            = Qualcomm Technologies, Inc MSM8976
#
# This tree is intentionally based on the last known-working R9Plus
# recovery/kernel baseline (LineageOS 22.1 kernel 4.9 + TWRP device data),
# not on a generic Qualcomm tree.
#

DEVICE_PATH := device/oppo/r9plus

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a53

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a53

TARGET_BOARD_SUFFIX := _64

# Bootloader / platform
TARGET_NO_BOOTLOADER := true
TARGET_BOOTLOADER_BOARD_NAME := MSM8952
TARGET_BOARD_PLATFORM := msm8952
TARGET_BOARD_PLATFORM_GPU := qcom-adreno510

# Device assertions. Every alias below is present in shipping R9Plus ROMs;
# the exact running device reports R9PlusA / R9PlustmA.
TARGET_OTA_ASSERT_DEVICE := r9plus,R9Plus,R9PlusA,R9PlusmA,R9PlustmA

# Kernel: prebuilt 4.9 recovery kernel + appended FDT extracted from the
# verified LineageOS 22.1 R9Plus recovery image. The blob is Image.gz-dtb
# (gzip-compressed Image followed by one FDT, 242901 bytes).
BOARD_KERNEL_BASE := 0x80000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_TAGS_OFFSET := 0x00000100
BOARD_RAMDISK_OFFSET := 0x01000000
BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb
BOARD_BOOT_HEADER_VERSION := 0
BOARD_KERNEL_CMDLINE := androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 androidboot.bootdevice=7824900.sdhci firmware_class.path=/vendor/firmware_mnt/image loop.max_part=7 androidboot.selinux=permissive androidboot.usbconfigfs=true androidboot.usbcontroller=msm_hsusb
BOARD_MKBOOTIMG_ARGS += --header_version 0
BOARD_MKBOOTIMG_ARGS += --pagesize $(BOARD_KERNEL_PAGESIZE)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image.gz-dtb
TARGET_FORCE_PREBUILT_KERNEL := true

# The kernel blob already contains the appended FDT. Do not let the build
# system run a dtbTool or append a second DT image. Leave
# BOARD_KERNEL_SEPARATED_DT unset (setting it to "false" is still non-empty
# to several AOSP make checks).


# Recovery image
# AERA is a recovery-only build. Do not run dexpreopt; this device has no
# usable ART runtime in the recovery ramdisk, and dex2oat would pull the
# entire ART tree into the build.
WITH_DEXPREOPT := false
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_HAS_NO_SELECT_BUTTON := true
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
RECOVERY_GRAPHICS_USE_LINELENGTH := true
TARGET_RECOVERY_QCOM_RTC_FIX := true
TARGET_USES_MKE2FS := true
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
RECOVERY_SDCARD_ON_DATA := true

# Filesystems / partitions (verified from live /proc/partitions and by-name)
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 2147483648
BOARD_CACHEIMAGE_PARTITION_SIZE := 134217728
BOARD_PERSISTIMAGE_PARTITION_SIZE := 33554432
BOARD_USERDATAIMAGE_PARTITION_SIZE := 59243994112

# No A/B, no vendor partition, no dynamic super partition, no metadata
# partition. reserve2 is used as /metadata by the modern LineageOS baseline.
# Leave AB_OTA_UPDATER / BOARD_USES_METADATA_PARTITION unset; this is an
# A-only CM14.1 device.

# Crypto: CM14.1 uses FDE (footer), not FBE. Leave crypto disabled for the
# first boot; enable only in Stage 7 after the AERA FDE path is verified.

# AERA display configuration
AERA_THEME := portrait_hdpi
AERA_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
AERA_MAX_BRIGHTNESS := 255
AERA_DEFAULT_BRIGHTNESS := 127
AERA_SCREEN_BLANK_ON_BOOT := true
AERA_FRAMERATE := 60
AERA_SCREEN_H := 1920
AERA_STATUS_H := 72
AERA_HIDE_NOTCH := 0

# Input. hbtp_vm is the virtual mouse created by OPPO's touch driver.
# The real panel is event1 ("synaptics-s3508", MT-B, 1080x1920).
AERA_INPUT_BLACKLIST := "hbtp_vm"
AERA_USE_SERIALNO_PROPERTY_FOR_DEVICE_ID := true

# Legacy Qualcomm recovery / battery / clock handling
AERA_USE_LEGACY_BATTERY_SERVICES := 1
AERA_CUSTOM_CPU_TEMP_PATH := "/sys/class/thermal/thermal_zone20/temp"
AERA_HAS_EDL_MODE := true

# Build size and compatibility
AERA_EXCLUDE_APEX := true
AERA_SKIP_ADDITIONAL_FSTAB := true
AERA_NO_TREBLE_COMPATIBILITY_CHECK := true
AERA_DEVICE_VERSION := OPPO_R9_Plusm_A
AERA_TARGET_DEVICES := r9plus,R9Plus,R9PlusA,R9PlusmA,R9PlustmA
AERA_BUILD_TYPE := Alpha
AERA_BUILD_STATUS := Unofficial
AERA_MAINTAINER := AERA R9Plus bring-up

# Do not claim a dynamic partition / fastbootd path on this device yet.
# Leave AERA_INCLUDE_FASTBOOTD / AERA_USE_AIDL_BOOT_CONTROL unset.

# SELinux: permissive during bring-up, matching the shipping CM14.1 kernel
# command line. Tighten only after Stage 6.
BOARD_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy
