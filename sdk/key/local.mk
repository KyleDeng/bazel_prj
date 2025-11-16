# 当前文件所在目录
LOCAL_PATH := $(call my-dir)

#---------------------------------------

# 清除 LOCAL_xxx 变量
include $(CLEAR_VARS)

# 当前模块名
LOCAL_MODULE := $(notdir $(LOCAL_PATH))

# 取消编译功能
LOCAL_EXCLUDE := $(shell echo $(COMPONENTS_EXCLUDE_LIST) | grep -o "\<$(LOCAL_MODULE)\>")

ifeq ($(LOCAL_EXCLUDE),)

# 模块源代码
LOCAL_SRC_FILES := $(shell find $(LOCAL_PATH)/src -name "*.c")

# 模块的 CFLAGS
LOCAL_CFLAGS := -I$(LOCAL_PATH)/include

# 生成静态库
include $(BUILD_STATIC_LIBRARY)

# 生成动态库
include $(BUILD_SHARED_LIBRARY)

endif


#---------------------------------------

