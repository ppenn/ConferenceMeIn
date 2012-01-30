//
//  CMIEventSystem.h
//  ConferenceMeIn
//
//  Created by philip penn on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

typedef enum calendarTypes
{
	allCalendars = 0,
    defaultCalendarType = 1
}calendarTypes;

@interface CMIEventSystem : NSObject

@property (strong, nonatomic, readonly) EKEventStore *eventStore;
@property (strong, nonatomic) EKCalendar *defaultCalendar;

@property bool fetchAllEvents;
@property calendarTypes calendarType;

- (id) init;

- (NSArray *)fetchEvents;

@end
