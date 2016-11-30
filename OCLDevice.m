//
//  OCLDevice.m
//  ObjOpenCL
//
//  Created by Zenny Chen on 2016/11/22.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

#import "OCLPlatformInfo.h"
#import "OCLDevice.h"
#import "OCLContext.h"

NSString* const OCL_COMMAND_QUEUE_PROPERTY_KEY_PROPERTIES = @"CL_QUEUE_PROPERTIES";
NSString* const OCL_COMMAND_QUEUE_PROPERTY_KEY_SIZE = @"CL_QUEUE_SIZE";
NSString* const OCL_CONTEXT_PROPERTY_KEY_INTEROP_USER_SYNC = @"CL_CONTEXT_INTEROP_USER_SYNC";

@implementation ZCOCLDevice

@synthesize clStatus, name, version, vendor, profile, type, vendorID,
            maxComputeUnits, maxWorkItemDimensions, maxWorkItemSizes, maxWorkGroupSize;

- (instancetype)initWithDeviceID:(cl_device_id)deviceID platform:(ZCOCLPlatformInfo*)platform
{
    self = [super init];
    
    mDevice = deviceID;
    mAssocPlatform = platform;
    clStatus = CL_SUCCESS;
    
    char strBuf[256];
    
    clGetDeviceInfo(deviceID, CL_DEVICE_NAME, 256, strBuf, NULL);
    name = [[NSString stringWithUTF8String:strBuf] retain];
    
    clGetDeviceInfo(deviceID, CL_DEVICE_VERSION, 256, strBuf, NULL);
    
    int index;
    for(index = 0; strBuf[index] < '0' || strBuf[index] > '9'; index++);
    version = atof(&strBuf[index]);
    
    clGetDeviceInfo(deviceID, CL_DEVICE_VENDOR, 256, strBuf, NULL);
    vendor = [[NSString stringWithUTF8String:strBuf] retain];
    
    clGetDeviceInfo(deviceID, CL_DEVICE_PROFILE, 256, strBuf, NULL);
    profile = [[NSString stringWithUTF8String:strBuf] retain];
    
    cl_device_type deviceType;
    clGetDeviceInfo(deviceID, CL_DEVICE_TYPE, sizeof(deviceType), &deviceType, NULL);
    type = deviceType;
    
    clGetDeviceInfo(deviceID, CL_DEVICE_VENDOR_ID, sizeof(vendorID), &vendorID, NULL);
    
    clGetDeviceInfo(deviceID, CL_DEVICE_MAX_COMPUTE_UNITS, sizeof(maxComputeUnits), &maxComputeUnits, NULL);
    
    clGetDeviceInfo(deviceID, CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS, sizeof(maxWorkItemDimensions), &maxWorkItemDimensions, NULL);
    
    clGetDeviceInfo(deviceID, CL_DEVICE_MAX_WORK_ITEM_SIZES, sizeof(maxWorkItemSizes), &maxWorkItemSizes, NULL);
    
    clGetDeviceInfo(deviceID, CL_DEVICE_MAX_WORK_GROUP_SIZE, sizeof(maxWorkGroupSize), &maxWorkGroupSize, NULL);
    
    return self;
}

- (void)dealloc
{
    [name release];
    [vendor release];
    [profile release];
    
    [super dealloc];
}

- (id<OCLContext>)newContext:(NSDictionary*)properties
{
    cl_context_properties props[] = { CL_CONTEXT_PLATFORM, (cl_context_properties)[mAssocPlatform platform], 0, 0, 0 };
    
    if(properties != nil)
    {
        if(version >= 2.0)
        {
            NSNumber *num = [properties objectForKey:OCL_CONTEXT_PROPERTY_KEY_INTEROP_USER_SYNC];
            if(num != NULL)
            {
                props[2] = CL_CONTEXT_INTEROP_USER_SYNC;
                props[3] = num.boolValue;
            }
        }
    }
    
    cl_context context = clCreateContext(props, 1, &mDevice, NULL, NULL, &clStatus);
    
    if(context == NULL)
        return nil;
    
    return [[ZCOCLContext alloc] initWithContext:context device:self];
}

- (cl_device_id)device
{
    return mDevice;
}

@end

