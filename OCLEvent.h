//
//  OCLEvent.h
//  ObjOpenCL
//
//  Created by Zenny Chen on 2016/11/25.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

#pragma once

#import "obj_opencl.h"

@interface ZCOCLEvent : NSObject<OCLEvent>
{
@private
    
    cl_event event;
}

- (instancetype)initWithEvent:(cl_event)evt;

@end

