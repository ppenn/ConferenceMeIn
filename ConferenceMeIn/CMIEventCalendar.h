//
//  CMIEventSystem.h
//  ConferenceMeIn
//
//  Created by philip penn on 1/26/12.
//  Copyright (c) 2012 Paleon Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "CMIEvent.h"
#import "CMIDay.h"

typedef enum calendarTimeframes
{
    weekAhead = 0,
    today,
    todayAndTomorrow,
    debugTimeframe
}calendarTimeframes;


typedef enum calendarTypes
{
	allCalendars = 0,
    defaultCalendarType = 1
    //TODO: Add user-selected calendars...V2
}calendarTypes;

typedef enum eventFilterTypes
{
	filterNone = 0,
    filterConfCallOnly = 1
}eventFilterTypes;

@interface CMIEventCalendar : NSObject

@property (strong, nonatomic, readonly) EKEventStore *eventStore;
@property (strong, nonatomic) EKCalendar *defaultCalendar;

@property (strong, nonatomic, readonly) NSMutableArray* eventsList;

@property (strong, nonatomic, readonly) NSMutableDictionary* cmiDaysDictionary;
@property (strong, nonatomic, readonly) NSMutableArray* cmiDaysArray;

@property (strong, nonatomic, readonly) NSMutableDictionary* cmiFilteredDaysDictionary;
@property (strong, nonatomic, readonly) NSMutableArray* cmiFilteredDaysArray;

@property (nonatomic) eventFilterTypes filterType;

@property calendarTimeframes calendarTimeframeType;
@property calendarTypes calendarType;
@property (nonatomic, assign) NSInteger currentTimeframeStarts;
@property (readonly, nonatomic) NSInteger numConfEvents;
@property (readonly, nonatomic) NSInteger numDays;
@property (strong, nonatomic) NSDate* lastRefreshTime;
@property BOOL showCompletedEvents;
@property BOOL accessGranted;

- (id) init;
- (void) finishInit;
- (void) createCMIEvents;
- (void) createCMIDays;
- (void) createCMIDayEvents;
- (NSIndexPath*)getDayEventIndexForDate:(NSDate*)date;

- (NSArray *)fetchEvents;
- (CMIDay*)getCMIDayByIndex:(NSInteger)dayEventIndex;
- (NSString*)getCMIDayNameByIndex:(NSInteger)dayEventIndex;
- (CMIEvent*)getCMIEventByIndexPath:(NSInteger)dayEventIndex eventIndex:(NSInteger)eventIndex;

@end
