GNUSTEP_MAKEFILES = /usr/share/GNUstep/Makefiles

include $(GNUSTEP_MAKEFILES)/common.make

ADDITIONAL_FLAGS += -std=gnu11 -I/opt/AMDAPPSDK-3.0/include -L/opt/AMDAPPSDK-3.0/lib/x86_64

TOOL_NAME = test
VERSION = 1.0

test_OBJC_FILES = main.m

test_OBJC_FILES += ObjOpenCL/OCLPlatformInfo.m
test_OBJC_FILES += ObjOpenCL/OCLDevice.m
test_OBJC_FILES += ObjOpenCL/OCLProgram.m
test_OBJC_FILES += ObjOpenCL/OCLMemoryBuffer.m
test_OBJC_FILES += ObjOpenCL/OCLEvent.m
test_OBJC_FILES += ObjOpenCL/OCLKernel.m
test_OBJC_FILES += ObjOpenCL/OCLContext.m
test_OBJC_FILES += ObjOpenCL/OCLCommandQueue.m

test_OBJC_LIBS += libOpenCL.so

include $(GNUSTEP_MAKEFILES)/tool.make

