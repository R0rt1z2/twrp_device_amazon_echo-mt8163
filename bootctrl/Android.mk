#
# Copyright (C) 2026 The Team Win Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

ifeq ($(AB_OTA_UPDATER),true)

include $(CLEAR_VARS)
LOCAL_MODULE := bootctrl_amzn
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := bootctrl_amzn.c
LOCAL_C_INCLUDES := hardware/libhardware/include
LOCAL_WHOLE_STATIC_LIBRARIES := libamznbcb
include $(BUILD_STATIC_LIBRARY)

endif
