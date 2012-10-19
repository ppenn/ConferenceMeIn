//
//  CMIEventSystem.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/26/12.
//  Copyright (c) 2012 Paleon Solutions. All rights reserved.
//

#import "CMIEventCalendar.h"
#import "CMIUtility.h"

#define MINUTES_PRIOR_TO_NOW 0

@implementation CMIEventCalendar

@synthesize eventStore = _eventStore;
@synthesize calendarType = _calendarType;
@synthesize defaultCalendar = _defaultCalendar;
@synthesize eventsList = _eventsList;
@synthesize cmiDaysDictionary = _cmiDaysDictionary;
@synthesize cmiDaysArray = _cmiDaysArray;
@synthesize filterType = _filterType;
@synthesize calendarTimeframeType = _calendarTimeframeType;
@synthesize currentTimeframeStarts = _currentTimeframeStarts;
@synthesize numConfEvents = _numConfEvents;
@synthesize cmiFilteredDaysArray = _cmiFilteredDaysArray;
@synthesize cmiFilteredDaysDictionary = _cmiFilteredDaysDictionary;
@synthesize lastRefreshTime = _lastRefreshTime;
@synthesize showCompletedEvents = _showCompletedEvents;
@synthesize accessGranted = _accessGranted;

NSDate* _eventsStartDate = nil;
NSDate* _eventsEndDate = nil;

NSMutableDictionary* _currentDaysDictionary;
NSMutableArray* _currentDaysArray;

- (NSInteger)numDays
{
    return _currentDaysArray.count;
}

- (id) init
{
    self = [super init];
    
    [CMIUtility Log:@"CMIEventCalendar::init()"];
    
    if (self != nil)
    {
        // your code here
        _eventStore = [[EKEventStore alloc] init];

        _calendarType = allCalendars;
        _calendarTimeframeType = weekAhead;
        _currentTimeframeStarts = 0;
        _showCompletedEvents = NO;
        
        _cmiDaysDictionary = [[NSMutableDictionary alloc] init];
        _cmiDaysArray = [[NSMutableArray alloc] init];
        _cmiFilteredDaysDictionary = [[NSMutableDictionary alloc] init];
        _cmiFilteredDaysArray = [[NSMutableArray alloc] init];
        _eventsList = [[NSMutableArray alloc] init];
        
        self.filterType = filterNone;
    }

    return self;
}

// NB this assumes that init() has been called
- (void) finishInit
{
    [CMIUtility Log:@"CMIEventCalendar::finishInit()"];

    // Get the default calendar from store.
    _defaultCalendar = [_eventStore defaultCalendarForNewEvents];
    
}
//**********************************************************************************

//   Below is a block for checking is current ios version higher than required version.

//**********************************************************************************

- (void)setFilterType:(eventFilterTypes)filterType
{
    [CMIUtility Log:@"setFilterType()"];

    _filterType = filterType;
    
    if (_filterType == filterNone) {
        _currentDaysDictionary = _cmiDaysDictionary;
        _currentDaysArray = _cmiDaysArray;        
    }
    else {
        _currentDaysDictionary = _cmiFilteredDaysDictionary;
        _currentDaysArray = _cmiFilteredDaysArray;        
    }
}

