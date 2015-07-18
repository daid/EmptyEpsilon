LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := emptyepsilon

LOCAL_SRC_FILES := $(wildcard $(abspath $(LOCAL_PATH)/../../src/**/*.cpp))
LOCAL_SRC_FILES += $(wildcard $(abspath $(LOCAL_PATH)/../../../SeriousProton/src/**/*.cpp))
LOCAL_SRC_FILES += $(wildcard $(abspath $(LOCAL_PATH)/../../../SeriousProton/src/**/*.c))
LOCAL_SRC_FILES += $(wildcard $(abspath $(LOCAL_PATH)/../../src/*.cpp))
LOCAL_SRC_FILES += $(wildcard $(abspath $(LOCAL_PATH)/../../../SeriousProton/src/*.cpp))
LOCAL_SRC_FILES += $(wildcard $(abspath $(LOCAL_PATH)/../../../SeriousProton/src/*.c))

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../src $(LOCAL_PATH)/../../../SeriousProton/src

LOCAL_CPP_FEATURES := rtti

LOCAL_LDLIBS := -lGLESv1_CM

LOCAL_SHARED_LIBRARIES := sfml-system
LOCAL_SHARED_LIBRARIES += sfml-window
LOCAL_SHARED_LIBRARIES += sfml-graphics
LOCAL_SHARED_LIBRARIES += sfml-audio
LOCAL_SHARED_LIBRARIES += sfml-network
LOCAL_WHOLE_STATIC_LIBRARIES := sfml-main

include $(BUILD_SHARED_LIBRARY)

$(call import-module,sfml)
