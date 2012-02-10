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

@interface CMIEventSystem : NSObject

@property (strong, nonatomic, readonly) EKEventStore *eventStore;
@property (strong, nonatomic) EKCalendar *defaultCalendar;

@property (strong, nonatomic, readonly) NSMutableDictionary* daysEvents;
@property (strong, nonatomic, readonly) NSMutableArray* eventDays;
@property (strong, nonatomic, readonly) NSMutableArray* eventsList;

@property (strong, nonatomic, readonly) NSMutableArray* cmiDays;

@property bool fetchAllEvents;
@property calendarTypes calendarType;

- (id) init;
- (void) createCMIEvents;
- (void) createCMIDays;

- (NSArray *)fetchEvents;
- (void) calculateDaysEvents:(NSDate*)startDate atEndDate:(NSDate*)endDate;
- (NSString*)formatDateAsDay:(NSDate*)date;
- (NSDate*) getMidnightDate:(NSDate*) date;
- (CMIEvent*)getCMIEvent:(NSInteger)dayEventIndex eventIndex:(NSInteger)eventIndex;


@end
