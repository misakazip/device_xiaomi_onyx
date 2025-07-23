#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Enable updating of APEXes
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# A/B
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)

PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-impl \
    android.hardware.boot@1.2-impl.recovery \
    android.hardware.boot@1.2-service

PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=ext4 \
    POSTINSTALL_OPTIONAL_vendor=true

PRODUCT_PACKAGES += \
    checkpoint_gc \
    otapreopt_script

# API levels
BOARD_API_LEVEL := 202404
PRODUCT_SHIPPING_API_LEVEL := 35

# fastbootd
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.1-impl-mock \
    fastbootd

# Health
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

# Overlays
PRODUCT_ENFORCE_RRO_TARGETS := *

# Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Product characteristics
PRODUCT_CHARACTERISTICS := nosdcard

# Rootdir
PRODUCT_PACKAGES += \
    coresight_reset_source_sink.sh \
    dcc-script-tuna.sh \
    dcc-script.sh \
    dcc_extension.sh \
    flash.sh \
    flash_before.sh \
    init.class_main.sh \
    init.crda.sh \
    init.kernel.extra_free_kbytes.sh \
    init.kernel.init_boot-memory.sh \
    init.kernel.post_boot-kera.sh \
    init.kernel.post_boot-kera_2_3_1.sh \
    init.kernel.post_boot-kera_2_4_0.sh \
    init.kernel.post_boot-kera_3_2_1.sh \
    init.kernel.post_boot-kera_default_3_4_1.sh \
    init.kernel.post_boot-memory.sh \
    init.kernel.post_boot-sun.sh \
    init.kernel.post_boot-sun_5_2.sh \
    init.kernel.post_boot-sun_6_0.sh \
    init.kernel.post_boot-sun_default_6_2.sh \
    init.kernel.post_boot-tuna.sh \
    init.kernel.post_boot-tuna_1_3_2_1.sh \
    init.kernel.post_boot-tuna_2_2_2_1.sh \
    init.kernel.post_boot-tuna_2_3_1_1.sh \
    init.kernel.post_boot-tuna_2_3_2_0.sh \
    init.kernel.post_boot-tuna_default_2_3_2_1.sh \
    init.kernel.post_boot.sh \
    init.mdm.sh \
    init.qcom.class_core.sh \
    init.qcom.coex.sh \
    init.qcom.early_boot.sh \
    init.qcom.efs.sync.sh \
    init.qcom.post_boot.sh \
    init.qcom.sdio.sh \
    init.qcom.sensors.sh \
    init.qcom.sh \
    init.qcom.usb.sh \
    init.qcrild.sh \
    init.qti.display_boot.sh \
    init.qti.kernel.debug-kera.sh \
    init.qti.kernel.debug-sun.sh \
    init.qti.kernel.debug-tuna.sh \
    init.qti.kernel.debug.sh \
    init.qti.kernel.early_debug-kera.sh \
    init.qti.kernel.early_debug-sun.sh \
    init.qti.kernel.early_debug-tuna.sh \
    init.qti.kernel.early_debug.sh \
    init.qti.kernel.sh \
    init.qti.keymaster.sh \
    init.qti.media.sh \
    init.qti.qcv.sh \
    init.qti.write.sh \
    init.qvrd.usb_mtu_set.sh \
    init.xrcommd.usb_mtu_set.sh \
    qca6234-service.sh \
    system_dlkm_modprobe.sh \
    ufs_ffu.sh \
    vendor.qti.diag.sh \
    vendor_modprobe.sh \

PRODUCT_PACKAGES += \
    fstab.qcom \
    init.batterysecret.rc \
    init.mi_thermald.rc \
    init.qcom.factory.rc \
    init.qcom.rc \
    init.qcom.usb.rc \
    init.qti.kernel.rc \
    init.qti.kernel.target.rc \
    init.qti.ufs.rc \
    init.target.rc \
    init.recovery.hardware.rc \
    init.recovery.qcom.rc \
    miui.factoryreset.rc \

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.qcom:$(TARGET_VENDOR_RAMDISK_OUT)/first_stage_ramdisk/fstab.qcom

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Inherit the proprietary files
$(call inherit-product, vendor/xiaomi/onyx/onyx-vendor.mk)
