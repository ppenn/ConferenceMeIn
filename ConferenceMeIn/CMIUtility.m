//
//  CMIUtility.m
//  ConferenceMeIn
//
//  Created by philip penn on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIUtility.h"


@implementation CMIUtility

+ (void)Log:(NSString*)logMessage
{
    NSLog(@"%@", logMessage);
}

+ (void)LogError:(NSString*)logMessage
{
    NSLog(@"%@", logMessage);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:logMessage
                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];    
}

+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending) 
        return NO;
    
    return YES;
}

+ (NSDate*) getOffsetDate:(NSDate*)today atOffsetDays:(NSInteger)offsetDays
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *offset = [[NSDateComponents alloc] init];
    
    [offset setDay:offsetDays];
    NSDate* nextDate = [calendar dateByAddingComponents:offset toDate:today options:0];
    
    return nextDate;
}


+ (BOOL)createTestEvent:(EKEventStore*)eventStore startDate:(NSDate*) startDate endDate:(NSDate*)endDate title:(NSString*)title withConfNumber:(BOOL)withConfNumber
{
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    
    event.title = title; 
    
    event.startDate = startDate;
    event.endDate = endDate;// 
    event.location = withConfNumber ? @"1800 123 4567 xx 123456789" : @"nada" ; 
    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
    NSError *err;
    BOOL isSuccess=[eventStore saveEvent:event span:EKSpanThisEvent error:&err];
    
    return isSuccess;
}

+ (void)removeAllSimulatorEvents:(EKEventStore*)eventStore
{
    NSDate *startDate = nil;
    NSString *dateStrStart = @"20120101";    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    startDate = [dateFormat dateFromString:dateStrStart];  	
    
    NSDate* now = [[NSDate alloc] init];
    NSDate* endDate = [CMIUtility getOffsetDate:now atOffsetDays:5];
    
    NSPredicate *predicate;
    predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate 
                                                  calendars:nil]; 
    
    // Fetch all events that match the predicate.
    NSArray *events = [eventStore eventsMatchingPredicate:predicate];
    
    NSError* error = nil;
    for (EKEvent* event in events) {
        [eventStore removeEvent:event span:EKSpanThisEvent error:&error];
    }
    
}

+ (void)createTestEvents:(EKEventStore*)eventStore
{
    
#if TARGET_IPHONE_SIMULATOR
    // Simulator specific code
    
    [CMIUtility removeAllSimulatorEvents:eventStore];
    // Create some events
    
    NSDate* startDate = [[NSDate alloc] init];
    NSDate* endDate = [[NSDate alloc] initWithTimeInterval:60*60 sinceDate:startDate];
    NSDate* beforeStartDate = [[NSDate alloc] initWithTimeInterval:-(60*60) sinceDate:startDate];
    NSDate* beforeBeforeStartDate = [[NSDate alloc] initWithTimeInterval:-(2*60*60) sinceDate:beforeStartDate];
    
    [self createTestEvent:eventStore startDate:startDate endDate:endDate title:@"testtitle2" withConfNumber:TRUE];    
    [self createTestEvent:eventStore startDate:beforeStartDate endDate:startDate title:@"testtitle1" withConfNumber:TRUE];
    [self createTestEvent:eventStore startDate:beforeStartDate endDate:startDate title:@"NoConfNumEvent" withConfNumber:FALSE];
    [self createTestEvent:eventStore startDate:beforeBeforeStartDate endDate:beforeStartDate title:@"testtitle0" withConfNumber:TRUE];
    
    
#else // TARGET_IPHONE_SIMULATOR
    // Device specific code
#endif // TARGET_IPHONE_SIMULATOR    
    
}

@end
