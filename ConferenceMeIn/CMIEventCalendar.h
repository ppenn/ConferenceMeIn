//
//  CMIEventSystem.h
//  ConferenceMeIn
//
//  Created by philip penn on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "CMIEvent.h"
#import "CMIDay.h"

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

//@property (strong, nonatomic, readonly) NSMutableDictionary* daysEvents;
//@property (strong, nonatomic, readonly) NSMutableArray* eventDays;

@property (strong, nonatomic, readonly) NSArray* eventsList;

@property (strong, nonatomic, readonly) NSMutableDictionary* cmiDaysDictionary;
@property (strong, nonatomic, readonly) NSMutableArray* cmiDaysArray;

@property eventFilterTypes filterType;

@property bool fetchAllEvents;
@property calendarTypes calendarType;

- (id) init;
- (void) createCMIEvents;
- (void) createCMIDays;
- (void) createCMIDayEvents;
- (NSIndexPath*)getDayEventIndexForDate:(NSDate*)date;

- (NSArray *)fetchEvents;
- (CMIEvent*)getCMIEventByIndexPath:(NSInteger)dayEventIndex eventIndex:(NSInteger)eventIndex;
- (CMIDay*)getCMIDayByIndex:(NSInteger)dayEventIndex;
- (NSString*)getCMIDayNameByIndex:(NSInteger)dayEventIndex;

@end
