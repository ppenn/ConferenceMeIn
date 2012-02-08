//
//  CMIEventTests.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIEventTests.h"

@implementation CMIEventTests

EKEventStore *_eventStore;
NSArray* _calendarEvents;

- (NSArray*)fetchEvents:(NSDate*)startDate atEndDate:(NSDate*)endDate
{
    NSPredicate* predicate = [_eventStore predicateForEventsWithStartDate:startDate endDate:endDate 
                                                               calendars:nil]; 
    
	// Fetch all events that match the predicate.
	NSArray *events = [_eventStore eventsMatchingPredicate:predicate];
    
    return events;
}


- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    _eventStore = [[EKEventStore alloc] init];
//    [CMIEventSystem createTestEvents:_eventStore];

    
#if TARGET_IPHONE_SIMULATOR
    // Simulator specific code
#else // TARGET_IPHONE_SIMULATOR
    // Device specific code
#endif // TARGET_IPHONE_SIMULATOR    

}

- (void)initializeEvents:(fetchTypes)fetchType
{
    NSDate *startDate = nil;
    NSDate *endDate = nil;
    NSString *dateStrStart = @"20120101";    
    NSString *dateStrEnd = @"20120102";    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    
    switch (fetchType) {
        case sinceJan:
            // endDate is 1 day = 60*60*24 seconds = 86400 seconds from startDate
            // Convert string to date object
            startDate = [dateFormat dateFromString:dateStrStart];  	
            endDate = [NSDate date];
            break;
        case jan1:
            startDate = [dateFormat dateFromString:dateStrStart];  	
            endDate = [dateFormat dateFromString:dateStrEnd];  	
            break;
            
        default:
            break;
    }
    
    
	_calendarEvents = [self fetchEvents:startDate atEndDate:endDate];

}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

// All code under test must be linked into the Unit Test bundle
- (void)testConferenceEventsCreeation
{
    [self initializeEvents:jan1];
    NSArray* cmiEvents = [CMIEvent createCMIEvents:_calendarEvents];
    STAssertTrue([cmiEvents count] > 0, @"Need some events for this to fly :-(");
}


- (void)testCMIHasConferenceNumber
{
    [self initializeEvents:jan1];

    NSArray* cmiEvents = [CMIEvent createCMIEvents:_calendarEvents];
    
    for (id event in cmiEvents)
    {
        CMIEvent* cmiEvent = (CMIEvent*) event;
        STAssertTrue(cmiEvent.hasConferenceNumber == true, @"All Events should have conf numbers");
        NSLog(@"%@", [NSString stringWithFormat:@"%@", cmiEvent.conferenceNumberURL]);
    }
}

@end
