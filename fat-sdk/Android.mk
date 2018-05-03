LOCAL_PATH := $(call my-dir)
##########################shared lib##################################
include $(CLEAR_VARS)

LOCAL_MODULES_NAME := 

define addprefixsuffix_so_list
$(addprefix lib/, $(addsuffix .so, $(1)))
endef

LOCAL_PREBUILT_LIBS := $(call addprefixsuffix_so_list,$(LOCAL_MODULES_NAME))
ALL_DEFAULT_INSTALLED_MODULES += $(LOCAL_MODULES_NAME)
LOCAL_MODULE_TAGS := optional
include $(BUILD_MULTI_PREBUILT)


##########################executable##################################
include $(CLEAR_VARS)

LOCAL_MODULES_NAME := sig_generator sig_analyzer dut_paras

define addprefixsuffix_exe_list
$(addprefix bin/, $(1))
endef

LOCAL_PREBUILT_EXECUTABLES := $(call addprefixsuffix_exe_list,$(LOCAL_MODULES_NAME))

LOCAL_MODULE_TAGS := optional
ALL_DEFAULT_INSTALLED_MODULES += $(LOCAL_MODULES_NAME)
include $(BUILD_MULTI_PREBUILT)

##########################static lib##################################
include $(CLEAR_VARS)

LOCAL_MODULES_NAME := 

define addprefixsuffix_a_list
$(addprefix lib/, $(addsuffix .a, $(1)))
endef

LOCAL_PREBUILT_LIBS := $(call addprefixsuffix_a_list,$(LOCAL_MODULES_NAME))
ALL_DEFAULT_INSTALLED_MODULES += $(LOCAL_MODULES_NAME)
LOCAL_MODULE_TAGS := optional
include $(BUILD_MULTI_PREBUILT)

