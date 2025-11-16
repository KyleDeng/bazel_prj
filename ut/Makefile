############################################################
# 全局环境变量配置
############################################################
TOPDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../)
TOP_OUTPUT := $(TOPDIR)/output
OUTPUT_DIR := $(TOP_OUTPUT)/ut

CFLAGS   := -g -Werror-implicit-function-declaration
CXXFLAGS := -g --std=c++11

# gcov覆盖率检测
ifeq ($(COV), 1)
CFLAGS   += --coverage
CXXFLAGS += --coverage
XMAKE_EXECUTABLE_LDFLAGS += --coverage
endif

############################################################
# 默认编译目标
############################################################
all: ut_run

############################################################
# 包含所有SDK组件的头文件目录
############################################################
HAL_INCLUDE_DIRS := $(shell find $(TOPDIR)/hal -name include -type d)
HAL_INCLUDE_ALL_SUBDIRS := $(foreach dir,$(HAL_INCLUDE_DIRS),$(shell find $(dir) -type d))
HAL_INCLUDE_FLAGS := $(addprefix -I,$(HAL_INCLUDE_ALL_SUBDIRS))
SDK_INCLUDE_DIRS := $(shell find $(TOPDIR)/sdk -name include -type d)
SDK_INCLUDE_ALL_SUBDIRS := $(foreach dir,$(SDK_INCLUDE_DIRS),$(shell find $(dir) -type d))
SDK_INCLUDE_FLAGS := $(addprefix -I,$(SDK_INCLUDE_ALL_SUBDIRS))
CFLAGS += $(SDK_INCLUDE_FLAGS) $(HAL_INCLUDE_FLAGS)
CXXFLAGS += $(SDK_INCLUDE_FLAGS) $(HAL_INCLUDE_FLAGS)

############################################################
# 使用 xmake 且包含所有SDK组件的local.mk HAL的hal.mk
############################################################
XMAKE_OUTDIR := $(OUTPUT_DIR)
include $(TOPDIR)/scripts/xmake.mk

-include $(TOPDIR)/hal/hal.mk
CFLAGS += $(HAL_CFLAGS)
CXXFLAGS += $(HAL_CFLAGS)

-include $(shell find $(TOPDIR)/sdk -name local.mk)

############################################################
# 包含所有SDK组件的单元测试 ut.mk
############################################################
UT_CLEAR_VARS   := ut_clear.mk
UT_BUILD_TARGET := ut_target.mk
UT_TARGETS      :=
-include $(shell find $(TOPDIR)/sdk -name ut.mk)
-include $(shell find $(TOPDIR)/hal -name ut.mk)

############################################################
# ut 目标定义
############################################################
# 判断是否使用 gdb
UT_USE_GDB :=
ifeq ($(GDB),1)
ifneq ($(TEST),)
UT_USE_GDB := 1
endif
endif

# 参数判断
UT_ARG_FILTER :=
UT_ARG_REPEAT :=
UT_ARG_RUN_DISABLED :=
UT_ARG_PRINT_TIME :=
UT_ARG_OUTPUT :=
ifneq ($(FILTER),)
UT_ARG_FILTER := "--gtest_filter=$(FILTER)"
endif
ifneq ($(REPEAT),)
UT_ARG_FILTER := "--gtest_repeat=$(REPEAT)"
endif
ifeq ($(RUN_DISABLED),1)
UT_ARG_RUN_DISABLED := "--gtest_also_run_disabled_tests"
endif
ifeq ($(PRINT_TIME),0)
UT_ARG_PRINT_TIME := "--gtest_print_time=0"
endif
ifeq ($(LOG),1)
UT_ARG_OUTPUT := "--gtest_output=json:$(XMAKE_OUTDIR)/log/"
endif

# 单元测试运行规则定义
ut_run/%: $(XMAKE_OUTDIR)/bin/ut_%
	@echo "-------- run `basename $^` unit test ------------------------"
ifeq ($(UT_USE_GDB),1)
	cd $(dir $^); gdb $(notdir $^)
else
	cd $(dir $^); ./$(notdir $^) $(UT_ARG_FILTER) $(UT_ARG_REPEAT) $(UT_ARG_RUN_DISABLED) $(UT_ARG_PRINT_TIME) $(UT_ARG_OUTPUT)
endif

ifeq ($(TEST),)
ut: $(UT_TARGETS)
ut_run: $(patsubst $(XMAKE_OUTDIR)/bin/ut_%,ut_run/%,$(UT_TARGETS))
else
ut: $(XMAKE_OUTDIR)/bin/ut_$(TEST)
ut_run: ut_run/$(TEST)
endif


############################################################
# 获取覆盖率
############################################################
coverage:
	make gcov
	make lcov

gcov:
	@_gcda=`find $(TOP_OUTPUT) -name "*.gcda"`; \
	_c=`echo $$_gcda | sed 's,\.gcda,\.c,g'`; echo $$_c; \
	_src=`echo $$_c | grep -oP "(?<=/)\w*\.\w*(?=\.c)"`; echo $$_src; \
	_gcov=`echo $$_src.gcov | sed 's, ,\.gcov ,g'`; echo $$_gcov; \
	gcov $$_c; \
	mkdir $(OUTPUT_DIR)/gcov; \
	cp -f $$_gcov -t $(OUTPUT_DIR)/gcov; \
	rm *.gcov

lcov:
	lcov -c -o locv.info -d $(TOP_OUTPUT) --ignore-errors mismatch
	genhtml locv.info -o $(OUTPUT_DIR)/lcov
	mv locv.info $(OUTPUT_DIR)/lcov

############################################################
# 外部依赖
############################################################
prepare: prepare_gtest

prepare_gtest: externals/gtest/lib/libgtest.a #externals/gtest/lib/libgmock.a
externals/gtest/lib/libgtest.a:
	#externals/gtest/lib/libgmock.a
	@rm -fr externals/gtest
	@git clone https://github.com/KyleDeng/gtest_lib.git externals/gtest
	@git clone https://github.com/KyleDeng/mockcpp_lib.git externals/mockcpp

############################################################
# 其他目标和依赖关系
############################################################
.PHONY: all clean ut ut_run prepare prepare_gtest

# 清空中间文件
clean:
	rm -fr $(OUTPUT_DIR)

############################################################
# debug
############################################################
debug:
	_gcda=`find $(OUTPUT_DIR) -name "*.gcda"`; \
	_c=`echo $$_gcda | sed 's,\.gcda,\.c,g'`; echo $$_c; \
	_src=`echo $$_c | grep -oP "(?<=/)\w*\.\w*(?=\.c)"`; echo $$_src; \
	_gcov=`echo $$_src.gcov | sed 's, ,\.gcov ,g'`; echo $$_gcov; \
	gcov $$_c; \
	mkdir $(OUTPUT_DIR)/gcov; \
	cp -f $$_gcov -t $(OUTPUT_DIR)/gcov; \
	rm *.gcov
	