- (NSIndexPath*)getDayEventIndexForDate:(NSDate*)date
{
    [CMIUtility Log:@"getDayEventIndexForDate()"];

    NSDate* currentDay = [CMIUtility getMidnightDate:date];
    NSInteger currentDaySection = -1;
    NSInteger currentDayRow = -1;
    
    for (NSInteger i = 0; i < [_currentDaysArray count]; i++ ) {
        NSDate* date = [[_currentDaysArray objectAtIndex:i] dateAtMidnight];
        if ([date isEqualToDate:currentDay] == TRUE) {
            currentDaySection = i;
            break;
        }
    }
    
    if (currentDaySection != -1) {
        NSArray* events = [[_currentDaysDictionary objectForKey:currentDay] cmiEvents];
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
    [CMIUtility Log:@"createCMIEvents()"];
    
    if (_eventsList != nil) {
        [_eventsList removeAllObjects];
    }
    [_eventsList addObjectsFromArray:[self fetchEvents]];    
}

- (void) createCMIDays
{
    [CMIUtility Log:@"createCMIDays()"];

    [_cmiDaysDictionary removeAllObjects];
    [_cmiDaysArray removeAllObjects];
    [_cmiFilteredDaysDictionary removeAllObjects];
    [_cmiFilteredDaysArray removeAllObjects];
    
    NSDate *nextDay = [ _eventsStartDate copy];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *offset = [[NSDateComponents alloc] init];
    
    NSInteger i = 0;
    
    while (([nextDay compare:_eventsEndDate] == NSOrderedAscending))
    {
        NSDate* nextDayMidnight = [CMIUtility getMidnightDate:nextDay];
        CMIDay* cmiDay = [[CMIDay alloc] initWithDay:nextDayMidnight];
        [_cmiDaysDictionary setObject:cmiDay forKey:nextDayMidnight];        
        [_cmiDaysArray addObject:cmiDay];        
        CMIDay* cmiDayCopy = [[CMIDay alloc] initWithDay:nextDayMidnight];
        [_cmiFilteredDaysDictionary setObject:cmiDayCopy forKey:nextDayMidnight];        
        [_cmiFilteredDaysArray addObject:cmiDayCopy];        
        
        // Move to next day
        [offset setDay:++i];
        nextDay = [calendar dateByAddingComponents:offset toDate:_eventsStartDate options:0];
    }
//    self.filterType = _filterType;
    
}

- (void) assignCMIEventsToCMIDays
{
    [CMIUtility Log:@"assignCMIEventsToCMIDays()"];
    
    _numConfEvents = 0;
    
    // Populate the days with events
    for (EKEvent* event in _eventsList) {
        // Need to convert date into day
        NSDate* eventDay = [CMIUtility getMidnightDate:event.startDate];  	
        // Should we be creating CMIEvent?
        CMIEvent* cmiEvent = [[CMIEvent alloc] initWithEKEvent:event];
        
        if (cmiEvent.hasConferenceNumber == true) {
            _numConfEvents++;
        }
        
        CMIDay* cmiDay = [_cmiDaysDictionary objectForKey:eventDay];
        [cmiDay.cmiEvents addObject:cmiEvent];
        if (cmiEvent.hasConferenceNumber == true) {
            CMIDay* cmiConfDay = [_cmiFilteredDaysDictionary objectForKey:eventDay];
            [cmiConfDay.cmiEvents addObject:cmiEvent];
        }
    }
    
}


- (void) createCMIDayEvents
{
    [CMIUtility Log:@"createCMIDayEvents()"];

    // Get the CMIEvents
    [self createCMIEvents];

    // Create the CMIDays
    [self createCMIDays];
    
    // Assign the CMIEvents to CMIDays
    [self assignCMIEventsToCMIDays];
    
}



- (CMIEvent*)getCMIEventByIndexPath:(NSInteger)dayEventIndex eventIndex:(NSInteger)eventIndex
{
    [CMIUtility Log:@"getCMIEventByIndexPath()"];
    
    CMIDay* cmiDay = [_currentDaysArray objectAtIndex:dayEventIndex];

    return (CMIEvent*)[cmiDay.cmiEvents objectAtIndex:eventIndex];
}

- (CMIDay*)getCMIDayByIndex:(NSInteger)dayIndex
{
    [CMIUtility Log:@"getCMIDayByIndex()"];

    CMIDay* cmiDay = [_currentDaysArray objectAtIndex:dayIndex];
    
    return cmiDay;
}

- (NSString*)getCMIDayNameByIndex:(NSInteger)dayIndex
{
    [CMIUtility Log:@"getCMIDayNameByIndex()"];
    
    CMIDay* cmiDay = [self getCMIDayByIndex:dayIndex];

    NSString* day = [CMIUtility formatDateAsDay:cmiDay.dateAtMidnight];
    
    return day;
}

- (void)calculateCurrentStartTime
{
    [CMIUtility Log:@"calculateCurrentStartTime()"];

    NSDate* now = [NSDate date];

    if (_showCompletedEvents == YES) {
        _eventsStartDate = [CMIUtility getMidnightDate:now];
    }
    else {
        _eventsStartDate = [CMIUtility getOffsetDateByMinutes:now offsetMinutes:-MINUTES_PRIOR_TO_NOW];
    }
}

- (void)calculateCalendarTimeframe
{
    [CMIUtility Log:@"calculateCalendarTimeframe()"];

	_eventsStartDate = nil;
    _eventsEndDate = nil;
	
    [self calculateCurrentStartTime];
    
    NSDate* now = [NSDate date];
    
    switch (_calendarTimeframeType) {
        case weekAhead:
            _eventsEndDate = [CMIUtility getMidnightDate:now];
            _eventsEndDate = [CMIUtility getOffsetDate:_eventsEndDate atOffsetDays:7];
            _eventsEndDate = [CMIUtility getOffsetDateByMinutes:_eventsEndDate offsetMinutes:-1];
            
            break;
        case today:
            _eventsEndDate = [CMIUtility getMidnightDate:now];
            _eventsEndDate = [CMIUtility getOffsetDate:_eventsEndDate atOffsetDays:1];
            _eventsEndDate = [CMIUtility getOffsetDateByMinutes:_eventsEndDate offsetMinutes:-1];
            break;
        case todayAndTomorrow:
            _eventsEndDate = [CMIUtility getOffsetDate:now atOffsetDays:2];
            _eventsEndDate = [CMIUtility getMidnightDate:_eventsEndDate];
            _eventsEndDate = [CMIUtility getOffsetDateByMinutes:_eventsEndDate offsetMinutes:-1];
            break;
        case debugTimeframe:
            _eventsStartDate = [CMIUtility dayToDate:@"20120201"];
            _eventsEndDate = [CMIUtility getOffsetDate:now atOffsetDays:1];
            break;
            
        default:
            break;
    }
}

- (NSArray *)fetchEvents
{
    [CMIUtility Log:@"fetchEvents()"];

    [self calculateCalendarTimeframe];
    
    
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
    _lastRefreshTime = [NSDate date];
    NSArray *sortedEvents =
    [events sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)];
    
	return sortedEvents;
    
}

@end
