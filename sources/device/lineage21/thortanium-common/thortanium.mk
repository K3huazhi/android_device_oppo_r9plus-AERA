#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

COMMON_PATH := device/oppo/thortanium-common

# Add common definitions for Qualcomm
$(call inherit-product, hardware/qcom-caf/common/common.mk)

# Setup dalvik vm configs
$(call inherit-product, frameworks/native/build/phone-xhdpi-4096-dalvik-heap.mk)

# Enable updating of APEXes
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# Disable APEX compression
# Keep this after including updatable_apex.mk
PRODUCT_COMPRESSED_APEX := false

# Bootanimation
TARGET_BOOTANIMATION_HALF_RES := true

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(COMMON_PATH)/overlay \
    $(COMMON_PATH)/overlay-lineage

PRODUCT_ENFORCE_RRO_TARGETS := *

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    hardware/oplus \
    vendor/qcom/opensource/usb/etc \
    $(COMMON_PATH)

# Device uses high-density artwork where available
PRODUCT_AAPT_CONFIG := normal

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml \
    frameworks/native/data/etc/android.hardware.telephony.cdma.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.cdma.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.telephony.ims.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.ims.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute-0.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level-0.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_1.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.software.ipsec_tunnels.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnels.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml \
    frameworks/native/data/etc/android.software.print.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.print.xml \
    frameworks/native/data/etc/android.software.opengles.deqp.level-2020-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2020-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.sip.voip.xml

# Audio
PRODUCT_PACKAGES += \
    android.hardware.audio@6.0-impl \
    android.hardware.audio.effect@6.0-impl \
    android.hardware.audio.service \
    android.hardware.bluetooth.audio-impl \
    android.hardware.soundtrigger@2.1-impl

PRODUCT_PACKAGES += \
    audio.bluetooth.default \
    audio.primary.$(TARGET_OPPO_PLATFORM) \
    audio.r_submix.default \
    audio.usb.default

PRODUCT_PACKAGES += \
    libaudioroute \
    libaudiopreprocessing \
    libqcomvisualizer \
    libqcomvoiceprocessing \
    libqcompostprocbundle \
    libtinycompress \
    libvolumelistener \
    tinymix

PRODUCT_PACKAGES += \
    libhfp \
    libsndmonitor

# Audio configs
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/audio/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    $(COMMON_PATH)/audio/audio_output_policy.conf:$(TARGET_COPY_OUT_VENDOR)/etc/audio_io_policy.conf \
    $(COMMON_PATH)/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    $(COMMON_PATH)/audio/audio_tuning_mixer.txt:$(TARGET_COPY_OUT_VENDOR)/etc/audio_tuning_mixer.txt \
    $(COMMON_PATH)/audio/sound_trigger_mixer_paths.xml:$(TARGET_COPY_OUT_VENDOR)/etc/sound_trigger_mixer_paths.xml \
    $(COMMON_PATH)/audio/sound_trigger_platform_info.xml:$(TARGET_COPY_OUT_VENDOR)/etc/sound_trigger_platform_info.xml

PRODUCT_COPY_FILES += \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    frameworks/av/services/audiopolicy/config/bluetooth_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml

# ANT+
PRODUCT_PACKAGES += \
    AntHalService-Soong \
    com.dsi.ant@1.0.vendor

# Bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0.vendor \
    vendor.qti.hardware.bluetooth_audio@2.0.vendor \
    vendor.qti.hardware.bluetooth_audio@2.1.vendor \
    vendor.qti.hardware.btconfigstore@1.0.vendor \
    vendor.qti.hardware.btconfigstore@2.0.vendor

# Camera
PRODUCT_PACKAGES += \
    camera.$(TARGET_OPPO_PLATFORM) \
    vendor.qti.hardware.camera.device@1.0 \
    libremosaic_daemon \
    libcamshim

PRODUCT_PACKAGES += \
    android.frameworks.sensorservice@1.0.vendor \
    android.hardware.camera.provider@2.4-impl \
    android.hardware.camera.provider@2.4-service \
    android.hardware.camera.provider@2.6:64

