//
//  OCLProgram.m
//  ObjOpenCL
//
//  Created by Zenny Chen on 2016/11/23.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

#import "OCLProgram.h"
#import "OCLKernel.h"

@implementation ZCOCLProgram

@synthesize clStatus, sources, binary, kernels;

- (instancetype)initWithProgram:(cl_program)program sources:(NSArray*)sourceArray binary:(NSData*)binaryData kernels:(NSArray*)kernelArray
{
    self = [super init];
    
    mProgram = program;
    sources = [sourceArray retain];
    binary = [binaryData retain];
    kernels = [kernelArray retain];
    
    clStatus = CL_SUCCESS;
    
    return self;
}

- (void)dealloc
{
    [sources release];
    [binary release];
    [kernels release];
    
    clReleaseProgram(mProgram);
    
    [super dealloc];
}

- (id<OCLKernel>)newKernel:(NSString*)kernelName
{
    if(kernelName == nil || kernelName.length == 0)
        return nil;
    
    cl_int status = CL_SUCCESS;
    cl_kernel kernel = clCreateKernel(mProgram, kernelName.UTF8String, &status);
    if(status != CL_SUCCESS)
    {
        clStatus = status;
        return nil;
    }
    
    return [[ZCOCLKernel alloc] initWithKernel:kernel];
}

@end

