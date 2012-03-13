//
//  CMIUtility.m
//  ConferenceMeIn
//
//  Created by philip penn on 2/8/12.
//  Copyright (c) 2012 Paleon Solutions. All rights reserved.
//

#import "CMIUtility.h"

//TOGGLE THIS BETWEEN 0 (release) and 1 (debug)
#define CMI_DEBUG 1

#define REGEX_1_PREFIX_COUNTRIES @"[us|ca|au|ie|mx]"


@implementation CMIUtility

+ (NSString*)getCountryName
{
    NSLocale* currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString* countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    
    NSString *country = [currentLocale displayNameForKey: NSLocaleCountryCode value: countryCode];
    return country;
}

+ (BOOL)countryHas0Prefix
{
    NSError* error = nil;
    
    NSRegularExpression *regexCountry = [NSRegularExpression regularExpressionWithPattern:REGEX_1_PREFIX_COUNTRIES
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:&error];
    
    NSLocale* currentLocale = [NSLocale currentLocale];  // get the current locale.
    NSString* countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    
    NSRange range = [regexCountry rangeOfFirstMatchInString:countryCode options:0 range:NSMakeRange(0, [countryCode  length])];
    if (range.location == NSNotFound) {
        return YES;
    }
    else {
        return FALSE;
    }
}

+ (NSString*) getRegionValue:(NSString*)key
{
#define DEFAULT_REGION_TABLE @"Region_GB"
    
    NSString* regionValue = nil;
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    if ([countryCode isEqualToString:@"CA"]) {
        countryCode = @"US";
    }
    NSString *tableName = [NSString stringWithFormat:@"Region_%@", countryCode];
    
    regionValue = [[NSBundle mainBundle] localizedStringForKey:key value:nil table:tableName];    

    // If value contains key, let's assume we didn't find it and use default table
    if ([regionValue rangeOfString:@"Key"].location != NSNotFound) {
        tableName = DEFAULT_REGION_TABLE;
        regionValue = [[NSBundle mainBundle] localizedStringForKey:key value:nil table:tableName];    
    }
    
    return regionValue;
}

+ (void)Log:(NSString*)logMessage
{
#if CMI_DEBUG
    NSLog(@"%@", logMessage);
#endif
}

+ (void)LogError:(NSString*)logMessage
{
    NSLog(@"%@", logMessage);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:logMessage
                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];    
}

+ (void)LogEvent:(EKEvent*)event
{
#if CMI_DEBUG

    if (event == nil) {
        NSLog(@"Event is nil!!");        
        return;
    }

    if ([CMIUtility environmentIsAtIOS5OrHigher] == YES) {
        NSLog(@"EventID [ %@ ]", event.UUID);
    }
    
    NSLog(@"Title [ %@ ]", (event.title == nil)? @"<nil>" : event.title);
    NSLog(@"Location [ %@ ]", (event.location == nil)? @"<nil>" : event.location);
    if ([CMIUtility environmentIsAtIOS5OrHigher] == YES) {
        NSLog(@"Notes [ %@ ]", (event.notes == nil)? @"<nil>" : event.notes);
    }    
#endif
}

+ (BOOL)isSameDay:(NSDate*)date1 atDate2:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

+ (NSDate*) dayToDate:(NSString*) day
{
    NSString *dateStrStart = day;//@"20120101";    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];

    return [dateFormat dateFromString:dateStrStart];  	
}

+ (NSString*)formatDateAsDay:(NSDate*)date
{
	static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"EEEE MMMM d"];
	}
    
    NSDate *now = [NSDate date];    
    NSDate* tomorrow = [CMIUtility getOffsetDate:now atOffsetDays:1];
    NSDate* yesterday = [CMIUtility getOffsetDate:now atOffsetDays:-1];
    NSString *dateString;
    
    if ([self isSameDay:now atDate2:date] == true) {
        dateString = @"Today";
    }
    else if ([self isSameDay:tomorrow atDate2:date] == true) {
        dateString = @"Tomorrow";
    } 
    else if ([self isSameDay:yesterday atDate2:date] == true) {
        dateString = @"Yesterday";
    } 
    else {
        dateString = [dateFormatter stringFromDate:date];        
    }
    
    return dateString;
}

+ (NSDate*) getMidnightDate:(NSDate*) date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    
    NSString* dateFormattedMidnight = [dateFormat stringFromDate:date];
    NSDate* eventDay = [dateFormat dateFromString:dateFormattedMidnight];  	
    
    return eventDay;
}


+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending) 
        return NO;
    
    return YES;
}

+ (NSDate*) getOffsetDate:(NSDate*)date atOffsetDays:(NSInteger)offsetDays
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *offset = [[NSDateComponents alloc] init];
    
    [offset setDay:offsetDays];
    NSDate* nextDate = [calendar dateByAddingComponents:offset toDate:date options:0];
    
    return nextDate;
}

