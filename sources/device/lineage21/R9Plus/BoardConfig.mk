#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/oppo/R9Plus

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := msm8952

# Kernel
TARGET_NEEDS_OPPO_VERITY_FAKESIGN := false

# Platform
TARGET_BOARD_PLATFORM := msm8952

# Inherit from common device tree
include device/oppo/thortanium-common/BoardConfigCommon.mk

# Display
TARGET_SCREEN_DENSITY := 400

# Init
TARGET_INIT_VENDOR_LIB := //$(DEVICE_PATH):init_oppo_R9Plus
TARGET_RECOVERY_DEVICE_MODULES := init_oppo_R9Plus

# HIDL
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/manifest.xml

# Kernel
BOARD_KERNEL_IMAGE_NAME := Image.gz
BOARD_KERNEL_SEPARATED_DT := true
BOARD_CUSTOM_BOOTIMG := true
BOARD_CUSTOM_BOOTIMG_MK := $(DEVICE_PATH)/mkbootimg.mk
TARGET_KERNEL_CONFIG := lineageos_R9Plus_defconfig
TARGET_KERNEL_RECOVERY_CONFIG := lineageos_R9Plus_recovery_defconfig

# Partitions
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 2147483648
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := squashfs
BOARD_SYSTEMIMAGE_EXTFS_INODE_COUNT := 4096
BOARD_SYSTEMIMAGE_JOURNAL_SIZE := 0
BOARD_SYSTEMIMAGE_SQUASHFS_COMPRESSOR := lz4
BOARD_CACHEIMAGE_PARTITION_SIZE := 134217728

# Properties
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.qcom

# Security patch level
VENDOR_SECURITY_PATCH := 2018-03-05

# SEPolicy
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
