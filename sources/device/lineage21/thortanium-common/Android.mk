#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

ifneq ($(filter msm8937 msm8952 msm8953,$(TARGET_BOARD_PLATFORM)),)

include $(call all-makefiles-under,$(LOCAL_PATH))

include $(CLEAR_VARS)

# A/B builds require us to create the mount points at compile time.
# Just creating it for all cases since it does not hurt.
FIRMWARE_MOUNT_POINT := $(TARGET_OUT_VENDOR)/firmware_mnt
$(FIRMWARE_MOUNT_POINT): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating $(FIRMWARE_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/firmware_mnt

DSP_MOUNT_POINT := $(TARGET_OUT_VENDOR)/dsp
$(DSP_MOUNT_POINT): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating $(DSP_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/dsp

ALL_DEFAULT_INSTALLED_MODULES += $(FIRMWARE_MOUNT_POINT) $(DSP_MOUNT_POINT)

# Sound trigger HAL uses direct path with TARGET_BOARD_PLATFORM
# instead of loading with just module ID, so we have to create
# a compile time symlink.
SOUND_TRIGGER_HAL_SYMLINK := \
	$(TARGET_OUT_VENDOR)/lib/hw/sound_trigger.primary.$(TARGET_BOARD_PLATFORM).so \
	$(TARGET_OUT_VENDOR)/lib64/hw/sound_trigger.primary.$(TARGET_BOARD_PLATFORM).so
$(SOUND_TRIGGER_HAL_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "Sound trigger HAL link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -s $(subst $(TARGET_OUT_VENDOR),/vendor,$(subst $(TARGET_BOARD_PLATFORM),qcom,$@)) $@

ALL_DEFAULT_INSTALLED_MODULES += $(SOUND_TRIGGER_HAL_SYMLINK)

# WCNSS config file symlink
WCNSS_INI_SYMLINK := $(TARGET_OUT_VENDOR)/firmware/wlan/prima/WCNSS_qcom_cfg.ini
$(WCNSS_INI_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@echo "WCNSS config ini link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /vendor/etc/wifi/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(WCNSS_INI_SYMLINK)

endif
