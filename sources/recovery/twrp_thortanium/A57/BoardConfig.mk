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

-include device/oppo/thortanium/BoardConfig.mk

DEVICE_PATH := $(PLATFORM_PATH)/A57

# OTA
TARGET_OTA_ASSERT_DEVICE := A57,CPH1701

# Platform
TARGET_BOARD_PLATFORM := msm8937
TARGET_BOARD_PLATFORM_GPU := qcom-adreno505

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := MSM8937

# Kernel
TARGET_KERNEL_CONFIG := lineageos_A57_recovery_defconfig

# Partitions
BOARD_USERDATAIMAGE_PARTITION_SIZE := 27497291264 # (27497307648-16384)

# Recovery
TARGET_RECOVERY_DEVICE_DIRS += $(DEVICE_PATH)

# TWRP Configuration
TW_CUSTOM_CPU_TEMP_PATH := "/sys/devices/virtual/thermal/thermal_zone14/temp"