+ (NSDate*) getOffsetDateByHours:(NSDate *)date offsetHours:(NSInteger)offsetHours
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *offset = [[NSDateComponents alloc] init];
    
    [offset setHour:offsetHours];
    NSDate* nextDate = [calendar dateByAddingComponents:offset toDate:date options:0];
    
    return nextDate;
}
+ (NSDate*) getOffsetDateByMinutes:(NSDate *)date offsetMinutes:(NSInteger)offsetMinutes
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *offset = [[NSDateComponents alloc] init];
    
    [offset setMinute:offsetMinutes];
    NSDate* nextDate = [calendar dateByAddingComponents:offset toDate:date options:0];
    
    return nextDate;
}

+ (BOOL)createTestEventUK:(EKEventStore*)eventStore startDate:(NSDate*) startDate endDate:(NSDate*)endDate title:(NSString*)title withConfNumber:(BOOL)withConfNumber
{
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    
    event.title = title; 
    
    event.startDate = startDate;
    event.endDate = endDate;// 
    if (withConfNumber == TRUE) {
        event.location = withConfNumber ? @"United Kingdom (toll-free): 0 800 014 8182" : @"nada" ;         
    }
    else {
        event.location = @"nada" ;                 
    }
    
    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
    NSError *err;
    BOOL isSuccess=[eventStore saveEvent:event span:EKSpanThisEvent error:&err];
    
    return isSuccess;
}

+ (BOOL)createTestEvent:(EKEventStore*)eventStore startDate:(NSDate*) startDate endDate:(NSDate*)endDate title:(NSString*)title withConfNumber:(BOOL)withConfNumber
{
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    
    event.title = title; 
    
    event.startDate = startDate;
    event.endDate = endDate;// 
    if (withConfNumber == TRUE) {
        event.location = withConfNumber ? @"1800 123 4567 xx 123456789" : @"nada" ;         
    }
    else {
        event.location = @"nada" ;                 
    }
    
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
    
    NSDate* now = [NSDate date];
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

+ (BOOL)environmentIsAtIOS5OrHigher
{
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    
    NSInteger intOSValue = [osVersion intValue];
    
    return intOSValue >= 5;
}



+ (void)createTestEvents:(EKEventStore*)eventStore
{
    
#if TARGET_IPHONE_SIMULATOR
    // Simulator specific code
    
    [CMIUtility removeAllSimulatorEvents:eventStore];
    // Create some events
    
    NSDate* startDate = [NSDate date];
    NSDate* endDate = [[NSDate alloc] initWithTimeInterval:60*60 sinceDate:startDate];
    NSDate* afterEndDate = [[NSDate alloc] initWithTimeInterval:60*60 sinceDate:endDate];
    NSDate* beforeStartDate = [[NSDate alloc] initWithTimeInterval:-(60*60) sinceDate:startDate];
    NSDate* beforeBeforeStartDate = [[NSDate alloc] initWithTimeInterval:-(2*60*60) sinceDate:beforeStartDate];
    NSDate* tomorrowStartDate = [[NSDate alloc] initWithTimeInterval:(24*60*60) sinceDate:beforeBeforeStartDate];
    NSDate* tomorrowEndDate = [[NSDate alloc] initWithTimeInterval:(60*60) sinceDate:tomorrowStartDate];
    
    [self createTestEvent:eventStore startDate:startDate endDate:endDate title:@"testtitle2" withConfNumber:TRUE];    
    [self createTestEvent:eventStore startDate:endDate endDate:afterEndDate title:@"futureEvent" withConfNumber:TRUE];    
    [self createTestEvent:eventStore startDate:tomorrowStartDate endDate:tomorrowEndDate title:@"tomorrowEvent" withConfNumber:TRUE];    
    [self createTestEventUK:eventStore startDate:tomorrowStartDate endDate:tomorrowEndDate title:@"tomorrowEvent2" withConfNumber:TRUE];    
    [self createTestEvent:eventStore startDate:beforeStartDate endDate:startDate title:@"testtitle1" withConfNumber:TRUE];
    [self createTestEvent:eventStore startDate:beforeStartDate endDate:startDate title:@"NoConfNumEvent1" withConfNumber:FALSE];
    [self createTestEvent:eventStore startDate:beforeBeforeStartDate endDate:beforeStartDate title:@"testtitle0" withConfNumber:TRUE];
    [self createTestEvent:eventStore startDate:beforeBeforeStartDate endDate:beforeStartDate title:@"testtitle00" withConfNumber:TRUE];
    [self createTestEvent:eventStore startDate:beforeBeforeStartDate endDate:beforeStartDate title:@"NoConfNumEvent0" withConfNumber:FALSE];
    [self createTestEvent:eventStore startDate:beforeBeforeStartDate endDate:endDate title:@"testStartEarlyEndFuture" withConfNumber:TRUE];
    
    
#else // TARGET_IPHONE_SIMULATOR
    // Device specific code
#endif // TARGET_IPHONE_SIMULATOR    
    
}

@end
