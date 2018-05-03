LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)
LOCAL_SRC_FILES:= \
	./cfgparse.c \
    ./sig_analyzer.c
LOCAL_MODULE:= sig_analyzer_local
LOCAL_MODULE_TAGS := optional
LOCAL_STATIC_LIBRARIES := libcjson
LOCAL_C_INCLUDES := vendor/libratone/sdk/cJson/include
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_SRC_FILES:= \
	./cfgparse.c \
    ./sig_generator.c
LOCAL_MODULE:= sig_generator_local
LOCAL_MODULE_TAGS := optional
LOCAL_STATIC_LIBRARIES := libcjson
LOCAL_C_INCLUDES := vendor/libratone/sdk/cJson/include
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_SRC_FILES:= \
	./cfgparse.c \
    ./dut_para.c
LOCAL_MODULE:= dut_paras
LOCAL_MODULE_TAGS := optional
LOCAL_STATIC_LIBRARIES := libcjson
LOCAL_C_INCLUDES := vendor/libratone/sdk/cJson/include
include $(BUILD_EXECUTABLE)


