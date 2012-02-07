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

typedef enum calendarTypes
{
	allCalendars = 0,
    defaultCalendarType = 1
}calendarTypes;

@interface CMIEventSystem : NSObject

@property (strong, nonatomic, readonly) EKEventStore *eventStore;
@property (strong, nonatomic) EKCalendar *defaultCalendar;
@property (strong, nonatomic, readonly) NSMutableDictionary* daysEvents;
@property (strong, nonatomic, readonly) NSMutableArray* eventDays;

@property bool fetchAllEvents;
@property calendarTypes calendarType;

- (id) init;
- (NSArray *)fetchEvents;
- (void) calculateDaysEvents:(NSDate*)startDate atEndDate:(NSDate*)endDate;
- (NSString*)formatDateAsDay:(NSDate*)date;
- (NSDate*) getMidnightDate:(NSDate*) date;
- (CMIEvent*)getCMIEvent:(NSInteger)dayEventIndex eventIndex:(NSInteger)eventIndex;

+ (NSDate*) getOffsetDate:(NSDate*)today atOffsetDays:(NSInteger)offsetDays;
+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;
+ (void)createTestEvents:(EKEventStore*)eventStore;
+ (void)removeAllSimulatorEvents:(EKEventStore*)eventStore;

@end
