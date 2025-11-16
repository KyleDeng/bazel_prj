
# ----------------------------------------------------
# 为单元测试可执行程序生成规则
# ----------------------------------------------------

# 清除 LOCAL_xxx 变量
include $(CLEAR_VARS)

# 定义单元测试目标和源码列表
LOCAL_MODULE := ut_$(UT_MODULE)
LOCAL_SRC_FILES := $(UT_TEST_FILES)
UT_TARGET := $(XMAKE_OUTDIR)/bin/$(LOCAL_MODULE)
UT_TARGETS += $(UT_TARGET)

# 通用选项
LOCAL_CFLAGS += -I$(TOPDIR)/ut/externals/gtest/include 
LOCAL_CFLAGS += -I$(TOPDIR)/ut/externals/mockcpp/include
LOCAL_LDFLAGS += $(UT_MOCK_INCLUDE)
LOCAL_LDFLAGS += -Lexternals/gtest/lib -lgtest -lgmock -lpthread
LOCAL_LDFLAGS += -Lexternals/mockcpp/lib -lmockcpp

# 添加hal和sdk的产物
LOCAL_CFLAGS += -I$(TOPDIR)/output/hal/include
LOCAL_CFLAGS += -I$(TOPDIR)/output/sdk/include
LOCAL_LDFLAGS += -L$(TOPDIR)/output/sdk/lib -lsdk
LOCAL_LDFLAGS += -L$(TOPDIR)/output/hal/lib -lhal


# 生成可执行程序
include $(BUILD_EXECUTABLE)

# ----------------------------------------------------
