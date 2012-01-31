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
    _cmiEventSystem = [[CMIEventSystem alloc] init];
    
}

- (void)testCalculateDateStuff
{
    NSDate* nowDate = [[NSDate alloc] init]; 
    NSDate* yesterdayDate = [_cmiEventSystem getOffsetDate:nowDate atOffsetDays:-1];
    NSDate* tomorrowDate = [_cmiEventSystem getOffsetDate:nowDate atOffsetDays:1];

    NSString* today = [_cmiEventSystem formatDateAsDay:nowDate];
    NSString* tomorrow = [_cmiEventSystem formatDateAsDay:tomorrowDate];
    NSString* yesterday = [_cmiEventSystem formatDateAsDay:yesterdayDate];

    STAssertTrue([today isEqualToString:@"Today"], @"Dates aren't flying");
    STAssertTrue([tomorrow isEqualToString:@"Tomorrow"], @"Dates aren't flying");
    STAssertTrue([yesterday isEqualToString:@"Yesterday"], @"Dates aren't flying");
    
}

- (void)testCalculateDaysEvents
{
    NSDate* nowDate = [[NSDate alloc] init]; 
    NSDate* startDate = [_cmiEventSystem getOffsetDate:nowDate atOffsetDays:-1];
    NSDate* endDate = [_cmiEventSystem getOffsetDate:nowDate atOffsetDays:1];
    
    [_cmiEventSystem calculateDaysEvents:startDate atEndDate:endDate];
    for(NSString *aKey in _cmiEventSystem.daysEvents){
        
        NSLog(@"%@", aKey);
//        NSNumber *num = [_cmiEventSystem.daysEvents objectForKey:aKey];
        NSMutableArray *events = [_cmiEventSystem.daysEvents objectForKey:aKey];
        NSInteger numEvents = [events count];
        NSLog(@"%d", numEvents); //made up method
        
    }
    
    STAssertTrue([_cmiEventSystem.daysEvents count] == 3, @"Must have some days"); 
}

// All code under test must be linked into the Unit Test bundle
- (void)testFetchEvents
{
    _cmiEventSystem.fetchAllEvents = true;
    NSArray* eventsList = [_cmiEventSystem fetchEvents];
    STAssertTrue([eventsList count] > 0, @"Need some events :-(");

    for(NSString *aKey in _cmiEventSystem.daysEvents){
        
        NSLog(@"%@", aKey);
        NSNumber *num = [_cmiEventSystem.daysEvents objectForKey:aKey];
        NSInteger numEvents = [num intValue];
        NSLog(@"%d", numEvents); //made up method
        
    }
    
}

@end
