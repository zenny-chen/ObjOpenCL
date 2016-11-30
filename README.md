# ObjOpenCL
Using OpenCL with Objective-C API

This project can be built directly on Linux with GCC. Of course, it workds better with Clang, especially Apple LLVM.
ATTENTION: if you use Clang, please use version 3.8 or above. And if you use Xcode, please use Xcode 8.0 or above.

GNUmakefile lists the compiler options, including paths and library paths. Modify the paths according to your OS environment.

Put the OpenCL kernel source file to the proper directory, and modify the path string in main.m which is defined via a macro.

ObjOpenCL supports both OpenCL 1.2 and OpenCL 2.0.
