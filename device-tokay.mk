#
# SPDX-FileCopyrightText: 2021 The Android Open-Source Project
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-FileCopyrightText: The Calyx Institute
# SPDX-License-Identifier: Apache-2.0
#

# Kernel
TARGET_LINUX_KERNEL_VERSION := 6.1
TARGET_KERNEL_DEVICE := caimito
TARGET_KERNEL_PATH := device/google/caimito-kernels
TARGET_KERNEL_DIR := $(TARGET_KERNEL_PATH)/6.1
TARGET_BOARD_KERNEL_HEADERS := $(TARGET_KERNEL_DIR)/kernel-headers
TARGET_PREBUILT_KERNEL := $(TARGET_KERNEL_DIR)/Image.lz4
LOCAL_KERNEL := $(TARGET_KERNEL_DIR)/Image.lz4

LOCAL_PATH := device/google/caimito

ifneq ($(TARGET_BOOTS_16K),true)
PRODUCT_16K_DEVELOPER_OPTION := true
endif

# Shipping API level
SHIPPING_API_LEVEL := 34

# Inherit from zumapro
include device/google/zumapro/common.mk

# Always use scudo for memory allocator
PRODUCT_USE_SCUDO := true

# Camera
$(call inherit-product-if-exists, vendor/google/camera/config.mk)

# Face unlock
$(call inherit-product-if-exists, vendor/google/faceunlock/config.mk)

# Pixel APN list
$(call inherit-product, vendor/google/CarrierSettings/telephony.mk)

# Overlays
PRODUCT_PACKAGES += \
    ConnectivityResourcesOverlayCaimitoOverride \
    FrameworkResOverlayProductCaimito \
    FrameworkResOverlayVendorCaimito \
    PixelNfcOverlayCaimito \
    PixelWifiOverlay2024Caimito \
    SafetyRegulatoryInfoOverlayProductCaimito \
    SettingsGoogleOverlayProductCaimito \
    SystemUIGoogleOverlayVendorCaimito \
    TeleServiceOverlayVendorCaimito \
    TelecomOverlayProductCaimito

PRODUCT_PACKAGES += \
    FrameworkResOverlayVendorTokay \
    PixelDisplayServiceOverlayProductTokay \
    PixelNfcOverlayTokay \
    SettingsGoogleOverlayVendorTokay \
    SettingsTokayOverlay \
    SystemUIGoogleOverlayVendorTokay

PRODUCT_PACKAGES += \
    ApertureOverlayTokay

# PowerShare
include hardware/google/pixel/powershare/device.mk

# Properties
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/$(DEVICE_CODENAME)/product.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/$(DEVICE_CODENAME)/vendor.prop

# Recovery
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/init.recovery.device.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.tokay.rc

PRODUCT_PACKAGES += \
    init.recovery.caimito.touch.rc

# Satellite
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/conf/allowlist_satellite.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/allowlist_satellite.xml \
    frameworks/native/data/etc/android.hardware.telephony.satellite.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.hardware.telephony.satellite.xml

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH)

# VINTF
DEVICE_PRODUCT_COMPATIBILITY_MATRIX_FILE += \
    $(DEVICE_PATH)/vintf/device_framework_matrix_product.xml

# Window extensions
$(call inherit-product, $(SRC_TARGET_DIR)/product/window_extensions.mk)
