# Copyright 2006 The Android Open Source Project
# Copyright 2025 The LineageOS Project

LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES:= \
	legacy_rild.c

LOCAL_SHARED_LIBRARIES := \
	libcutils \
	libdl \
	liblog \
	libril

# Temporary hack for broken vendor RILs.
LOCAL_WHOLE_STATIC_LIBRARIES := \
	librilutils

LOCAL_CFLAGS := -DRIL_SHLIB
LOCAL_CFLAGS += -Wall -Wextra -Werror

LOCAL_CFLAGS += -DPRODUCT_COMPATIBLE_PROPERTY
LOCAL_CFLAGS += -DANDROID_MULTI_SIM
LOCAL_CFLAGS += -DANDROID_SIM_COUNT_2

LOCAL_MODULE_RELATIVE_PATH := hw
LOCAL_PROPRIETARY_MODULE := true
LOCAL_MODULE:= legacy_rild
LOCAL_INIT_RC := legacy_rild.rc

include $(BUILD_EXECUTABLE)

# Extension script for retries
include $(CLEAR_VARS)
LOCAL_MODULE       := legacy_rild.sh
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := legacy_rild.sh
LOCAL_MODULE_PATH  := $(TARGET_OUT_VENDOR_EXECUTABLES)
include $(BUILD_PREBUILT)
