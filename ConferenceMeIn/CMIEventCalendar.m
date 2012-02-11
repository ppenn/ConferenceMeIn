//
//  CMIEventSystem.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIEventCalendar.h"
#import "CMIUtility.h"

@implementation CMIEventCalendar

@synthesize eventStore = _eventStore;
@synthesize fetchAllEvents = _fetchAllEvents;
@synthesize calendarType = _calendarType;
@synthesize defaultCalendar = _defaultCalendar;
@synthesize eventsList = _eventsList;
@synthesize cmiDaysDictionary = _cmiDaysDictionary;
@synthesize cmiDaysArray = _cmiDaysArray;
@synthesize filterType = _filterType;

//@synthesize daysEvents = _daysEvents;
//@synthesize eventDays = _eventDays;

NSDate* _eventsStartDate = nil;
NSDate* _eventsEndDate = nil;

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
        _filterType = filterNone;
        
        _cmiDaysDictionary = [[NSMutableDictionary alloc] init]; 
        _cmiDaysArray = [[NSMutableArray alloc] init];
        
    }
    
    return self;    
}

- (NSIndexPath*)getDayEventIndexForDate:(NSDate*)date
{
    NSDate* currentDay = [CMIUtility getMidnightDate:date];
    NSInteger currentDaySection = -1;
    NSInteger currentDayRow = -1;
    
    for (NSInteger i = 0; i < [_cmiDaysArray count]; i++ ) {
        NSDate* date = [[_cmiDaysArray objectAtIndex:i] dateAtMidnight];
        if ([date isEqualToDate:currentDay] == TRUE) {
            currentDaySection = i;
            break;
        }
    }
    
    if (currentDaySection != -1) {
        NSArray* events = [[_cmiDaysDictionary objectForKey:currentDay] cmiEvents];
        if (events.count > 0) {
            for (currentDayRow = 0; currentDayRow < (events.count -1); currentDayRow++) {
                CMIEvent* event = [events objectAtIndex:currentDayRow];
                // If event is current
                if ([CMIUtility date:date isBetweenDate:event.ekEvent.startDate andDate:event.ekEvent.endDate] == true) {
                    break;
                }
                // if current event is later than now, then bail too
                if ([date compare:event.ekEvent.startDate] == NSOrderedAscending ||
                    [date compare:event.ekEvent.startDate] == NSOrderedSame) {
                    break;
                }
            }
        }
    }
    
    NSIndexPath *scrollIndexPath = nil;
    if (currentDayRow > -1) {
        scrollIndexPath = [NSIndexPath indexPathForRow:currentDayRow inSection:currentDaySection];
    }
    else if (currentDaySection > -1) {
        // Get the last row 
        scrollIndexPath = [NSIndexPath indexPathForRow:NSNotFound inSection:currentDaySection];
    }
    return scrollIndexPath;
}


- (void) createCMIEvents
{
    NSLog(@"createCMIEvents()");
    
    if (_eventsList != nil) {
        _eventsList = nil;
//        [_eventsList removeAllObjects];
    }
//    _eventsList = [CMIEvent createCMIEvents:[self fetchEvents]];    
    _eventsList = [self fetchEvents];    
}

- (void) createCMIDays
{
    NSLog(@"createCMIDays()");

    [_cmiDaysDictionary removeAllObjects];
    [_cmiDaysArray removeAllObjects];
    
    NSDate *nextDay = [_eventsStartDate copy];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *offset = [[NSDateComponents alloc] init];
    
    NSInteger i = 0;
    
    while (([nextDay compare:_eventsEndDate] == NSOrderedAscending))
    {
        NSDate* nextDayMidnight = [CMIUtility getMidnightDate:nextDay];
        CMIDay* cmiDay = [[CMIDay alloc] initWithDay:nextDayMidnight];
        [_cmiDaysDictionary setObject:cmiDay forKey:nextDayMidnight];        
        [_cmiDaysArray addObject:cmiDay];        
        
        // Move to next day
        [offset setDay:++i];
        nextDay = [calendar dateByAddingComponents:offset toDate:_eventsStartDate options:0];
    }
    
}

- (void) assignCMIEventsToCMIDays
{
    NSLog(@"assignCMIEventsToCMIDays()");
    
    // Populate the days with events
    for (EKEvent* event in _eventsList) {
        // Need to convert date into day
        NSDate* eventDay = [CMIUtility getMidnightDate:event.startDate];  	
        // Should we be creating CMIEvent?
        CMIEvent* cmiEvent = [[CMIEvent alloc] initWithEKEvent:event];
        
        if (_filterType == filterNone || cmiEvent.hasConferenceNumber == true) {
            CMIDay* cmiDay = [_cmiDaysDictionary objectForKey:eventDay];
            [cmiDay.cmiEvents addObject:cmiEvent];
        }
    }
    
}