PRODUCT_PACKAGES += \
    libgui_vendor \
    libion.vendor \
    libstdc++_vendor \
    android.frameworks.displayservice@1.0.vendor

# Configstore
PRODUCT_PACKAGES += \
    disable_configstore

# Display
PRODUCT_PACKAGES += \
    android.frameworks.displayservice@1.0.vendor \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.mapper@2.0-impl-2.1 \
    gralloc.$(TARGET_OPPO_PLATFORM)

PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.1-service \
    hwcomposer.$(TARGET_OPPO_PLATFORM)

PRODUCT_PACKAGES += \
    android.hardware.memtrack@1.0-impl \
    android.hardware.memtrack@1.0-service \
    memtrack.$(TARGET_OPPO_PLATFORM)

PRODUCT_PACKAGES += \
    libqdMetaData.system \
    libtinyxml \
    vendor.display.config@1.0.vendor

# Doze
PRODUCT_PACKAGES += \
    OplusDoze

# DRM
PRODUCT_PACKAGES += \
    android.hardware.drm@1.4.vendor \
    android.hardware.drm-service.clearkey \
    libprotobuf-cpp-full-3.9.1-vendorcompat

# Filesystem
PRODUCT_PACKAGES += \
    e2fsck_ramdisk \
    tune2fs_ramdisk \
    resize2fs_ramdisk

# Fingerprint
PRODUCT_PACKAGES += \
    android.hardware.biometrics.fingerprint@2.0-service.oppo_thortanium \
    libbinder_shim

# FM
ifeq ($(BOARD_HAVE_QCOM_FM),true)
PRODUCT_PACKAGES += \
    FMRadio \
    libfmjni
endif

# Gatekeeper
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-impl \
    android.hardware.gatekeeper@1.0-service

# GPS / Location
include $(LOCAL_PATH)/gps/gps_vendor_product.mk

PRODUCT_PACKAGES += \
    android.hardware.gnss@2.1.vendor

PRODUCT_PACKAGES += \
    gnss@2.0-base.policy \
    gnss@2.0-xtra-daemon.policy \
    gnss@2.0-xtwifi-client.policy \
    gnss@2.0-xtwifi-inet-agent.policy

# Health
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

PRODUCT_PACKAGES += \
    vendor.lineage.health-service.default

# HIDL
PRODUCT_PACKAGES += \
    android.hidl.allocator@1.0.vendor \
    android.hidl.base@1.0 \
    android.hidl.base@1.0.vendor \
    android.hidl.manager@1.0 \
    android.hidl.manager@1.0.vendor \
    android.hidl.memory@1.0.vendor \
    libhidlmemory.vendor \
    libhidltransport \
    libhidltransport.vendor \
    libhwbinder \
    libhwbinder.vendor

# Input
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/keylayout/gpio-keys.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/gpio-keys.kl \
    $(COMMON_PATH)/keylayout/uinput-fpc.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/uinput-fpc.kl

# IPACM
PRODUCT_PACKAGES += \
    ipacm \
    IPACM_cfg.xml

# IRQ balance
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/configs/msm_irqbalance.conf:$(TARGET_COPY_OUT_VENDOR)/etc/msm_irqbalance.conf

# Keymaster
PRODUCT_PACKAGES += \
    android.hardware.keymaster@3.0-impl \
    android.hardware.keymaster@3.0-service

# Lights
PRODUCT_PACKAGES += \
    android.hardware.light@2.0-service.oppo_thortanium

# LiveDisplay
PRODUCT_PACKAGES += \
    vendor.lineage.livedisplay@2.0-service-sdm \
    vendor.lineage.livedisplay@2.0-service-sysfs

# Media
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/media/$(TARGET_OPPO_PLATFORM)/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    $(COMMON_PATH)/media/$(TARGET_OPPO_PLATFORM)/media_codecs_performance.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_performance.xml \
    $(COMMON_PATH)/media/$(TARGET_OPPO_PLATFORM)/media_profiles_V1_0.xml:$(TARGET_COPY_OUT_ODM)/etc/media_profiles_V1_0.xml

