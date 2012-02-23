//
//  CMIEventSystemTests.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIEventSystemTests.h"

@implementation CMIEventSystemTests

@synthesize cmiEventSystem = _cmiEventSystem;

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    _cmiEventSystem = [[CMIEventCalendar alloc] init];
    [CMIUtility createTestEvents:_cmiEventSystem.eventStore];
}

- (void)testCreateCMIDays
{
    
}

- (void)testCalculateDateStuff
{
    NSDate* nowDate = [NSDate date]; 
    NSDate* yesterdayDate = [CMIUtility getOffsetDate:nowDate atOffsetDays:-1];
    NSDate* tomorrowDate = [CMIUtility getOffsetDate:nowDate atOffsetDays:1];

    NSString* today = [CMIUtility formatDateAsDay:nowDate];
    NSString* tomorrow = [CMIUtility formatDateAsDay:tomorrowDate];
    NSString* yesterday = [CMIUtility formatDateAsDay:yesterdayDate];

    STAssertTrue([today isEqualToString:@"Today"], @"Dates aren't flying");
    STAssertTrue([tomorrow isEqualToString:@"Tomorrow"], @"Dates aren't flying");
    STAssertTrue([yesterday isEqualToString:@"Yesterday"], @"Dates aren't flying");
    
}


    


@end