- (void) createCMIDayEvents
{
    NSLog(@"createCMIDayEvents()");

    // Get the CMIEvents
    [self createCMIEvents];

    // Create the CMIDays
    [self createCMIDays];
    
    // Assign the CMIEvents to CMIDays
    [self assignCMIEventsToCMIDays];
    
}




//- (void) assignCMIEventsToDayEvents:(NSDate*)startDate atEndDate:(NSDate*)endDate atEvents:(NSArray*)events
//{
//
//    // Get the days together
//    [self calculateDaysEvents:startDate atEndDate:endDate];
//
//    // Now populate the number
//    for (EKEvent* event in events) {
//        // Need to convert date into day
//        NSDate* eventDay = [CMIUtility getMidnightDate:event.startDate];  	
//        NSMutableArray *events = [_daysEvents objectForKey:eventDay];
//        // Should we be creating CMIEvent?
//        CMIEvent* cmiEvent = [[CMIEvent alloc] initWithEKEvent:event];
//        [events addObject:cmiEvent];
//        [_daysEvents setObject:events forKey:eventDay];        
//    }
//
//}
//
//- (void) calculateDaysEvents:(NSDate*)startDate atEndDate:(NSDate*)endDate
//{
//    [_daysEvents removeAllObjects];
//    [_eventDays removeAllObjects];
//    
//    NSDate *nextDay=[startDate copy];
//    
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *offset = [[NSDateComponents alloc] init];
//    
//    int i = 0;
//
//    while (([nextDay compare:endDate] == NSOrderedAscending))
//    {
////        NSInteger numEvents = 0; //TODO: get # of events for that "day". going to need to get day range
//        NSMutableArray* events = [[NSMutableArray alloc] init];
//        NSDate* nextDayMidnight = [CMIUtility getMidnightDate:nextDay];
//        [_daysEvents setObject:events forKey:nextDayMidnight];
//        [_eventDays addObject:nextDayMidnight];
//
//        // Move to next day
//        i++;
//        [offset setDay:i];
//        nextDay = [calendar dateByAddingComponents:offset toDate:startDate options:0];
//    }
//
//}

- (CMIEvent*)getCMIEventByIndexPath:(NSInteger)dayEventIndex eventIndex:(NSInteger)eventIndex
{
    CMIDay* cmiDay = [_cmiDaysArray objectAtIndex:dayEventIndex];
    
    return (CMIEvent*)[cmiDay.cmiEvents objectAtIndex:eventIndex];
}

- (CMIDay*)getCMIDayByIndex:(NSInteger)dayIndex
{
    CMIDay* cmiDay = [_cmiDaysArray objectAtIndex:dayIndex];
    
    return cmiDay;
}

- (NSString*)getCMIDayNameByIndex:(NSInteger)dayIndex
{
    [CMIUtility Log:@"getCMIDayNameByIndex()"];
    
    CMIDay* cmiDay = [self getCMIDayByIndex:dayIndex];

    NSString* day = [CMIUtility formatDateAsDay:cmiDay.dateAtMidnight];
    
    return day;
}


- (NSArray *)fetchEvents
{
	_eventsStartDate = nil;
    if (_fetchAllEvents == true)
    {
        //TODO: date arithmetic...new settings etc
        _eventsStartDate = [CMIUtility dayToDate:@"20120101"];
    }
    else
    {
        _eventsStartDate = [CMIUtility getMidnightDate:[NSDate date]];
    }
	
    NSDate* now = [[NSDate alloc] init];
	_eventsEndDate = [CMIUtility getOffsetDate:now atOffsetDays:1];
    
    NSArray* calendarArray = nil; // All calendars
    NSPredicate *predicate;
    if (_calendarType == defaultCalendarType)
    {
        calendarArray = [NSArray arrayWithObject:_defaultCalendar];
        predicate = [self.eventStore predicateForEventsWithStartDate:_eventsStartDate endDate:_eventsEndDate 
                                                           calendars:calendarArray]; 
    }
    else
    {
        predicate = [self.eventStore predicateForEventsWithStartDate:_eventsStartDate endDate:_eventsEndDate 
                                                           calendars:nil]; 
        
    }
	
	// Fetch all events that match the predicate.
	NSArray *events = [self.eventStore eventsMatchingPredicate:predicate];
    NSArray *sortedEvents =
    [events sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)];

    // What's this for?? Resetting Start Date to first event...not sure about that, want all days, period
//    if (sortedEvents != nil && sortedEvents.count > 0) {
//       startDate = [[sortedEvents objectAtIndex:0] startDate];
//    }

//    [self assignCMIEventsToDayEvents:_eventsStartDate atEndDate:_eventsEndDate atEvents:sortedEvents];
    
	return sortedEvents;
    
}

@end
