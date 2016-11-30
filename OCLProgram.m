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

- (instancetype)initWithProgram:(cl_program)program
{
    self = [super init];
    
    mProgram = program;
    clStatus = CL_SUCCESS;
    
    return self;
}

- (void)dealloc
{
    [self setSources:nil];
    [self setBinary:nil];
    [self setKernels:nil];
    
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

