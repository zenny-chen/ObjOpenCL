//
//  OCLContext.h
//  ObjOpenCL
//
//  Created by Zenny Chen on 2016/11/23.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

#pragma once

#import "obj_opencl.h"

@class ZCOCLDevice;

@interface ZCOCLContext : NSObject<OCLContext>
{
@private
    
    cl_int clStatus;
    cl_context mContext;
    ZCOCLDevice *mAssocDevice;
}

- (instancetype)initWithContext:(cl_context)context device:(ZCOCLDevice*)device;
- (cl_context)context;
- (cl_device_id)device;

@end

