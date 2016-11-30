//
//  OCLKernel.h
//  ObjOpenCL
//
//  Created by Zenny Chen on 2016/11/25.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

#pragma once

#import "obj_opencl.h"

@interface ZCOCLKernel : NSObject<OCLKernel>
{
@private
    
    cl_int clStatus;
    cl_kernel mKernel;
}

- (instancetype)initWithKernel:(cl_kernel)kernel;
- (cl_kernel)kernel;

@end

