//
//  OCLCommandQueue.h
//  ObjOpenCL
//
//  Created by Zenny Chen on 2016/11/23.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

#pragma once

#import "obj_opencl.h"

@class ZCOCLContext;

@interface ZCOCLCommandQueue : NSObject<OCLCommandQueue>
{
@private
    
    cl_int clStatus;
    cl_command_queue mCommandQueue;
    
    ZCOCLContext *mAssocContext;
}

- (instancetype)initWithCommandQueue:(cl_command_queue)commandQueue context:(ZCOCLContext*)context;

@end


