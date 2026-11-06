#
# Copyright (C) 2017 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

PLATFORM_PATH := device/oppo/thortanium

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

# Platform
TARGET_BOARD_SUFFIX := _64

# Bootloader
TARGET_NO_BOOTLOADER := true

# Build
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

# Kernel
BOARD_KERNEL_BASE := 0x80000000
BOARD_KERNEL_CMDLINE := androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 androidboot.bootdevice=7824900.sdhci firmware_class.path=/vendor/firmware_mnt/image loop.max_part=7
BOARD_KERNEL_CMDLINE += androidboot.usbconfigfs=true
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_TAGS_OFFSET := 0x00000100
BOARD_RAMDISK_OFFSET := 0x1000000
BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb
BOARD_MKBOOTIMG_ARGS := --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
TARGET_KERNEL_SOURCE := kernel/oppo/msm8937

# Verity
TARGET_NEEDS_OPPO_VERITY_FAKESIGN ?= true
ifeq ($(TARGET_NEEDS_OPPO_VERITY_FAKESIGN), true)
BOARD_CUSTOM_BOOTIMG_MK := $(PLATFORM_PATH)/boot/mkbootimg.mk
endif

# TWRP - Crypto
TW_INCLUDE_CRYPTO := true

PLATFORM_VERSION := 99.87.36
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)

TARGET_RECOVERY_DEVICE_MODULES += \
    libxml2 \
    vendor.display.config@1.0 \
    vendor.display.config@2.0

RECOVERY_LIBRARY_SOURCE_FILES += \
    $(TARGET_OUT_SHARED_LIBRARIES)/libxml2.so \
    $(TARGET_OUT_SYSTEM_EXT_SHARED_LIBRARIES)/vendor.display.config@1.0.so \
    $(TARGET_OUT_SYSTEM_EXT_SHARED_LIBRARIES)/vendor.display.config@2.0.so

# TWRP - Crypto - FBE
BOARD_USES_QCOM_FBE_DECRYPTION := true
TW_USE_FSCRYPT_POLICY := 1

# TWRP - Crypto - FDE
BOARD_USES_QCOM_DECRYPTION := true
TARGET_CRYPTFS_HW_PATH := $(PLATFORM_PATH)/cryptfs_hw
TARGET_HW_DISK_ENCRYPTION := true
TARGET_RECOVERY_DEVICE_MODULES += libcryptfs_hw
RECOVERY_LIBRARY_SOURCE_FILES += $(TARGET_OUT_SHARED_LIBRARIES)/libcryptfs_hw.so

# Keymaster
TARGET_PROVIDES_KEYMASTER := true

# Partitions
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 2684354560
BOARD_CACHEIMAGE_PARTITION_SIZE := 268435456
BOARD_PERSISTIMAGE_PARTITION_SIZE := 33554432
BOARD_VENDORIMAGE_PARTITION_SIZE := 268435456
BOARD_FLASH_BLOCK_SIZE := 131072 # (BOARD_KERNEL_PAGESIZE * 64)
TARGET_COPY_OUT_VENDOR := vendor
TARGET_USERIMAGES_USE_F2FS := true

# Recovery
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_HAS_NO_SELECT_BUTTON := true
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_RECOVERY_DEVICE_DIRS += $(PLATFORM_PATH)

# VINTF
PRODUCT_ENFORCE_VINTF_MANIFEST := true

# TWRP Configuration
TW_THEME := portrait_hdpi
TW_EXTRA_LANGUAGES := true
TW_DEFAULT_BRIGHTNESS := 127
TW_MAX_BRIGHTNESS := 255
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_SCREEN_BLANK_ON_BOOT := true
TW_HAS_EDL_MODE := true
TARGET_RECOVERY_QCOM_RTC_FIX := true
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"
BOARD_SUPPRESS_SECURE_ERASE := true
RECOVERY_SDCARD_ON_DATA := true
RECOVERY_GRAPHICS_USE_LINELENGTH := true

# TWRP add-ons
TW_INCLUDE_NTFS_3G := true
TW_INCLUDE_FASTBOOTD := true
TW_INCLUDE_FB2PNG := true
TW_INCLUDE_RESETPROP := true
TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD := true

# TWRP removals
TW_EXCLUDE_APEX := true
TW_EXCLUDE_PYTHON := true

# Disable Mouse Cursor
TW_INPUT_BLACKLIST := "hbtp_vm"

# exFAT FS Support
TW_INCLUDE_FUSE_EXFAT := true
