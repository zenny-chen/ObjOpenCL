//
//  OCLPlatformInfo.h
//  ObjOpenCL
//
//  Created by Zenny Chen on 2016/11/22.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

#pragma once

#import "obj_opencl.h"


@interface ZCOCLPlatformInfo : NSObject<OCLPlatformInfo>
{
@private
    
    NSString *name;
    NSString *version;
    NSString *vendor;
    NSString *profile;

    cl_platform_id mPlatform;
    
    cl_int clStatus;
}

- (instancetype)initWithPlatformID:(cl_platform_id)platform;
- (cl_platform_id)platform;

@end


@interface ZCOCLPlatformsInfoList : NSObject<OCLPlatformsInfoList>
{
@private
    
    NSMutableArray *platforms;
    
    cl_int clStatus;
}

@end

