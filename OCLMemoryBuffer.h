//
//  OCLMemoryBuffer.h
//  ObjOpenCL
//
//  Created by Zenny Chen on 2016/11/23.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

#pragma once

#import "obj_opencl.h"

@interface ZCOCLMemoryBuffer : NSObject<OCLMemoryBuffer>
{
@private
    
    cl_mem mMemoryBuffer;
    size_t size;
    void *hostPtr;
}

- (instancetype)initWithMemoryObject:(cl_mem)memObj size:(size_t)nBytes withHostPtr:(void*)host_ptr;

- (cl_mem)memObj;

@end

