#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-FileCopyrightText: The Calyx Institute
# SPDX-License-Identifier: Apache-2.0
#

# Inherit some Infinity-X stuff
$(call inherit-product, vendor/infinity/config/common_full_phone.mk)

# Infinity-X Flags
WITH_GAPPS := true
INFINITY_BUILD_TYPE := OFFICIAL
INFINITY_MAINTAINER := Pyrtle93
TARGET_HAS_UDFPS := true
TARGET_SUPPORTS_GFU := true
PRODUCT_NO_CAMERA := true
TARGET_SUPPORTS_QUICK_TAP := true
TARGET_EXCLUDES_AUDIOFX := true

# Inherit device configuration
DEVICE_CODENAME := tokay
DEVICE_PATH := device/google/caimito
VENDOR_PATH := vendor/google/tokay
$(call inherit-product, $(DEVICE_PATH)/aosp_$(DEVICE_CODENAME).mk)

# Device identifier. This must come after all inclusions
PRODUCT_BRAND := google
PRODUCT_MODEL := Pixel 9
PRODUCT_NAME := infinity_$(DEVICE_CODENAME)

# Boot animation
TARGET_SCREEN_HEIGHT := 2424
TARGET_SCREEN_WIDTH := 1080

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="tokay-user 16 BP4A.260205.002 14624737 release-keys" \
    BuildFingerprint=google/tokay/tokay:16/BP4A.260205.002/14624737:user/release-keys \
    DeviceProduct=$(DEVICE_CODENAME)

$(call inherit-product, $(VENDOR_PATH)/$(DEVICE_CODENAME)-vendor.mk)
