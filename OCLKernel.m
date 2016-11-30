//
//  OCLKernel.m
//  ObjOpenCL
//
//  Created by Zenny Chen on 2016/11/25.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

#import "OCLKernel.h"
#import "OCLMemoryBuffer.h"

@implementation ZCOCLKernel

@synthesize clStatus;

- (instancetype)initWithKernel:(cl_kernel)kernel
{
    self = [super init];
    
    mKernel = kernel;
    clStatus = CL_SUCCESS;
    
    return self;
}

- (void)dealloc
{
    clReleaseKernel(mKernel);
    
    [super dealloc];
}

- (BOOL)setKernelArgWithMemBuffer:(id<OCLMemoryBuffer>)memObj atIndex:(unsigned)index
{
    if(memObj == nil)
        return NO;
    
    ZCOCLMemoryBuffer *memBuffer = (ZCOCLMemoryBuffer*)memObj;
    void *pValue = memBuffer.memObj;
    
    cl_int status = clSetKernelArg(mKernel, index, sizeof(memBuffer.memObj), &pValue);
    if(status != CL_SUCCESS)
    {
        clStatus = status;
        return NO;
    }
    
    return YES;
}

- (BOOL)setKernelArgWithObj:(const void*)pObj objSize:(size_t)size atIndex:(unsigned)index
{
    if(pObj == NULL)
        return NO;
    
    cl_int status = clSetKernelArg(mKernel, index, size, pObj);
    if(status != CL_SUCCESS)
    {
        clStatus = status;
        return NO;
    }
    
    return YES;
}

- (cl_kernel)kernel
{
    return mKernel;
}

@end

