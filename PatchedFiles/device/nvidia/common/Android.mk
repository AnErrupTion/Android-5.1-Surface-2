LOCAL_PATH := $(call my-dir)

# init_tf.rc, based on secureos is enabled or disbaled
include $(NVIDIA_DEFAULTS)
ifeq ($(SECURE_OS_BUILD),y)
LOCAL_SRC_FILES := init.tf_enabled.rc
else
LOCAL_SRC_FILES := init.tf_disabled.rc
endif
LOCAL_MODULE := init.tf
LOCAL_MODULE_SUFFIX := .rc
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_ROOT_OUT)
LOCAL_MODULE_TAGS := optional
include $(NVIDIA_PREBUILT)

# init.qvs.rc for qvs automation
include $(NVIDIA_DEFAULTS)
LOCAL_SRC_FILES := init.qvs.rc
LOCAL_MODULE := init.qvs
LOCAL_MODULE_SUFFIX := .rc
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_ROOT_OUT)
LOCAL_MODULE_TAGS := optional
include $(NVIDIA_PREBUILT)

# init.hdcp.rc
include $(NVIDIA_DEFAULTS)
LOCAL_SRC_FILES := init.hdcp.rc
LOCAL_MODULE := init.hdcp
LOCAL_MODULE_SUFFIX := .rc
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_ROOT_OUT)
LOCAL_MODULE_TAGS := optional
include $(NVIDIA_PREBUILT)

include $(call all-makefiles-under,$(LOCAL_PATH))
