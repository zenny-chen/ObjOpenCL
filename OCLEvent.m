//
//  OCLEvent.m
//  ObjOpenCL
//
//  Created by Zenny Chen on 2016/11/25.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

#import "OCLEvent.h"

@implementation ZCOCLEvent

@synthesize event;

- (instancetype)initWithEvent:(cl_event)evt
{
    self = [super init];
    
    event = evt;
    
    return self;
}

- (void)dealloc
{
    clReleaseEvent(event);
    event = NULL;
    
    [super dealloc];
}

- (cl_int)status
{
    cl_int status = 0;
    clGetEventInfo(event, CL_EVENT_COMMAND_EXECUTION_STATUS, sizeof(status), &status, NULL);
    return status;
}

@end

