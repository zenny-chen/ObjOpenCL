//
//  OCLCommandQueue.m
//  ObjOpenCL
//
//  Created by Zenny Chen on 2016/11/23.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

#import "OCLCommandQueue.h"
#import "OCLContext.h"
#import "OCLMemoryBuffer.h"
#import "OCLEvent.h"
#import "OCLKernel.h"

@implementation ZCOCLCommandQueue

@synthesize clStatus;

- (instancetype)initWithCommandQueue:(cl_command_queue)commandQueue context:(ZCOCLContext*)context
{
    self = [super init];
    
    mCommandQueue = commandQueue;
    mAssocContext = context;
    clStatus = CL_SUCCESS;
    
    return self;
}

- (void)dealloc
{
    clReleaseCommandQueue(mCommandQueue);
    
    [super dealloc];
}

- (void)finish
{
    clFinish(mCommandQueue);
}

- (void)flush
{
    clFlush(mCommandQueue);
}

#pragma mark - enqueueWrite/ReadBuffer

- (BOOL)enqueueWriteBuffer:(id<OCLMemoryBuffer>)memObj offset:(size_t)offset size:(size_t)size hostPtr:(const void*)ptr waitingEvents:(NSArray*)events
{
    if(memObj == NULL || ptr == NULL)
        return NO;
    
    ZCOCLMemoryBuffer *memBuffer = (ZCOCLMemoryBuffer*)memObj;
    
    const cl_uint nEvents = events == nil? 0 : (cl_uint)events.count;
    const cl_event *pEvents = NULL;
    cl_event eventList[nEvents + 1];
    if(nEvents > 0)
    {
        int i = 0;
        for(id<OCLEvent> event in events)
            eventList[i++] = event.event;
        
        pEvents = eventList;
    }
    
    cl_int status = clEnqueueWriteBuffer(mCommandQueue, memBuffer.memObj, CL_TRUE, offset, size, ptr, nEvents, pEvents, NULL);
    if(status != CL_SUCCESS)
    {
        clStatus = status;
        return NO;
    }
    
    return YES;
}

- (id<OCLEvent>)newEventAndEnqueueWriteBuffer:(id<OCLMemoryBuffer>)memObj offset:(size_t)offset size:(size_t)size hostPtr:(const void*)ptr waitingEvents:(NSArray*)events
{
    if(memObj == NULL || ptr == NULL)
        return nil;
    
    ZCOCLMemoryBuffer *memBuffer = (ZCOCLMemoryBuffer*)memObj;
    
    const cl_uint nEvents = events == nil? 0 : (cl_uint)events.count;
    const cl_event *pEvents = NULL;
    cl_event eventList[nEvents + 1];
    if(nEvents > 0)
    {
        int i = 0;
        for(id<OCLEvent> event in events)
            eventList[i++] = event.event;
        
        pEvents = eventList;
    }
    
    cl_event evt;
    
    cl_int status = clEnqueueWriteBuffer(mCommandQueue, memBuffer.memObj, CL_FALSE, offset, size, ptr, nEvents, pEvents, &evt);
    if(status != CL_SUCCESS)
    {
        clStatus = status;
        return nil;
    }
    
    return [[ZCOCLEvent alloc] initWithEvent:evt];
}

- (BOOL)enqueueReadBuffer:(id<OCLMemoryBuffer>)memObj offset:(size_t)offset size:(size_t)size hostPtr:(void*)ptr waitingEvents:(NSArray*)events
{
    if(memObj == NULL || ptr == NULL)
        return NO;
    
    ZCOCLMemoryBuffer *memBuffer = (ZCOCLMemoryBuffer*)memObj;
    
    const cl_uint nEvents = events == nil? 0 : (cl_uint)events.count;
    const cl_event *pEvents = NULL;
    cl_event eventList[nEvents + 1];
    if(nEvents > 0)
    {
        int i = 0;
        for(id<OCLEvent> event in events)
            eventList[i++] = event.event;
        
        pEvents = eventList;
    }
    
    cl_int status = clEnqueueReadBuffer(mCommandQueue, memBuffer.memObj, CL_TRUE, offset, size, ptr, nEvents, pEvents, NULL);
    if(status != CL_SUCCESS)
    {
        clStatus = status;
        return NO;
    }
    
    return YES;
}

