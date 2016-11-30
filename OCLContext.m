//
//  OCLContext.m
//  ObjOpenCL
//
//  Created by Zenny Chen on 2016/11/23.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

#import "OCLContext.h"
#import "OCLDevice.h"
#import "OCLCommandQueue.h"
#import "OCLProgram.h"
#import "OCLMemoryBuffer.h"
#import "OCLEvent.h"

@implementation ZCOCLContext

@synthesize clStatus;

- (instancetype)initWithContext:(cl_context)context device:(ZCOCLDevice*)device
{
    self = [super init];
    
    mContext = context;
    mAssocDevice = device;
    clStatus = CL_SUCCESS;
    
    return self;
}

- (void)dealloc
{
    clReleaseContext(mContext);
    
    [super dealloc];
}

- (id<OCLCommandQueue>)newCommandQueue:(NSDictionary*)properties
{
#ifdef CL_VERSION_2_0
     
    cl_queue_properties props[] = { CL_QUEUE_PROPERTIES, 0, CL_QUEUE_SIZE, CL_DEVICE_QUEUE_ON_DEVICE_PREFERRED_SIZE, 0 };
    cl_command_queue commandQueue = clCreateCommandQueueWithProperties(mContext, mAssocDevice.device, props, &clStatus);
     
#else

    cl_command_queue commandQueue = clCreateCommandQueue(mContext, mAssocDevice.device, 0, &clStatus);
    
#endif
    
    if(commandQueue == NULL)
        return nil;
    
    return [[ZCOCLCommandQueue alloc] initWithCommandQueue:commandQueue context:self];
}

- (id<OCLProgram>)newProgram:(NSArray*)sourcePaths buildOptions:(const char*)options needToFetchSources:(BOOL)need
{
    if(sourcePaths.count == 0)
    {
        NSLog(@"No source files to build!");
        return nil;
    }
    
    const NSUInteger count = sourcePaths.count;
    
    char* sources[count];
    size_t sourceLengths[count];
    
    BOOL isFailed = NO;
    int index = 0;
    for(NSString *path in sourcePaths)
    {
        FILE *fp = fopen(path.UTF8String, "r");
        if(fp == NULL)
        {
            NSLog(@"source file: %@ cannot be opened!", path);
            isFailed = YES;
            break;
        }
        
        fseek(fp, 0, SEEK_END);
        long fileLength = ftell(fp);
        fseek(fp, 0, SEEK_SET);
        sources[index] = malloc(fileLength + 1);
        fread(sources[index], 1, fileLength, fp);
        fclose(fp);
        
        sources[index][fileLength] = '\0';
        sourceLengths[index] = fileLength;
        
        index++;
    }
    
    if(isFailed)
    {
        for(int i = 0; i < index; i++)
        {
            if(sources[i] == NULL)
                break;
            
            free(sources[i]);
        }
        
        return nil;
    }
    
    cl_program program = NULL;
    
    do
    {
        program = clCreateProgramWithSource(mContext, (cl_uint)count, (const char**)sources, sourceLengths, &clStatus);
        if(program == NULL)
            break;
        
        cl_device_id device = mAssocDevice.device;
        cl_int status = clBuildProgram(program, 1, &device, options, NULL, NULL);
        if(status != CL_SUCCESS)
        {
            size_t logLength = 0;
            clGetProgramBuildInfo(program, device, CL_PROGRAM_BUILD_LOG, 0, NULL, &logLength);
            char *logBuffer = malloc(logLength);
            clGetProgramBuildInfo(program, device, CL_PROGRAM_BUILD_LOG, logLength, logBuffer, NULL);
            NSLog(@"Build error: %s\n", logBuffer);
            free(logBuffer);
            
            clStatus = status;
            clReleaseProgram(program);
            program = NULL;
        }
    }
    while(NO);
    
    ZCOCLProgram *oclProgram = nil;
    
    if(program != NULL)
    {
        oclProgram = [[ZCOCLProgram alloc] initWithProgram:program];
        
        if(need)
        {
            NSMutableArray *sourceArray = [NSMutableArray arrayWithCapacity:count];
            for(int i = 0; i < count; i++)
                [sourceArray addObject:[NSString stringWithUTF8String:sources[i]]];
            
            [oclProgram setSources:sourceArray];
            
            size_t binaryLength = 0;
            clGetProgramInfo(program, CL_PROGRAM_BINARY_SIZES, sizeof(binaryLength), &binaryLength, NULL);
            uint8_t *binaryBuf = malloc(binaryLength);
            clGetProgramInfo(program, CL_PROGRAM_BINARIES, sizeof(binaryBuf), &binaryBuf, NULL);
            
            NSData *binaryData = [NSData dataWithBytes:binaryBuf length:binaryLength];
            [oclProgram setBinary:binaryData];
            
            free(binaryBuf);
        }
        
        size_t kernelCount = 0;
        clGetProgramInfo(program, CL_PROGRAM_NUM_KERNELS, sizeof(kernelCount), &kernelCount, NULL);
        
        size_t kernelNameLength = 0;
        clGetProgramInfo(program, CL_PROGRAM_KERNEL_NAMES, 0, NULL, &kernelNameLength);
        char *kernelNamesBuf = malloc(kernelNameLength + 1);
        clGetProgramInfo(program, CL_PROGRAM_KERNEL_NAMES, kernelNameLength, kernelNamesBuf, NULL);
        kernelNamesBuf[kernelNameLength] = '\0';
        
        size_t startIndex = 0;
        size_t endIndex;
        NSMutableArray *kernelArray = [NSMutableArray arrayWithCapacity:kernelCount];
        for(endIndex = 0; endIndex < kernelNameLength; endIndex++)
        {
            char ch = kernelNamesBuf[endIndex];
            if(ch == ';')
            {
                kernelNamesBuf[endIndex] = '\0';
                NSString *str = [NSString stringWithUTF8String:&kernelNamesBuf[startIndex]];
                [kernelArray addObject:str];
                
                startIndex = endIndex + 1;
            }
        }
        if(startIndex != endIndex)
        {
            NSString *str = [NSString stringWithUTF8String:&kernelNamesBuf[startIndex]];
            [kernelArray addObject:str];
        }
        
        [oclProgram setKernels:kernelArray];
        
        free(kernelNamesBuf);
    }
    
    for(int i = 0; i < count; i++)
        free(sources[i]);
    
    return oclProgram;
}

- (id<OCLMemoryBuffer>)newMemoryBuffer:(size_t)flags size:(size_t)size hostPtr:(void* _Nullable)host_ptr
{
    if(size == 0)
        return nil;
    
    cl_mem memObj = clCreateBuffer(mContext, flags, size, host_ptr, &clStatus);
    if(memObj == NULL)
        return nil;
    
    return [[ZCOCLMemoryBuffer alloc] initWithMemoryObject:memObj size:size withHostPtr:host_ptr];
}

- (BOOL)waitForEvents:(NSArray*)events
{
    if(events == nil || events.count == 0)
        return NO;
    
    cl_event eventList[events.count];
    
    int index = 0;
    for(id<OCLEvent> event in events)
        eventList[index++] = event.event;
    
    cl_int status = clWaitForEvents(index, eventList);
    if(status != CL_SUCCESS)
    {
        clStatus = status;
        return NO;
    }
    
    return YES;
}

- (cl_context)context
{
    return mContext;
}

- (cl_device_id)device
{
    return mAssocDevice.device;
}

@end

