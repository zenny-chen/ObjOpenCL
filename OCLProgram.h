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

@property (nonatomic, retain) NSArray *sources;
@property (nonatomic, retain) NSData* binary;
@property (nonatomic, retain) NSArray *kernels;

- (instancetype)initWithProgram:(cl_program)program;

@end

