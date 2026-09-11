#
# Copyright (C) 2026 The Team Win Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/amazon/mt8163-echo/biscuit
DEVICE_ARCH := arm

# Traits
DEVICE_HAS_SCREEN := false
DEVICE_HAS_LEDS := true
DEVICE_USES_AB := true

# Kernel
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,32N2 androidboot.selinux=permissive
BOARD_RAMDISK_OFFSET := 0x06000000
DEVICE_KERNEL_IMAGE := zImage-dtb

# Recovery
TARGET_USE_CUSTOM_LUN_FILE_PATH := /sys/devices/platform/mt_usb/musb-hdrc.0.auto/gadget/lun%d/file
RECOVERY_SDCARD_ON_DATA := true

# OTA
TW_OTA_ASSERT_DEVICES := biscuit,biscuit_puffin

# TWRP
TW_INCLUDE_CRYPTO := false
TW_NO_LEGACY_PROPS := true

include device/amazon/mt8163-echo/BoardConfigCommon.mk
