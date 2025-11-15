ARCHS = arm64
TARGET = iphone:clang:26.0
SYSROOT = $(THEOS)/sdks/iPhoneOS26.0.sdk
THEOS_PACKAGE_SCHEME = rootless
PACKAGE_VERSION = 1.0.3

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SoraX
$(TWEAK_NAME)_FILES = $(wildcard *.x *.m)
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