PRODUCT_COPY_FILES += \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_c2_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_c2_video.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_telephony.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_telephony.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_video.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_video_le.xml

# Net
PRODUCT_PACKAGES += \
    android.system.net.netd@1.1.vendor \
    netutils-wrapper-1.0

# OMX
PRODUCT_PACKAGES += \
    libc2dcolorconvert \
    libmm-omxcore \
    libOmxAacEnc \
    libOmxAmrEnc \
    libOmxCore \
    libOmxEvrcEnc \
    libOmxG711Enc \
    libOmxQcelp13Enc \
    libOmxVdec \
    libOmxVenc \
    libstagefrighthw

# Network
PRODUCT_PACKAGES += \
    android.system.net.netd@1.1.vendor

# Perf
PRODUCT_PACKAGES += \
    vendor.qti.hardware.perf@2.2 \
    vendor.qti.hardware.perf@2.2.vendor

PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/configs/perf/$(TARGET_OPPO_PLATFORM)/commonresourceconfigs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/commonresourceconfigs.xml \
    $(COMMON_PATH)/configs/perf/$(TARGET_OPPO_PLATFORM)/perfboostsconfig.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/perfboostsconfig.xml \
    $(COMMON_PATH)/configs/perf/$(TARGET_OPPO_PLATFORM)/perfconfigstore.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/perfconfigstore.xml \
    $(COMMON_PATH)/configs/perf/$(TARGET_OPPO_PLATFORM)/targetconfig.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/targetconfig.xml \
    $(COMMON_PATH)/configs/perf/$(TARGET_OPPO_PLATFORM)/targetresourceconfigs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/perf/targetresourceconfigs.xml

ifneq ($(filter msm8937 msm8952,$(TARGET_OPPO_PLATFORM)),)
$(foreach f,$(wildcard $(COMMON_PATH)/configs/perf/$(TARGET_OPPO_PLATFORM)/perf-profile*.conf),\
        $(eval PRODUCT_COPY_FILES += $(f):$(TARGET_COPY_OUT_VENDOR)/etc/perf/$(notdir $f)))
endif

# Power
PRODUCT_PACKAGES += \
    android.hardware.power@1.2.vendor \
    android.hardware.power-service-qti

PRODUCT_COPY_FILES += \
    vendor/qcom/opensource/power/config/$(TARGET_OPPO_PLATFORM)/powerhint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.xml

# Public libraries
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/configs/public.libraries.txt:$(TARGET_COPY_OUT_VENDOR)/etc/public.libraries.txt

PRODUCT_COPY_FILES += \
    system/core/libprocessgroup/profiles/cgroups_28.json:$(TARGET_COPY_OUT_VENDOR)/etc/cgroups.json \
    system/core/libprocessgroup/profiles/task_profiles_28.json:$(TARGET_COPY_OUT_VENDOR)/etc/task_profiles.json

# Protobuf
PRODUCT_PACKAGES += \
    libprotobuf-cpp-full-3.9.1-vendorcompat \
    libprotobuf-cpp-lite-vendorcompat

# QMI
PRODUCT_PACKAGES += \
    libjson \
    libnetutils.vendor:64 \
    libsqlite.vendor:64 \
    libqti_vndfwk_detect \
    libqti_vndfwk_detect.vendor \
    libvndfwk_detect_jni.qti \
    libvndfwk_detect_jni.qti.vendor

# RIL
PRODUCT_PACKAGES += \
    android.hardware.radio@1.5.vendor \
    android.hardware.radio.config@1.2.vendor \
    android.hardware.radio.deprecated@1.0.vendor \
    android.hardware.secure_element@1.2.vendor \
    libavservices_minijail.vendor \
    librmnetctl \
    libxml2

PRODUCT_PACKAGES += \
    libshims_legacy_ril \
    libril-qcril-oppo \
    legacy_rild.sh \
    legacy_rild

