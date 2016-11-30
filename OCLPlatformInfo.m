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

- (instancetype)initWithPlatformID:(cl_platform_id)platform
{
    self = [super init];
    
    mPlatform = platform;
    clStatus = CL_SUCCESS;
    
    char strBuf[256];
    
    clGetPlatformInfo(platform, CL_PLATFORM_NAME, 256, strBuf, NULL);
    name = [[NSString stringWithUTF8String:strBuf] retain];
    
    clGetPlatformInfo(platform, CL_PLATFORM_VERSION, 256, strBuf, NULL);
    version = [[NSString stringWithUTF8String:strBuf] retain];
    
    clGetPlatformInfo(platform, CL_PLATFORM_VENDOR, 256, strBuf, NULL);
    vendor = [[NSString stringWithUTF8String:strBuf] retain];
    
    clGetPlatformInfo(platform, CL_PLATFORM_PROFILE, 256, strBuf, NULL);
    profile = [[NSString stringWithUTF8String:strBuf] retain];
    
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

- (NSArray*)queryExtensions
{
    NSMutableArray *extensions = [NSMutableArray arrayWithCapacity:128];
    
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
            [extensions addObject:[NSString stringWithUTF8String:tmpBuf]];
            tmpIndex = 0;
        }
        
        index++;
    }
    if(tmpIndex > 0)
    {
        tmpBuf[tmpIndex] = '\0';
        [extensions addObject:[NSString stringWithUTF8String:tmpBuf]];
    }
    
    free(extStrBuf);
    
    return extensions;
}

- (NSArray*)getDevices
{
    NSMutableArray *devices = [NSMutableArray arrayWithCapacity:128];
    
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


@implementation ZCOCLPlatformsInfoList

@synthesize platforms, clStatus;

- (instancetype)init
{
    self = [super init];
    
    platforms = [[NSMutableArray alloc] initWithCapacity:16];
    clStatus = CL_SUCCESS;
    
    do
    {
        cl_uint nPlatforms = 0;
        cl_int status = clGetPlatformIDs(0, NULL, &nPlatforms);
        if(status != CL_SUCCESS)
        {
            clStatus = status;
            break;
        }
        
        cl_platform_id platformList[nPlatforms];
        status = clGetPlatformIDs(nPlatforms, platformList, NULL);

        if(status != CL_SUCCESS)
        {
            clStatus = status;
            break;
        }
        
        // Fetch platform names
        for(cl_uint i = 0; i < nPlatforms; i++)
        {
            ZCOCLPlatformInfo *platformInfo = [[ZCOCLPlatformInfo alloc] initWithPlatformID:platformList[i]];
            [platforms addObject:platformInfo];
            [platformInfo release];
        }
    }
    while(NO);
    
    return self;
}

- (void)dealloc
{
    [platforms removeAllObjects];
    [platforms release];
    
    [super dealloc];
}

id<OCLPlatformsInfoList> OCLCreateCurrentPlatformsInfo(void)
{
    ZCOCLPlatformsInfoList *platformList = [ZCOCLPlatformsInfoList new];
    
    if(platformList.platforms.count == 0)
    {
        [platformList release];
        platformList = nil;
    }
    
    return platformList;
}

@end



