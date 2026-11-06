#
# AERA Recovery product for OPPO R9 Plusm A (r9plus)
#

$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# AERA/TWRP common recovery configuration
$(call inherit-product, vendor/twrp/config/common.mk)

# Device configuration
$(call inherit-product, device/oppo/r9plus/device.mk)

PRODUCT_DEVICE := r9plus
PRODUCT_NAME := twrp_r9plus
PRODUCT_BRAND := OPPO
PRODUCT_MODEL := OPPO R9 Plusm A
PRODUCT_MANUFACTURER := OPPO

PRODUCT_BUILD_PROP_OVERRIDES += \
    TARGET_DEVICE="R9PlusA" \
    PRODUCT_NAME="R9PlustmA"

# Match the verified shipping fingerprint family.
BUILD_FINGERPRINT := OPPO/R9PlusmA/R9PlusA:5.1.1/LMY47V/1390465867:user/release-keys

# Language / density used by the AERA UI
PRODUCT_DEFAULT_LANGUAGE := en
PRODUCT_DEFAULT_REGION := US
TARGET_SCREEN_DENSITY := 480
