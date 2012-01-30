//
//  CMIEventSystem.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIEventSystem.h"

@implementation CMIEventSystem

@synthesize eventStore = _eventStore;
@synthesize fetchAllEvents = _fetchAllEvents;
@synthesize calendarType = _calendarType;
@synthesize defaultCalendar = _defaultCalendar;

- (id) init
{
    self = [super init];
    
    if (self != nil)
    {
        // your code here
        _eventStore = [[EKEventStore alloc] init];
        // Get the default calendar from store.
        _defaultCalendar = [_eventStore defaultCalendarForNewEvents];
        _calendarType = allCalendars;
        _fetchAllEvents = false;
    }
    
    return self;    
}

- (NSArray *)fetchEvents
{
	NSDate *startDate = nil;
    if (_fetchAllEvents == true)
    {
        //TODO: date arithmetic
        NSString *dateStrStart = @"20120101";    
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyyMMdd"];
        startDate = [dateFormat dateFromString:dateStrStart];  	
    }
    else
    {
        startDate = [NSDate date]; 
    }
	
	// endDate is 1 day = 60*60*24 seconds = 86400 seconds from startDate
	NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:86400];
	
    
    NSArray* calendarArray = nil; // All calendars
    NSPredicate *predicate;
    if (_calendarType == defaultCalendarType)
    {
        calendarArray = [NSArray arrayWithObject:_defaultCalendar];
        predicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate 
                                                           calendars:calendarArray]; 
    }
    else
    {
        predicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate 
                                                           calendars:nil]; 
        
    }
	
	// Fetch all events that match the predicate.
	NSArray *events = [self.eventStore eventsMatchingPredicate:predicate];
    
    //    NSString *nsString = [((EKCalendarItem*)[events objectAtIndex:0]) notes];
    
	return events;
    
}

@end
