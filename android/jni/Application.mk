NDK_TOOLCHAIN_VERSION := 4.8
APP_PLATFORM := android-9
APP_STL := c++_shared
APP_ABI := armeabi armeabi-v7a x86 mips
APP_MODULES := sfml-activity emptyepsilon

APP_CFLAGS += -DVERSION_NUMBER=$(shell date +%Y%m%d)
