//
//  OCLDevice.h
//  ObjOpenCL
//
//  Created by Zenny Chen on 2016/11/22.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

#pragma once

#import "obj_opencl.h"

@class ZCOCLPlatformInfo;

@interface ZCOCLDevice : NSObject<OCLDevice>
{
@private
    
    cl_int clStatus;
    cl_device_id mDevice;
    ZCOCLPlatformInfo *mAssocPlatform;
    
    NSString *name;
    NSString *vendor;
    NSString *profile;
    cl_uint vendorID;
    cl_uint maxComputeUnits;
    cl_uint maxWorkItemDimensions;
    struct OCLDimensionType maxWorkItemSizes;
    size_t maxWorkGroupSize;

    double version;
    size_t type;
}

- (instancetype)initWithDeviceID:(cl_device_id)deviceID platform:(ZCOCLPlatformInfo*)platform;

- (cl_device_id)device;

@end

