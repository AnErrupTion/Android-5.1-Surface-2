# NVIDIA Tegra4 "Tegratab" development system
#
# Copyright (c) 2012-2013, NVIDIA Corporation.  All rights reserved.
# AndroidProducts.mk is included before BoardConfig.mk, variable essential at
# start of build and used in here should always be intialized in this file

# SECURE_OS_BUILD, NV_TN_SKU and NV_TN_PLATFORM can be set from environment
# because of ?= intialization

# SECURE_OS_BUILD - allowed values y,n
# default: y
SECURE_OS_BUILD ?= y

# NV_TN_SKU - allowed values tn7_114gp, tn7_114np, tn7_114gp_2014, tn7_114np_2014
# Default: tn7_114gp (GMS + PREMIUM)

ifeq ($(NV_TN_SKU),)
    ifeq ($(SECURE_OS_BUILD), n)
        NV_TN_SKU := tn7_114np
    else
        NV_TN_SKU := tn7_114gp
    endif
endif

## REFERENCE_DEVICE
REFERENCE_DEVICE := tegratab

# DEV_TEGRATAB_PATH
DEV_TEGRATAB_PATH := device/nvidia/tegratab

# Android currently has some problems with Bluetooth on the Surface 2, so we disable it
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_no_telephony_no_bluetooth.mk)

# Thse are default settings, it gets changed as per sku manifest properties
PRODUCT_NAME := tegratab
PRODUCT_DEVICE := tegratab
PRODUCT_MANUFACTURER := NVIDIA
PRODUCT_BRAND := nvidia

# SKU specific packages, variables resides in sku specific device makefile
$(call inherit-product, device/nvidia/tegratab/skus/tn7/$(NV_TN_SKU).mk)

# Rest of the packages
$(call inherit-product, device/nvidia/tegratab/device.mk)
$(call inherit-product-if-exists, device/nvidia/tegratab/lbh/lbh.mk)
$(call inherit-product-if-exists, vendor/nvidia/tegra/secureos/nvsi/nvsi.mk)
$(call inherit-product-if-exists, vendor/nvidia/tegra/tegratab/partition-data/factory-ramdisk/factory.mk)
