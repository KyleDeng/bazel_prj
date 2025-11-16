############################################################
# 提供编译工具
############################################################
AR = $(COMPILE_PREX)ar
CC = $(COMPILE_PREX)gcc
NM = $(COMPILE_PREX)nm
CPP = $(COMPILE_PREX)g++
STRIP = $(COMPILE_PREX)strip
OBJCOPY = $(COMPILE_PREX)objcopy
OBJDUMP = $(COMPILE_PREX)objdump
RANLIB = $(COMPILE_PREX)ranlib
CXX = $(COMPILE_PREX)g++

############################################################

# 当前文件所在目录
HAL_PATH := $(call my-dir)

#---------------------------------------

# 源代码
HAL_SRC_FILES = $(shell find $(HAL_PATH)/src -name "*.c")

# 头文件
HAL_CFLAGS = -I$(HAL_PATH)/include

# source list
HAL_SRC_LIST = $(call source-add-prefix,$(HAL_PATH),$(HAL_SRC_FILES))
-include $(call source-dependencies,$(HAL_SRC_LIST))


############################################################
# HAL静态库
############################################################
# static compile options
HAL_STATIC_OBJ_LIST = $(call source-static-objects,$(HAL_SRC_LIST))
$(HAL_STATIC_OBJ_LIST):PRIVATE_CFLAGS = $(HAL_CFLAGS)

# build static target
HAL_STATIC_TARGET = $(OUTPUT_HAL_DIR)/lib/libhal.a
$(HAL_STATIC_TARGET): $(HAL_STATIC_OBJ_LIST)
	@$(call build-static-library,$@,$^)


############################################################
# HAL动态库
############################################################
# shared compile options
HAL_SHARED_OBJ_LIST = $(call source-shared-objects,$(HAL_SRC_LIST))
$(HAL_SHARED_OBJ_LIST):PRIVATE_CFLAGS = $(HAL_CFLAGS)
$(HAL_SHARED_OBJ_LIST): PRIVATE_LDFLAGS := $(HAL_LDFLAGS)

# build shared target
HAL_SHARED_TARGET := $(OUTPUT_HAL_DIR)/lib/libhal.so
$(HAL_SHARED_TARGET): $(HAL_SHARED_OBJ_LIST)
	@$(call build-shared-library,$@,$^)


############################################################
# 打包HAL产物
############################################################
HAL_FILES_DIR=$(OUTPUT_HAL_DIR)
hal_files:
	@echo "====== build hal files begin ======="
	@mkdir -p $(HAL_FILES_DIR)/include
	# 复制对外头文件
	@cp -a $(HAL_PATH)/include/* $(HAL_FILES_DIR)/include
	@echo "------ build sdk files end ---------"


#---------------------------------------
