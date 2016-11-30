//
//  main.m
//  ObjOpenCL
//
//  Created by Zenny Chen on 2016/11/22.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

#import "ObjOpenCL/obj_opencl.h"

#define obj     __auto_type

#define OPENCL_KERNEL_PATH  @"/Users/zennychen/Downloads/test.cl"

static void CL_CALLBACK MyEventHandler(cl_event event, cl_int status, void *data)
{
    puts("The event is completed!");
}

int main(int argc, const char * argv[])
{
    obj pool = [NSAutoreleasePool new];

    id<OCLContext> context = nil;
    id<OCLProgram> program = nil;
    id<OCLCommandQueue> commandQueue = nil;
    id<OCLMemoryBuffer> memSrc1 = nil;
    id<OCLMemoryBuffer> memSrc2 = nil;
    id<OCLMemoryBuffer> memDst = nil;
    id<OCLEvent> event = nil;
    id<OCLKernel> kernel = nil;

    int *pHostBuffer = NULL;
    float *pDeviceBuffer = NULL;

    obj platformInfoList = OCLCreateCurrentPlatformsInfo();
    if(platformInfoList.platforms.count == 0)
    {
        NSLog(@"Your current environment does not support OpenCL!");
        goto CLEAR_RESOURCES;
    }
    
    obj platform = [platformInfoList.platforms objectAtIndex:0];
    
    obj devices = [platform getDevices];
    
    if(devices.count == 0)
    {
        NSLog(@"No OpenCL devices!");
        goto CLEAR_RESOURCES;
    }

    id<OCLDevice> currDevice = [devices objectAtIndex:0];
    
    for(id<OCLDevice> device in devices)
    {
        if(device.type == CL_DEVICE_TYPE_GPU)
        {
            currDevice = device;
            break;
        }
    }
    
    context = [currDevice newContext:nil];
    if(context == nil)
    {
        NSLog(@"Context cannot be created! Error code: %d", currDevice.clStatus);
        goto CLEAR_RESOURCES;
    }
    
    const size_t maxWorkGroupSize = currDevice.maxWorkGroupSize;
    const cl_uint maxComputeUnits = currDevice.maxComputeUnits;
    NSString *options = [NSString stringWithFormat:@"-D GROUP_NUMBER_OF_WORKITEMS=%zu -D MAX_COMPUTE_UNITS=%u", maxWorkGroupSize, maxComputeUnits];
    
    program = [context newProgram:[NSArray arrayWithObject:OPENCL_KERNEL_PATH] buildOptions:options.UTF8String needToFetchSources:YES];
    if(program == nil)
    {
        NSLog(@"Failed to build the program!");
        goto CLEAR_RESOURCES;
    }

    commandQueue = [context newCommandQueue:nil];
    if(commandQueue == nil)
    {
        NSLog(@"Failed to create command queue! Error code: %d", context.clStatus);
        goto CLEAR_RESOURCES;
    }
    
    const size_t contentLength = sizeof(int) * 16 * 1024 * 1024;
    memSrc1 = [context newMemoryBuffer:CL_MEM_READ_ONLY size:contentLength hostPtr:NULL];
    if(memSrc1 == nil)
    {
        NSLog(@"Failed to create memSrc1 buffer! Error code: %d", context.clStatus);
        goto CLEAR_RESOURCES;
    }

    memSrc2 = [context newMemoryBuffer:CL_MEM_READ_WRITE size:contentLength hostPtr:NULL];
    if(memSrc2 == nil)
    {
        NSLog(@"Failed to create memSrc2 buffer! Error code: %d", context.clStatus);
        goto CLEAR_RESOURCES;
    }
    
    pHostBuffer = malloc(contentLength);
    for(int i = 0; i < contentLength / sizeof(int); i++)
        pHostBuffer[i] = i + 1;
    
    event = [commandQueue newEventAndEnqueueWriteBuffer:memSrc1 offset:0 size:contentLength hostPtr:pHostBuffer waitingEvents:nil];
    
    clSetEventCallback(event.event, CL_COMPLETE, &MyEventHandler, NULL);
    
    memDst = [context newMemoryBuffer:CL_MEM_READ_WRITE size:16 hostPtr:NULL];
    if(memDst == nil)
    {
        NSLog(@"Failed to create memDst buffer! Error code: %d", context.clStatus);
        goto CLEAR_RESOURCES;
    }
    
    [commandQueue enqueueWriteBuffer:memDst offset:0 size:8 hostPtr:(int[]){0, 0} waitingEvents:[NSArray arrayWithObject:event]];
    
    kernel = [program newKernel:[program.kernels objectAtIndex:0]];
    if(kernel == nil)
    {
        NSLog(@"Failed to create kernel!");
        goto CLEAR_RESOURCES;
    }
    
    [kernel setKernelArgWithMemBuffer:memDst atIndex:0];
    [kernel setKernelArgWithMemBuffer:memSrc1 atIndex:1];
    [kernel setKernelArgWithMemBuffer:memSrc2 atIndex:2];
    
    [event release];
    
    event = [commandQueue newEventAndEnqueueExecuteKernel:kernel workDimensions:1 global_work_offset:NULL global_work_size:(size_t[]){contentLength} local_work_size:(size_t[]){maxWorkGroupSize} waitingEvents:nil];
    
    [context waitForEvents:[NSArray arrayWithObject:event]];
    
    // 准备做校验
    pDeviceBuffer = malloc(contentLength);
    
    // 然后获取相关剩余的元素
    [commandQueue enqueueReadBuffer:memDst offset:0 size:16 hostPtr:pDeviceBuffer waitingEvents:nil];
    
    // 做数据校验
    printf("s0 = %f, s1 = %f, s3 = %f, s4 = %f\n", pDeviceBuffer[0], pDeviceBuffer[1], pDeviceBuffer[2], pDeviceBuffer[3]);

CLEAR_RESOURCES:
    
    free(pHostBuffer);
    free(pDeviceBuffer);
    
    [event release];
    [memSrc1 release];
    [memSrc2 release];
    [memDst release];
    [kernel release];
    [program release];
    [commandQueue release];
    [context release];
    [platformInfoList release];

    [pool drain];
    
    return 0;
}


