#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/onyx

# A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    init_boot \
    vendor \
    system \
    odm \
    boot \
    product \
    dtbo \
    system_ext \
    vendor_dlkm \
    recovery \
    vendor_boot \
    system_dlkm
BOARD_USES_RECOVERY_AS_BOOT := true

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a 
TARGET_CPU_VARIANT := oryon
TARGET_CPU_VARIANT_RUNTIME := oryon

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := sun
TARGET_NO_BOOTLOADER := true

# Display
TARGET_SCREEN_DENSITY := 520
TARGET_USES_VULKAN := true

# Kernel
BOARD_BOOTIMG_HEADER_VERSION := 4
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_CMDLINE := video=vfb:640x400,bpp=32,memsize=3072000 erofs.reserved_pages=64 swinfo.fingerprint=onyx:15/OS2.0.102.0.VOLMIXM:user mtdoops.fingerprint=onyx:15/OS2.0.102.0.VOLMIXM:user bootmonitor.fingerprint=onyx:15/OS2.0.102.0.VOLMIXM:user bootconfig
BOARD_KERNEL_PAGESIZE := 4096
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOTIMG_HEADER_VERSION)
BOARD_KERNEL_IMAGE_NAME := Image
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_KERNEL_SEPARATED_DTBO := true
TARGET_KERNEL_CONFIG += vendor/onyx_perf.config vendor/onyx_consolidate.config
TARGET_KERNEL_SOURCE := kernel/xiaomi/onyx

# Kernel - prebuilt
TARGET_FORCE_PREBUILT_KERNEL := true
ifeq ($(TARGET_FORCE_PREBUILT_KERNEL),true)
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilts/kernel
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilts/dtb.img
BOARD_MKBOOTIMG_ARGS += --dtb $(TARGET_PREBUILT_DTB)
BOARD_INCLUDE_DTB_IN_BOOTIMG := 
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilts/dtbo.img
BOARD_KERNEL_SEPARATED_DTBO := 
endif

# Partitions
BOARD_FLASH_BLOCK_SIZE := 262144 # (BOARD_KERNEL_PAGESIZE * 64)
BOARD_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_DTBOIMG_PARTITION_SIZE := 18874368
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 104857600
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_SUPER_PARTITION_SIZE := 9126805504 # TODO: Fix hardcoded value
BOARD_SUPER_PARTITION_GROUPS := xiaomi_dynamic_partitions
BOARD_XIAOMI_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    vendor \
    system \
    odm \
    product \
    system_ext \
    vendor_dlkm \
    system_dlkm
BOARD_XIAOMI_DYNAMIC_PARTITIONS_SIZE := 9122611200 # TODO: Fix hardcoded value

# Platform
TARGET_BOARD_PLATFORM := sun

# Properties
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/props/system.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/props/vendor.prop
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/props/product.prop
TARGET_SYSTEM_EXT_PROP += $(DEVICE_PATH)/props/system_ext.prop
TARGET_SYSTEM_DLKM_PROP += $(DEVICE_PATH)/props/system_dlkm.prop
TARGET_ODM_PROP += $(DEVICE_PATH)/props/odm.prop
TARGET_ODM_DLKM_PROP += $(DEVICE_PATH)/props/odm_dlkm.prop
TARGET_VENDOR_DLKM_PROP += $(DEVICE_PATH)/props/vendor_dlkm.prop

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.qcom
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# Security patch level
VENDOR_SECURITY_PATCH := 2025-05-01

# Verified Boot
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1
BOARD_AVB_VENDOR_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_VENDOR_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_VENDOR_BOOT_ROLLBACK_INDEX := 1
BOARD_AVB_VENDOR_BOOT_ROLLBACK_INDEX_LOCATION := 1

# VINTF
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/manifest.xml

# Inherit the proprietary files
include vendor/xiaomi/onyx/BoardConfigVendor.mk
