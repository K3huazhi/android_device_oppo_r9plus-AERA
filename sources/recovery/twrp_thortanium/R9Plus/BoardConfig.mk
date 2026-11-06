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

ifeq ($(TARGET_DEVICE), R9PlusL)
# Verity
TARGET_NEEDS_OPPO_VERITY_FAKESIGN := false
endif

-include device/oppo/thortanium/BoardConfig.mk

DEVICE_PATH := $(PLATFORM_PATH)/R9Plus

# OTA
TARGET_OTA_ASSERT_DEVICE := R9Plus

# Platform
TARGET_BOARD_PLATFORM := msm8952
TARGET_BOARD_PLATFORM_GPU := qcom-adreno510

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := MSM8952

# Kernel
ifeq ($(TARGET_DEVICE), R9PlusL)
BOARD_KERNEL_IMAGE_NAME := Image.gz
BOARD_KERNEL_SEPARATED_DT := true
TARGET_CUSTOM_DTBTOOL := dtbToolOppo
BOARD_DTBTOOL_ARGS := --force-v3
endif
TARGET_KERNEL_CONFIG := lineageos_R9Plus_recovery_defconfig

# Partitions
BOARD_USERDATAIMAGE_PARTITION_SIZE := 58765827072 # (58765843456-16384)

# Recovery
TARGET_RECOVERY_DEVICE_DIRS += $(DEVICE_PATH)

# TWRP Configuration
TW_CUSTOM_CPU_TEMP_PATH := "/sys/devices/virtual/thermal/thermal_zone20/temp"
