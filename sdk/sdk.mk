# 当前文件所在目录
SDK_PATH := $(call my-dir)

############################################################
# 包含所有SDK组件的头文件目录
############################################################
SDK_FILES_INC := # SDK产物包中需要对外的头文件特殊路径，在组件local.mk中自行配置
SDK_INCLUDE_DIRS := $(shell find $(SDK_PATH) -name include -type d)
SDK_INCLUDE_ALL_SUBDIRS := $(foreach dir,$(SDK_INCLUDE_DIRS),$(shell find $(dir) -type d))
SDK_CFLAGS = $(addprefix -I,$(SDK_INCLUDE_ALL_SUBDIRS))

############################################################
# 编译隔离列表定义
############################################################
COMPONENTS_EXCLUDE_LIST := $(subst ", , $(CONFIG_COMPONENTS_EXCLUDE_LIST)) # 将"引号替换成空格

-include $(shell find sdk -name local.mk)


############################################################
# 生成单个SDK静态库
############################################################
# 生成目标文件列表
STATIC_OBJS_DIR := $(call static-objects-dir)
SDK_STATIC_OBJS_DIRS := $(STATIC_OBJS_DIR)/sdk
SDK_STATIC_TARGET := $(OUTPUT_SDK_DIR)/lib/libsdk.a

# 排除目标文件列表，把某些组件的.o排除在.a之外
SDK_OBJS_EXCLUDE := $(subst ",, $(CONFIG_SDK_OBJS_EXCLUDE))  # 将"引号去掉
SDK_OBJS_EXCLUDE_DIR := $(addprefix $(SDK_STATIC_OBJS_DIRS)/,$(SDK_OBJS_EXCLUDE))
SDK_OBJS_EXCLUDE_A := $(SDK_OBJS_EXCLUDE:%=$(OUTPUT_DIR)/lib/lib%.a)

# 生成命令
sdk_static:
	# 移除不必要的.o
	@rm -rf $(SDK_OBJS_EXCLUDE_DIR)
	@mkdir -p $(SDK_STATIC_OBJS_DIRS)
	@$(call build-static-library-by-dirs,$(SDK_STATIC_TARGET),$(SDK_STATIC_OBJS_DIRS))
	@cp $(SDK_STATIC_TARGET) $(SDK_STATIC_TARGET).stripped
	@$(STRIP) --strip-debug $(SDK_STATIC_TARGET).stripped


############################################################
# 生成单个SDK动态库
############################################################
# 生成目标文件列表
SHARED_OBJS_DIR := $(call shared-objects-dir)
SDK_SHARED_OBJS_DIRS := $(SHARED_OBJS_DIR)/sdk
SDK_SHARED_TARGET := $(OUTPUT_SDK_DIR)/lib/libsdk.so

# 生成命令
sdk_shared:
	@$(call build-shared-library-by-dirs,$(SDK_SHARED_TARGET),$(SDK_SHARED_OBJS_DIRS))
	@cp $(SDK_SHARED_TARGET) $(SDK_SHARED_TARGET).stripped
	@$(STRIP) --strip-debug $(SDK_SHARED_TARGET).stripped


############################################################
# 打包SDK产物
############################################################
SDK_FILES_DIR=$(OUTPUT_SDK_DIR)
sdk_files:
	@echo "====== build sdk files begin ======="
	@mkdir -p $(SDK_FILES_DIR)/include
	# 复制对外头文件
	@for dir in `ls -1 sdk`; do		\
		if [ -d sdk/$${dir}/include ]; then \
			cp -a sdk/$${dir}/include/* $(SDK_FILES_DIR)/include/; fi ;\
	done
	# 复制自定义对外头文件
	@for inc in $(SDK_FILES_INC); do		\
		if [ -e $${inc} ]; then \
			cp -a $${inc} $(SDK_FILES_DIR)/include/; fi ;\
	done
	@echo "------ build sdk files end ---------"

