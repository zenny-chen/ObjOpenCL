//
//  OCLMemoryBuffer.m
//  ObjOpenCL
//
//  Created by Zenny Chen on 2016/11/23.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

#import "OCLMemoryBuffer.h"

@implementation ZCOCLMemoryBuffer

@synthesize hostPtr, size;

- (instancetype)initWithMemoryObject:(cl_mem)memObj size:(size_t)nBytes withHostPtr:(void*)host_ptr
{
    self = [super init];
    
    mMemoryBuffer = memObj;
    size = nBytes;
    hostPtr = host_ptr;
    
    return self;
}

- (void)dealloc
{
    clReleaseMemObject(mMemoryBuffer);
    
    [super dealloc];
}

- (cl_mem)memObj
{
    return mMemoryBuffer;
}

@end