PRODUCT_PACKAGES += \
    android.hardware.radio.c_shim@1.0 \
    android.hardware.radio.c_shim@1.1 \
    android.hardware.radio.c_shim@1.2 \
    android.hardware.radio.config@1.1-service.wrapper

# Rootdir
PRODUCT_PACKAGES += \
    init.qcom.early_boot.sh \
    init.qcom.post_boot.sh \
    init.qcom.sh \
    init.qcom.usb.sh

PRODUCT_PACKAGES += \
    fstab.qcom \
    fstab.qcom.ramdisk \
    init.qcom.rc \
    init.qcom.usb.rc \
    init.recovery.qcom.rc \
    init.target.rc \
    ueventd.qcom.rc

# Sensors
PRODUCT_PACKAGES += \
    android.frameworks.sensorservice@1.0.vendor \
    android.hardware.sensors@1.0-impl \
    android.hardware.sensors@1.0-service \
    libsensorndkbridge \
    libpower.vendor

# Recovery
PRODUCT_PACKAGES += \
    librecovery_updater_oppo

# Speed profile services and wifi-service to reduce RAM and storage
PRODUCT_SYSTEM_SERVER_COMPILER_FILTER := speed-profile
PRODUCT_USE_PROFILE_FOR_BOOT_IMAGE := true
PRODUCT_DEX_PREOPT_BOOT_IMAGE_PROFILE_LOCATION := frameworks/base/config/boot-image-profile.txt

# Telephony
PRODUCT_PACKAGES += \
    libgui_shim \
    ims-ext-common \
    ims_ext_common.xml \
    qti-telephony-hidl-wrapper \
    qti_telephony_hidl_wrapper.xml \
    qti-telephony-utils \
    qti_telephony_utils.xml \
    telephony-ext

PRODUCT_BOOT_JARS += \
    telephony-ext

PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/configs/qmi_fw.conf:$(TARGET_COPY_OUT_VENDOR)/etc/qmi_fw.conf

# Thermal
PRODUCT_PACKAGES += \
    android.hardware.thermal@1.0-impl \
    android.hardware.thermal@1.0-service

# Touch
PRODUCT_PACKAGES += \
    vendor.lineage.touch@1.0-service.oppo_thortanium

# USB
PRODUCT_PACKAGES += \
    oppo_usb_compositions.conf \
    android.hardware.usb@1.3-service.basic \
    android.hardware.usb.gadget@1.2-service-qti

# Vibrator
PRODUCT_PACKAGES += \
    vendor.qti.hardware.vibrator.service

PRODUCT_COPY_FILES += \
    vendor/qcom/opensource/vibrator/excluded-input-devices.xml:$(TARGET_COPY_OUT_VENDOR)/etc/excluded-input-devices.xml

# Whitelisted app
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/configs/qti_whitelist.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/qti_whitelist.xml \
    $(COMMON_PATH)/configs/telephony_system-ext_privapp-permissions-qti.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/telephony_system-ext_privapp-permissions-qti.xml

# Wifi
PRODUCT_PACKAGES += \
    android.hardware.wifi-service \
    hostapd \
    libcld80211 \
    libwifi-hal-ctrl \
    libwifi-hal-qcom \
    libwpa_client \
	TetheringConfigOverlay \
    wcnss_service \
    WifiOverlay \
    wificond \
    wpa_supplicant \
    wpa_supplicant.conf

PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf \
    $(COMMON_PATH)/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf \
    $(COMMON_PATH)/wifi/WCNSS_cfg.dat:$(TARGET_COPY_OUT_VENDOR)/firmware/wlan/prima/WCNSS_cfg.dat \
    $(COMMON_PATH)/wifi/WCNSS_wlan_dictionary.dat:$(TARGET_COPY_OUT_VENDOR)/firmware/wlan/prima/WCNSS_wlan_dictionary.dat

# Inherit the proprietary files
$(call inherit-product, vendor/oppo/thortanium-common/thortanium-common-vendor.mk)
