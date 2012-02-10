//
//  CMIDay.m
//  ConferenceMeIn
//
//  Created by philip penn on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIDay.h"
#import "CMIEvent.h"
//TODO: class forwarding?

@implementation CMIDay

@synthesize dateAtMidnight = _dateAtMidnight;
@synthesize cmiEvents = _cmiEvents;

- (id) initWithCMIEvents:(NSDate*)dateAtMidnight cmiEvents:(NSArray*)cmiEvents
{
    self = [super init];
    
    if (self != nil)
    {    
        _dateAtMidnight = dateAtMidnight;
        _cmiEvents = cmiEvents;
    }

    return self;
}


@end