//
//  OCLPlatformInfo.m
//  ObjOpenCL
//
//  Created by Zenny Chen on 2016/11/22.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

#import "OCLPlatformInfo.h"
#import "OCLDevice.h"


@implementation ZCOCLPlatformInfo

@synthesize name, version, vendor, profile, clStatus;

NSArray* OCLCreateCurrentPlatformInfos(cl_int *pStatus)
{
    NSMutableArray *platforms = [[NSMutableArray alloc] initWithCapacity:16];
    cl_int status = CL_SUCCESS;
    
    do
    {
        cl_uint nPlatforms = 0;
        status = clGetPlatformIDs(0, NULL, &nPlatforms);
        if(status != CL_SUCCESS)
            break;
        
        cl_platform_id platformList[nPlatforms];
        status = clGetPlatformIDs(nPlatforms, platformList, NULL);
        
        if(status != CL_SUCCESS)
            break;
        
        // Fetch platform names
        for(cl_uint i = 0; i < nPlatforms; i++)
        {
            ZCOCLPlatformInfo *platformInfo = [[ZCOCLPlatformInfo alloc] initWithPlatformID:platformList[i]];
            [platforms addObject:platformInfo];
            [platformInfo release];
        }
    }
    while(NO);
    
    if(status != CL_SUCCESS)
    {
        [platforms release];
        platforms = nil;
    }
    
    if(pStatus != NULL)
        *pStatus = status;
    
    return platforms;
}

- (instancetype)initWithPlatformID:(cl_platform_id)platform
{
    self = [super init];
    
    mPlatform = platform;
    clStatus = CL_SUCCESS;
    
    char strBuf[256];
    
    clGetPlatformInfo(platform, CL_PLATFORM_NAME, 256, strBuf, NULL);
    NSString *str = [[NSString alloc] initWithUTF8String:strBuf];
    name = str;
    
    clGetPlatformInfo(platform, CL_PLATFORM_VERSION, 256, strBuf, NULL);
    str = [[NSString alloc] initWithUTF8String:strBuf];
    version = str;
    
    clGetPlatformInfo(platform, CL_PLATFORM_VENDOR, 256, strBuf, NULL);
    str = [[NSString alloc] initWithUTF8String:strBuf];
    vendor = str;
    
    clGetPlatformInfo(platform, CL_PLATFORM_PROFILE, 256, strBuf, NULL);
    str = [[NSString alloc] initWithUTF8String:strBuf];
    profile = str;
    
    return self;
}

- (void)dealloc
{
    [name release];
    [version release];
    [vendor release];
    [profile release];
    
    [super dealloc];
}

- (NSArray*)newQueryExtensions
{
    size_t extStrLen = 0;
    cl_int status = clGetPlatformInfo(mPlatform, CL_PLATFORM_EXTENSIONS, 0, NULL, &extStrLen);
    if(status != CL_SUCCESS)
    {
        clStatus = status;
        return nil;
    }
    
    char *extStrBuf = malloc(extStrLen);
    
    status = clGetPlatformInfo(mPlatform, CL_PLATFORM_EXTENSIONS, extStrLen, extStrBuf, NULL);
    if(status != CL_SUCCESS)
    {
        clStatus = status;
        free(extStrBuf);
        return nil;
    }
    
    NSMutableArray *extensions = [[NSMutableArray alloc] initWithCapacity:128];
    
    char tmpBuf[256];
    
    size_t index = 0;
    int tmpIndex = 0;
    while(index < extStrLen)
    {
        if(extStrBuf[index] != ' ')
            tmpBuf[tmpIndex++] = extStrBuf[index];
        else
        {
            tmpBuf[tmpIndex] = '\0';
            
            NSString *str = [[NSString alloc] initWithUTF8String:tmpBuf];
            [extensions addObject:str];
            [str release];
            
            tmpIndex = 0;
        }
        
        index++;
    }
    if(tmpIndex > 0)
    {
        tmpBuf[tmpIndex] = '\0';
        
        NSString *str = [[NSString alloc] initWithUTF8String:tmpBuf];
        [extensions addObject:str];
        [str release];
    }
    
    free(extStrBuf);
    
    return extensions;
}

- (NSArray*)newDevices
{
    NSMutableArray *devices = [[NSMutableArray alloc] initWithCapacity:128];
    
    do
    {
        cl_uint nDevices = 0;
        cl_int status = clGetDeviceIDs(mPlatform, CL_DEVICE_TYPE_ALL, 0, NULL, &nDevices);
        
        if(status != CL_SUCCESS)
        {
            clStatus = status;
            break;
        }
        
        cl_device_id deviceList[nDevices];
        
        status = clGetDeviceIDs(mPlatform, CL_DEVICE_TYPE_ALL, nDevices, deviceList, NULL);
        if(status != CL_SUCCESS)
        {
            clStatus = status;
            break;
        }
        
        for(cl_uint i = 0; i < nDevices; i++)
        {
            ZCOCLDevice *device = [[ZCOCLDevice alloc] initWithDeviceID:deviceList[i] platform:self];
            [devices addObject:device];
            [device release];
        }
    }
    while(NO);
    
    return devices;
}

- (cl_platform_id)platform
{
    return mPlatform;
}

@end

