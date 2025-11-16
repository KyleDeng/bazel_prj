# 当前文件所在目录
LOCAL_PATH := $(call my-dir)

#---------------------------------------

# 清除 LOCAL_xxx 变量
include $(CLEAR_VARS)

# 当前模块名
LOCAL_MODULE := $(notdir $(LOCAL_PATH))

# 模块源代码
# LOCAL_SRC_FILES := $(shell find $(LOCAL_PATH)/src -name "*.c")

# CFLAGS
CFLAGS += -I$(LOCAL_PATH)/include

CONFIG_PATH := $(LOCAL_PATH)/include


#---------------------------------------

