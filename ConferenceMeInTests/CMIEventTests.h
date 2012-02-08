//
//  CMIEventTests.h
//  ConferenceMeIn
//
//  Created by philip penn on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//  Logic unit tests contain unit test code that is designed to be linked into an independent test executable.
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

#import <SenTestingKit/SenTestingKit.h>
#import "CMIEvent.h"
#import <TargetConditionals.h>

typedef enum fetchTypes
{
	sinceJan = 0,
    jan1,
    twentyFourHours
} fetchTypes;

@interface CMIEventTests : SenTestCase


@end
