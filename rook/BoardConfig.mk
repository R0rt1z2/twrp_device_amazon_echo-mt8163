#
# Copyright (C) 2026 The Team Win Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/amazon/mt8163-echo/rook
DEVICE_ARCH := arm64

# Kernel
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2 firmware_class.path=/system/vendor/firmware
BOARD_KERNEL_BASE := 0x40078000
BOARD_KERNEL_OFFSET := 0
BOARD_KERNEL_PAGESIZE := 2048
BOARD_MKBOOTIMG_ARGS := --base 0x40078000 --kernel_offset 0x00008000 --ramdisk_offset 0x291cce00 --second_offset 0x00e80000 --tags_offset 0x07f88000

# Screen
TARGET_SCREEN_WIDTH := 480
TARGET_SCREEN_HEIGHT := 480

# Recovery
TARGET_USE_CUSTOM_LUN_FILE_PATH := /sys/devices/platform/mt_usb/musb-hdrc.0.auto/gadget/lun%d/file

# TWRP
TW_THEME := spot_mdpi
TW_ROTATION := 0

RECOVERY_TOUCHSCREEN_SWAP_XY := false
RECOVERY_TOUCHSCREEN_FLIP_Y := false

include device/amazon/mt8163-echo/BoardConfigCommon.mk
