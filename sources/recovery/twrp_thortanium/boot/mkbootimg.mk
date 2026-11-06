LOCAL_PATH := $(call my-dir)

#
# This Makefile appends the public key extracted from stock ROM
# which is required to boot custom images on this device, since
# OPPO accidentally shipped an engineering bootloader on an earlier
# version.
#

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(BOOTIMAGE_EXTRA_DEPS)
	$(call pretty,"Target boot image: $@")
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE))

$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(recovery_ramdisk) $(recovery_kernel)
	@echo ----- Making recovery image ------
	$(call build-recoveryimage-target, $@)
	$(hide) cat $(LOCAL_PATH)/recovery.patch >> $@
	$(hide) $(call assert-max-image-size,$@,$(call get-hash-image-max-size,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE)))
