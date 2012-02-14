//
//  CMIUtility.h
//  ConferenceMeIn
//
//  Created by philip penn on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface CMIUtility : NSObject

+ (void)Log:(NSString*)logMessage;
+ (void)LogError:(NSString*)logMessage;
+ (NSDate*) getOffsetDate:(NSDate*)day atOffsetDays:(NSInteger)offsetDays;
+ (NSDate*) getOffsetDateByHours:(NSDate*)date offsetHours:(NSInteger)offsetHours;
+ (NSDate*) getOffsetDateByMinutes:(NSDate*)date offsetMinutes:(NSInteger)offsetMinutes;
+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;


//TODO:Maybe move these to TestUtility
+ (void)createTestEvents:(EKEventStore*)eventStore;
+ (void)removeAllSimulatorEvents:(EKEventStore*)eventStore;
+ (BOOL)createTestEvent:(EKEventStore*)eventStore startDate:(NSDate*) startDate endDate:(NSDate*)endDate title:(NSString*)title withConfNumber:(BOOL)withConfNumber;
+ (BOOL)isSameDay:(NSDate*)date1 atDate2:(NSDate*)date2;
+ (NSString*)formatDateAsDay:(NSDate*)date;
+ (NSDate*) getMidnightDate:(NSDate*) date;
+ (NSDate*) dayToDate:(NSString*) day;

@end
