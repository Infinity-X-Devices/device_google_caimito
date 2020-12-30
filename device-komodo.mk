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

# Display
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/permissions/permissions_com.android.pixeldisplayservice.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/permissions_com.android.pixeldisplayservice.xml

# EUICC
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/permissions/permissions_com.google.android.euicc.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/permissions_com.google.android.euicc.xml

# Google Camera
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/sysconfig/the_experiences.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/the_experiences.xml

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
    FrameworkResOverlayVendorKomodo \
    PixelDisplayServiceOverlayProductKomodo \
    PixelNfcOverlayKomodo \
    PixelUwbOverlayCT3 \
    SettingsGoogleOverlayVendorKomodo \
    SettingsKomodoOverlay \
    SystemUIGoogleOverlayVendorKomodo

PRODUCT_PACKAGES += \
    ApertureOverlayKomodo

# PowerShare
include hardware/google/pixel/powershare/device.mk

# Properties
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/$(DEVICE_CODENAME)/product.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/$(DEVICE_CODENAME)/vendor.prop

# Recovery
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/init.recovery.device.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.komodo.rc

PRODUCT_PACKAGES += \
    init.recovery.caimito.touch.rc

# Satellite
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/conf/allowlist_satellite.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/allowlist_satellite.xml \
    frameworks/native/data/etc/android.hardware.telephony.satellite.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.hardware.telephony.satellite.xml

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH)

# Set support hide display cutout feature
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_hide_display_cutout=true

PRODUCT_PACKAGES += \
    NoCutoutOverlay \
    AvoidAppsInCutoutOverlay

# VINTF
DEVICE_PRODUCT_COMPATIBILITY_MATRIX_FILE += \
    $(DEVICE_PATH)/vintf/device_framework_matrix_product.xml

# Window extensions
$(call inherit-product, $(SRC_TARGET_DIR)/product/window_extensions.mk)

PRODUCT_PACKAGES += fir-proximity-feature.xml
