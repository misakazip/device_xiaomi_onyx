#
# SPDX-FileCopyrightText: The LineageOS Project
# Copyright (C) 2025 SebaUbuntu's TWRP device tree generator
# Copyright (C) 2025 The Android Open Source Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
TARGET_SUPPORTS_OMX_SERVICE := false
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from sm8735-common
$(call inherit-product-if-exists, device/xiaomi/sm8735-common/common.mk)

# Enable virtual A/B OTA
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# Enable project quotas and casefolding for emulated storage without sdcardfs
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Setup dalvik vm configs
#$(call inherit-product, frameworks/native/build/phone-xhdpi-6144-dalvik-heap.mk)
# Copy from stock rom
PRODUCT_VENDOR_PROPERTIES += \
    dalvik.vm.heapstartsize?=16m \
    dalvik.vm.heapgrowthlimit?=256m \
    dalvik.vm.heapsize?=512m \
    dalvik.vm.heaptargetutilization?=0.5 \
    dalvik.vm.heapminfree?=2m \
    dalvik.vm.heapmaxfree?=32m

# Add common definitions for Qualcomm
$(call inherit-product, hardware/qcom-caf/common/common.mk)

# Call the proprietary setup
$(call inherit-product-if-exists, vendor/xiaomi/onyx/onyx-vendor.mk)

# API
PRODUCT_SHIPPING_API_LEVEL := 35

# A/B
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

# Boot control HAL
PRODUCT_PACKAGES += \
    android.hardware.boot@1.0-impl \
    android.hardware.boot@1.0-service

PRODUCT_PACKAGES += \
    bootctrl.sun

PRODUCT_STATIC_BOOT_CONTROL_HAL := \
    bootctrl.sun \
    libgptutils \
    libz \
    libcutils

PRODUCT_PACKAGES += \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_verifier \
    update_engine_sideload

# Boot animation
TARGET_SCREEN_HEIGHT := 2772
TARGET_SCREEN_WIDTH := 1280

# Fastbootd
PRODUCT_PACKAGES += \
    fastbootd 
