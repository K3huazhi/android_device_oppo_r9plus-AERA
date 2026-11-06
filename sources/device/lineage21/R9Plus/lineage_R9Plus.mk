#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from R9Plus device
$(call inherit-product, device/oppo/R9Plus/device.mk)

# Inherit some common LineageOS stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Set shipping API level
$(call inherit-product, $(SRC_TARGET_DIR)/product/product_launched_with_l_mr1.mk)

# Device identifiers.
PRODUCT_NAME := lineage_R9Plus
PRODUCT_DEVICE := R9Plus
PRODUCT_MANUFACTURER := OPPO
PRODUCT_BRAND := OPPO
PRODUCT_MODEL := OPPO R9 Plus

PRODUCT_GMS_CLIENTID_BASE := android-oppo

PRODUCT_BUILD_PROP_OVERRIDES += \
    TARGET_DEVICE=R9Plus \
    PRIVATE_BUILD_DESC="msm8952_64-user 5.1.1 LMY47V eng.root.20190904.035419 dev-keys"

BUILD_FINGERPRINT := "OPPO/R9PlusmA/R9PlusA:5.1.1/LMY47V/1521209354:user/release-keys"
