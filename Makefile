
-include build/global_config.config

############################################################
# 默认编译目标
############################################################
all: app


############################################################
# build config
############################################################
BUILD_STATIC ?= 1
BUILD_SHARED ?=

############################################################
# 输出路径定义
############################################################
ROOT_DIR=$(shell pwd)
OUTPUT_DIR=$(ROOT_DIR)/output
OUTPUT_HAL_DIR=$(OUTPUT_DIR)/hal
OUTPUT_SDK_DIR=$(OUTPUT_DIR)/sdk
OUTPUT_APP_DIR=$(OUTPUT_DIR)/app


############################################################
# 使用xmake
############################################################
# GCC编译动态库需要
XMAKE_SHARED_CFLAGS = -fPIC
# 指定库文件 默认使用动态库
ifeq ($(BUILD_SHARED), 1)
XMAKE_EXECUTABLE_LDFLAGS = $(OUTPUT_SDK_DIR)/lib/libsdk.so $(OUTPUT_HAL_DIR)/lib/libhal.so
else
XMAKE_EXECUTABLE_LDFLAGS = -L$(OUTPUT_HAL_DIR)/lib -L$(OUTPUT_SDK_DIR)/lib -lsdk -lhal
endif
# 默认输出路径
XMAKE_OUTDIR := $(OUTPUT_DIR)
include scripts/xmake.mk


ifeq ($(UT), 1)
CFLAGS += -g --coverage
endif


############################################################
# 包含HAL环境依赖定义
############################################################
-include ${ROOT_DIR}/hal/hal.mk
CFLAGS += $(HAL_CFLAGS)


############################################################
# 包含SDK组件依赖定义
############################################################
-include ${ROOT_DIR}/sdk/sdk.mk
CFLAGS += $(SDK_CFLAGS)


############################################################
# 包含APP应用依赖定义
############################################################
include ${ROOT_DIR}/apps/app.mk
CFLAGS += $(APP_CFLAGS)
app:
	@echo "====== build app begin ======="
	@echo APP_NAME=$(APP_NAME)
	make xmake_executable
	@echo "------ build app  end ---------"

app_run: $(OUTPUT_DIR)/bin/$(APP_NAME)
	@echo "====== run app $(APP_NAME) begin ======="
	$<
	@echo "------ run app $(APP_NAME) end ------"


############################################################
# config
############################################################
ifeq ($(CONFIG_PATH),)
CONFIG_PATH:=/tmp
endif

menuconfig:
	@if [ -f ./build/global_config.config ]; then cp -f ./build/global_config.config ./.config; fi
	@python3 -u ./scripts/kconfiglib/menuconfig.py ./build/configList
	@if [ -f ./.config ]; then cp -f ./.config ./build/global_config.config; fi

config_choice:
	@mkdir -p $(CONFIG_PATH)
	@INPUT_CONFIG=`bash ./scripts/get_config.sh`; \
	echo INPUT_CONFIG=$$INPUT_CONFIG; \
	echo CONFIG_PATH=$(CONFIG_PATH); \
	python3 -u ./scripts/kconfiglib/conf2h.py ./build/config/$$INPUT_CONFIG $(CONFIG_PATH)/global_config.h
	@echo "global_config.h is generated !!"

config:
	@if [ ! -f ./build/global_config.config ]; then \
		CONFIG=`bash ./scripts/get_config.sh`; \
		cp ./build/config/$$CONFIG ./build/global_config.config; \
		fi
	@mkdir -p $(CONFIG_PATH)
	@echo INPUT_CONFIG=../global_config.config
	@echo CONFIG_PATH=$(CONFIG_PATH)
	@python3 -u ./scripts/kconfiglib/conf2h.py ./build/global_config.config $(CONFIG_PATH)/global_config.h
	@echo "global_config.h is generated !!"

config_clean:
	rm -f .config*
	rm -f $(CONFIG_PATH)/global_config.h


############################################################
# 单元测试
############################################################
ut_prepare:
	@make -C ut prepare

ut: ut_prepare
	@echo "====== build unit test begin ======="
	@make -C ut ut
	@echo "------ build unit test end ------"

ut_run: ut
	@echo "====== run unit test begin ======"
	make -C ut ut_run
	@echo "------ run unit test end ------"
ifeq ($(COV), 1)
	make -C ut coverage
endif

clean_ut:
	make -C ut clean

ut_debug:
	make -C ut debug


############################################################
# cppcheck进行静态检测
############################################################
# 包含所有SDK组件的源文件目录
SDK_SRC_DIRS := $(shell find sdk -name src -type d)
SDK_SRC_ALL_SUBDIRS := $(foreach dir,$(SDK_SRC_DIRS),$(shell find $(dir) -type d))
 
# cppcheck时是否需要日志
ifeq ($(LOG),1)
CPPCHECK_L := >$(OUTPUT_DIR)/check/cppcheck.log 2>&1
endif
# cppcheck时需要定义的宏 -D开头
CPPCHECK_D :=
# cppcheck时不需要定义的宏 -U开头
CPPCHECK_U :=
# cppcheck时需要的头文件
CPPCHECK_I := $(addprefix -I,$(SDK_INCLUDE_ALL_SUBDIRS))
# cppcheck时需要的源文件
ifdef CHECK
	CPPCHECK_S := $(patsubst %, ./sdk/%/src/, $(CHECK))
else
	CPPCHECK_S := $(SDK_SRC_ALL_SUBDIRS)
endif
 
cppcheck:
	@echo "====== run $(CHECK) cppcheck begin ======"
	cppcheck --enable=warning,style,missingInclude $(CPPCHECK_D) $(CPPCHECK_U) \
	--error-exitcode=99 --force \
	$(CPPCHECK_I) \
	$(CPPCHECK_S) \
	$(CPPCHECK_L)
	@echo "------ run $(CHECK) cppcheck end ------"

############################################################
# doc
############################################################
doc:
	@if [ ! -d output ];then mkdir output; fi
	doxygen ./build/doxfile


############################################################
# HELP
############################################################
help:
	@echo "config                  : 生成global头文件"
	@echo "config_choice           : 选择其他配置生成头文件"
	@echo "menuconfig              : 配置可选功能"
	@echo "hal[UT=]                : 编译HAL层"
	@echo "sdk[UT=]                : 编译SDK层"
	@echo "app(default)            : 生成应用产物"
	@echo "app_run                 : 运行应用产物"
	@echo "doc                     : 生成注释文档"
	@echo "ut[TEST= COV= LOG=]     : 编译单元测试"
	@echo "ut_run[TEST= COV= LOG=] : 运行单元测试"
	@echo "cppcheck[CHECK=]        : sdk代码静态检测"
	@echo "clean                   : clean"


############################################################
# .PHONY
############################################################
clean:
	rm -rf $(OUTPUT_DIR)

.PHONY: all clean hal_static hal_shared hal sdk_static sdk_shared sdk app ut_demo

clean: config_clean

hal_static: $(HAL_STATIC_TARGET)
hal_shared: $(HAL_SHARED_TARGET)
sdk_static: xmake_static
sdk_shared: xmake_shared

ifeq ($(BUILD_STATIC), 1)
hal: hal_static
sdk: sdk_static
endif
ifeq ($(BUILD_SHARED), 1)
hal: hal_shared
sdk: sdk_shared
endif

hal: hal_files
sdk: sdk_files

app: hal sdk


############################################################
# DEBUG
############################################################
# APP_NAME ?= `bash ./scripts/get_sub_dir.sh apps`
debug:
	@echo $(CFLAGS)

auto: clean
	make COV=1 TEST=led ut
