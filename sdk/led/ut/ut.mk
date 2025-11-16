
# 当前文件所在目录
LOCAL_PATH := $(call my-dir)

#---------------------------------------

# 清除UT相关变量
include $(UT_CLEAR_VARS)

# 当前模块名，根据目录名生成
UT_MODULE := $(notdir $(patsubst %/ut,%,$(LOCAL_PATH)))

# 测试用例源文件
UT_TEST_FILES := $(shell find $(LOCAL_PATH)/test -name "*.cpp")


# 包含单元测试编译辅助工具
include $(UT_BUILD_TARGET)

#---------------------------------------

