#
# Copyright (C) 2026 The Team Win Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/amazon/mt8163-echo/checkers
DEVICE_ARCH := arm

# Screen
TARGET_SCREEN_WIDTH := 960
TARGET_SCREEN_HEIGHT := 480

# Thermal
TW_CUSTOM_CPU_TEMP_PATH := /sys/devices/virtual/thermal/thermal_zone10/temp

include device/amazon/mt8163-echo/BoardConfigCommon.mk
