APP_NAME ?= app_huatuo

# 当前文件所在目录
APPS_PATH := $(call my-dir)

include $(APPS_PATH)/$(APP_NAME)/local.mk