- (id<OCLEvent>)newEventAndEnqueueReadBuffer:(id<OCLMemoryBuffer>)memObj offset:(size_t)offset size:(size_t)size hostPtr:(void*)ptr waitingEvents:(NSArray*)events
{
    if(memObj == NULL || ptr == NULL)
        return nil;
    
    ZCOCLMemoryBuffer *memBuffer = (ZCOCLMemoryBuffer*)memObj;
    
    const cl_uint nEvents = events == nil? 0 : (cl_uint)events.count;
    const cl_event *pEvents = NULL;
    cl_event eventList[nEvents + 1];
    if(nEvents > 0)
    {
        int i = 0;
        for(id<OCLEvent> event in events)
            eventList[i++] = event.event;
        
        pEvents = eventList;
    }
    
    cl_event evt;
    
    cl_int status = clEnqueueReadBuffer(mCommandQueue, memBuffer.memObj, CL_FALSE, offset, size, ptr, nEvents, pEvents, &evt);
    if(status != CL_SUCCESS)
    {
        clStatus = status;
        return nil;
    }
    
    return [[ZCOCLEvent alloc] initWithEvent:evt];
}

#pragma mark - enqueueExecuteKernel

- (BOOL)enqueueExecuteKernel:(id<OCLKernel>)kernel workDimensions:(unsigned)work_dim global_work_offset:(const size_t[])offsets global_work_size:(const size_t[])gsizes local_work_size:(const size_t[])lsizes waitingEvents:(NSArray*)events
{
    if(kernel == nil || gsizes == NULL)
        return NO;
    
    cl_kernel kn = ((ZCOCLKernel*)kernel).kernel;
    
    const cl_uint nEvents = events == nil? 0 : (cl_uint)events.count;
    const cl_event *pEvents = NULL;
    cl_event eventList[nEvents + 1];
    if(nEvents > 0)
    {
        int i = 0;
        for(id<OCLEvent> event in events)
            eventList[i++] = event.event;
        
        pEvents = eventList;
    }
    
    cl_int status = clEnqueueNDRangeKernel(mCommandQueue, kn, work_dim, offsets, gsizes, lsizes, nEvents, pEvents, NULL);
    if(status != CL_SUCCESS)
    {
        clStatus = status;
        return NO;
    }
    
    return YES;
}

- (id<OCLEvent> _Nullable)newEventAndEnqueueExecuteKernel:(id<OCLKernel> _Nonnull)kernel workDimensions:(unsigned)work_dim global_work_offset:(const size_t[_Nonnull])offsets global_work_size:(const size_t[_Nonnull])gsizes local_work_size:(const size_t[_Nonnull])lsizes waitingEvents:(NSArray* _Nullable)events
{
    if(kernel == nil || gsizes == NULL)
        return nil;
    
    cl_kernel kn = ((ZCOCLKernel*)kernel).kernel;
    
    const cl_uint nEvents = events == nil? 0 : (cl_uint)events.count;
    const cl_event *pEvents = NULL;
    cl_event eventList[nEvents + 1];
    if(nEvents > 0)
    {
        int i = 0;
        for(id<OCLEvent> event in events)
            eventList[i++] = event.event;
        
        pEvents = eventList;
    }
    
    cl_event evt;
    
    cl_int status = clEnqueueNDRangeKernel(mCommandQueue, kn, work_dim, offsets, gsizes, lsizes, nEvents, pEvents, &evt);
    if(status != CL_SUCCESS)
    {
        clStatus = status;
        return nil;
    }
    
    return [[ZCOCLEvent alloc] initWithEvent:evt];
}

@end

