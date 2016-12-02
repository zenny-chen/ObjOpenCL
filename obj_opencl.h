//
//  obj_opencl.h
//  ObjOpenCL
//
//  Created by Zenny Chen on 2016/11/22.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

#ifndef obj_opencl_h
#define obj_opencl_h

#import <Foundation/Foundation.h>
#include <stdint.h>

#ifdef __APPLE__

#include <OpenCL/OpenCl.h>

#else

#include <CL/opencl.h>

#endif

/** Used for work item dimension and work group dimension */
struct OCLDimensionType
{
    size_t x, y, z, w;
};

#ifndef __clang__

#define _Nonnull
#define _Nullable
#define OBJ_OPENCL_WITHTYPE(type)
#define instancetype    id

#else

#define OBJ_OPENCL_WITHTYPE(type)      <type>

#endif


extern NSString* _Nonnull const OCL_COMMAND_QUEUE_PROPERTY_KEY_PROPERTIES;
extern NSString* _Nonnull const OCL_COMMAND_QUEUE_PROPERTY_KEY_SIZE;
extern NSString* _Nonnull const OCL_CONTEXT_PROPERTY_KEY_INTEROP_USER_SYNC;


#pragma mark - OCLMemoryBuffer

@protocol OCLMemoryBuffer <NSObject>

@property (nonatomic, readonly) size_t size;
@property (nonatomic, readonly) void* _Nullable hostPtr;

@end


#pragma mark - OCLKernel

@protocol OCLKernel <NSObject>

@property (nonatomic, readonly) int clStatus;

- (BOOL)setKernelArgWithMemBuffer:(id<OCLMemoryBuffer> _Nonnull)memObj atIndex:(unsigned)index;

- (BOOL)setKernelArgWithObj:(const void* _Nonnull)pObj objSize:(size_t)size atIndex:(unsigned)index;

@end


#pragma mark - OCLProgram

@protocol OCLProgram <NSObject>

@property (nonatomic, readonly) int clStatus;
@property (nonatomic, readonly) NSArray OBJ_OPENCL_WITHTYPE(NSString*) * _Nullable sources;
@property (nonatomic, readonly) NSData* _Nullable binary;
@property (nonatomic, readonly) NSArray OBJ_OPENCL_WITHTYPE(NSString*) * _Nonnull kernels;

- (id<OCLKernel> _Nullable)newKernel:(NSString* _Nonnull)kernelName;

@end


#pragma mark - OCLEvent

@protocol OCLEvent <NSObject>

@property (nonatomic, readonly) int status;
@property (nonatomic, readonly) cl_event _Nonnull event;

@end


#pragma mark - OCLCommandQueue

@protocol OCLCommandQueue <NSObject>

@property (nonatomic, readonly) int clStatus;

- (void)finish;

- (void)flush;

- (BOOL)enqueueWriteBuffer:(id<OCLMemoryBuffer> _Nonnull)memObj offset:(size_t)offset size:(size_t)size hostPtr:(const void* _Nonnull)ptr waitingEvents:(NSArray OBJ_OPENCL_WITHTYPE(id<OCLEvent>) * _Nullable)events;

- (id<OCLEvent> _Nullable)newEventAndEnqueueWriteBuffer:(id<OCLMemoryBuffer> _Nonnull)memObj offset:(size_t)offset size:(size_t)size hostPtr:(const void* _Nonnull)ptr waitingEvents:(NSArray OBJ_OPENCL_WITHTYPE(id<OCLEvent>) * _Nullable)events;

- (BOOL)enqueueReadBuffer:(id<OCLMemoryBuffer> _Nonnull)memObj offset:(size_t)offset size:(size_t)size hostPtr:(void* _Nonnull)ptr waitingEvents:(NSArray OBJ_OPENCL_WITHTYPE(id<OCLEvent>) * _Nullable)events;

- (id<OCLEvent> _Nullable)newEventAndEnqueueReadBuffer:(id<OCLMemoryBuffer> _Nonnull)memObj offset:(size_t)offset size:(size_t)size hostPtr:(void* _Nonnull)ptr waitingEvents:(NSArray OBJ_OPENCL_WITHTYPE(id<OCLEvent>) * _Nullable)events;

- (BOOL)enqueueExecuteKernel:(id<OCLKernel> _Nonnull)kernel workDimensions:(unsigned)work_dim global_work_offset:(const size_t[_Nullable])offsets global_work_size:(const size_t[_Nonnull])gsizes local_work_size:(const size_t[_Nullable])lsizes waitingEvents:(NSArray OBJ_OPENCL_WITHTYPE(id<OCLEvent>) * _Nullable)events;

- (id<OCLEvent> _Nullable)newEventAndEnqueueExecuteKernel:(id<OCLKernel> _Nonnull)kernel workDimensions:(unsigned)work_dim global_work_offset:(const size_t[_Nullable])offsets global_work_size:(const size_t[_Nonnull])gsizes local_work_size:(const size_t[_Nullable])lsizes waitingEvents:(NSArray OBJ_OPENCL_WITHTYPE(id<OCLEvent>) * _Nullable)events;

@end


#pragma mark - OCLContext

@protocol OCLContext <NSObject>

@property (nonatomic, readonly) int clStatus;

- (id<OCLCommandQueue> _Nullable)newCommandQueue:(NSDictionary* _Nullable)properties;
- (id<OCLProgram> _Nullable)newProgram:(NSArray OBJ_OPENCL_WITHTYPE(NSString*) * _Nonnull)sourcePaths buildOptions:(const char* _Nullable)options needToFetchSources:(BOOL)need;
- (id<OCLMemoryBuffer> _Nullable)newMemoryBuffer:(size_t)flags size:(size_t)size hostPtr:(void* _Nullable)host_ptr;
- (BOOL)waitForEvents:(NSArray OBJ_OPENCL_WITHTYPE(id<OCLEvent>) * _Nonnull)events;

@end


#pragma mark - OCLDevice

@protocol OCLDevice <NSObject>

@property (nonatomic, readonly) int clStatus;
@property (nonatomic, readonly) size_t type;
@property (nonatomic, readonly) double version;
@property (nonatomic, readonly) NSString* _Nonnull name;
@property (nonatomic, readonly) NSString* _Nonnull vendor;
@property (nonatomic, readonly) NSString* _Nonnull profile;
@property (nonatomic, readonly) uint32_t vendorID;
@property (nonatomic, readonly) uint32_t maxComputeUnits;
@property (nonatomic, readonly) uint32_t maxWorkItemDimensions;
@property (nonatomic, readonly) struct OCLDimensionType maxWorkItemSizes;
@property (nonatomic, readonly) size_t maxWorkGroupSize;

- (id<OCLContext> _Nullable)newContext:(NSDictionary* _Nullable)properties;

@end


@protocol OCLPlatformInfo <NSObject>

@property (nonatomic, readonly) NSString* _Nonnull name;
@property (nonatomic, readonly) NSString* _Nonnull version;
@property (nonatomic, readonly) NSString* _Nonnull vendor;
@property (nonatomic, readonly) NSString* _Nonnull profile;
@property (nonatomic, readonly) int clStatus;

- (NSArray OBJ_OPENCL_WITHTYPE(NSString*) * _Nullable)newQueryExtensions;

- (NSArray OBJ_OPENCL_WITHTYPE(id<OCLDevice>) * _Nonnull)newDevices;

@end


extern NSArray OBJ_OPENCL_WITHTYPE(id<OCLPlatformInfo>) * _Nullable OCLCreateCurrentPlatformInfos(cl_int* _Nullable pStatus);


#endif /* obj_opencl_h */

