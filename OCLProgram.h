//
//  OCLProgram.h
//  ObjOpenCL
//
//  Created by Zenny Chen on 2016/11/23.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

#pragma once

#import "obj_opencl.h"

@interface ZCOCLProgram : NSObject<OCLProgram>
{
@private
    
    cl_program mProgram;
    cl_int clStatus;

    NSArray *sources;
    NSData* binary;
    NSArray *kernels;
}

- (instancetype)initWithProgram:(cl_program)program sources:(NSArray*)sourceArray binary:(NSData*)binaryData kernels:(NSArray*)kernelArray;

@end

