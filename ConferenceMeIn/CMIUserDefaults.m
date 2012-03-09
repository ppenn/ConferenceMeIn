//
//  CMIUserDefaults.m
//  ConferenceMeIn
//
//  Created by philip penn on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIUserDefaults.h"
#import "CMIUtility.h"

NSString *kCalendarTypeKey	= @"calendarTypeKey";
NSString *kCalendarTimeframeTypeKey = @"calendarTimeframeTypeKey";
NSString *kFilterTypeKey = @"filterTypeKey";
NSString *kCallProviderTypeKey = @"callProviderTypeKey";
NSString *kCurrentTimeframeStartsKey = @"currentTimeframeStartsKey";
NSString *kHighlightCurrentEventsKey = @"highlightCurrentEventsKey";
NSString *kMyConfPhoneNumberKey = @"myConfPhoneNumberKey";
NSString *kMyConfConfNumberKey = @"myConfConfNumberKey";
NSString *kMyConfLeaderSeparatorKey = @"myConfLeaderSeparatorKey";
NSString *kMyConfLeaderPINKey = @"myConfLeaderPINKey";
NSString *kFirstRun = @"firstRunKey";
NSString *kShowCompletedEvents = @"showCompletedEventsKey";

@implementation CMIUserDefaults

@synthesize calendarType = _calendarType;
@synthesize calendarTimeframeType = _calendarTimeframeType;
@synthesize firstRun = _firstRun;
@synthesize filterType = _filterType;
@synthesize callProviderType = _callProviderType;
@synthesize currentTimeframeStarts = _currentTimeframeStarts;
@synthesize highlightCurrentEvents = _highlightCurrentEvents;
@synthesize myConfPhoneNumber = _myConfPhoneNumber;
@synthesize myConfConfNumber = _myConfConfNumber;
@synthesize myConfLeaderSeparator = _myConfLeaderSeparator;
@synthesize myConfLeaderPIN = _myConfLeaderPIN;
@synthesize defaultsDidChange = _defaultsDidChange;
@synthesize showCompletedEvents = _showCompletedEvents;

- (void)setFilterType:(NSInteger)filterType
{
    _filterType = filterType;    
}
- (void)setMyConfPhoneNumber:(NSString *)myConfPhoneNumber
{
    [[NSUserDefaults standardUserDefaults] setObject:myConfPhoneNumber forKey:kMyConfPhoneNumberKey];    
}
- (void)setMyConfConfNumber:(NSString *)myConfConfNumber
{
    [[NSUserDefaults standardUserDefaults] setObject:myConfConfNumber forKey:kMyConfConfNumberKey];    
    
}

- (void)setMyConfLeaderSeparator:(NSString *)myConfLeaderSeparator
{
    [[NSUserDefaults standardUserDefaults] setObject:myConfLeaderSeparator forKey:kMyConfLeaderSeparatorKey];    
    
}
- (void)setMyConfLeaderPIN:(NSString *)myConfLeaderPIN
{
    [[NSUserDefaults standardUserDefaults] setObject:myConfLeaderPIN forKey:kMyConfLeaderPINKey];        
}

- (BOOL)defaultsAreDifferent
{
    [CMIUtility Log:@"defaultsHaveChanged()"];

    if(![[NSUserDefaults standardUserDefaults] objectForKey:kFirstRun]) return true;

	if (self.calendarType != [[NSUserDefaults standardUserDefaults] integerForKey:kCalendarTypeKey]) return true;    
	if (self.showCompletedEvents != [[NSUserDefaults standardUserDefaults] boolForKey:kShowCompletedEvents]) return true;    
    if (self.calendarTimeframeType != [[NSUserDefaults standardUserDefaults] integerForKey:kCalendarTimeframeTypeKey]) return true;
    if (self.currentTimeframeStarts != [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentTimeframeStartsKey]) return true;
    if (self.highlightCurrentEvents != (self.currentTimeframeStarts >= 0)) return true;
//    if (self.filterType != [[NSUserDefaults standardUserDefaults] integerForKey:kFilterTypeKey]) return true;
    if (self.callProviderType != [[NSUserDefaults standardUserDefaults] integerForKey:kCallProviderTypeKey]) return true;
    //I don't think we care about the Conf# details...hopefully
    
    return false;
}

- (BOOL)stringValueIsIdenticalToDefaultValue:(NSString*)stringValue stringKey:(NSString*)stringKey
{
    if (stringValue == nil && [[NSUserDefaults standardUserDefaults] objectForKey:stringKey] == nil)
        return YES;
    
    if (stringValue == nil || [[NSUserDefaults standardUserDefaults] objectForKey:stringKey] == nil)
        return NO;
    if ([stringValue isEqualToString:((NSString*) [[NSUserDefaults standardUserDefaults] objectForKey:stringKey])] == NO) 
        return NO;

    return YES;
}

- (BOOL)allDefaultsAreIdentical
{
    [CMIUtility Log:@"defaultsAreIdentical()"];

    if ([self defaultsAreDifferent] == YES)
        return NO;
    
    if ([self stringValueIsIdenticalToDefaultValue:self.myConfPhoneNumber stringKey:kMyConfPhoneNumberKey] == NO)
        return NO;
    if ([self stringValueIsIdenticalToDefaultValue:self.myConfConfNumber stringKey:kMyConfConfNumberKey] == NO)
        return NO;
    if ([self stringValueIsIdenticalToDefaultValue:self.myConfLeaderSeparator stringKey:kMyConfLeaderSeparatorKey] == NO)
        return NO;
    if ([self stringValueIsIdenticalToDefaultValue:self.myConfLeaderPIN stringKey:kMyConfLeaderPINKey] == NO)
        return NO;
    
    return YES;
}

- (void)save
{
    [CMIUtility Log:@"save()"];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveDefaults
{
    [CMIUtility Log:@"saveDefaults()"];

    NSNumber *number = [NSNumber numberWithInt:_filterType];
    
    [[NSUserDefaults standardUserDefaults] setObject:number forKey:kFilterTypeKey];    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)initializeDefaults
{
    [CMIUtility Log:@"initializeDefaults()"];
    
    NSString *pathStr = [[NSBundle mainBundle] bundlePath];
    NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
    NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
    
    NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
    
    NSNumber* calendarTypeDefault = nil;
    NSNumber* callProviderTypeDefault = nil;
    NSNumber* calendarTimeframeDefault = nil;
    NSNumber* currentTimeframeStartsDefault = nil;
    NSString* leaderSeparatorDefault = nil;
    
    NSDictionary *prefItem;
    for (prefItem in prefSpecifierArray)
    {
        NSString *keyValueStr = [prefItem objectForKey:@"Key"];
        id defaultValue = [prefItem objectForKey:@"DefaultValue"];
        
        if ([keyValueStr isEqualToString:kShowCompletedEvents])
        {
//            callProviderTypeDefault = [prefItem boolForKey:@"DefaultValue"];
        }
        else if ([keyValueStr isEqualToString:kCallProviderTypeKey])
        {
            callProviderTypeDefault = defaultValue;
        }
        else if ([keyValueStr isEqualToString:kCalendarTimeframeTypeKey])
        {
            calendarTimeframeDefault = defaultValue;
        }
        else if ([keyValueStr isEqualToString:kCurrentTimeframeStartsKey])
        {
            currentTimeframeStartsDefault = defaultValue;
        }
        else if ([keyValueStr isEqualToString:kCalendarTypeKey])
        {
            calendarTypeDefault = defaultValue;
        }
        else if ([keyValueStr isEqualToString:kMyConfLeaderSeparatorKey])
        {
            leaderSeparatorDefault = defaultValue;
        }
        
    }        
    // since no default values have been set (i.e. no preferences file created), create it here		
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kShowCompletedEvents];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kFirstRun];
    [[NSUserDefaults standardUserDefaults] setInteger:filterNone forKey:kFilterTypeKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kMyConfConfNumberKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kMyConfPhoneNumberKey];
    [[NSUserDefaults standardUserDefaults] setObject:leaderSeparatorDefault forKey:kMyConfLeaderSeparatorKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kMyConfConfNumberKey];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		[[NSUserDefaults standardUserDefaults] setInteger:[callProviderTypeDefault intValue] forKey:kCallProviderTypeKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setInteger:googleTalkatone forKey:kCallProviderTypeKey];            
    }
    [[NSUserDefaults standardUserDefaults] setInteger:[calendarTimeframeDefault intValue]  forKey:kCalendarTimeframeTypeKey];
    [[NSUserDefaults standardUserDefaults] setInteger:[currentTimeframeStartsDefault intValue] forKey:kCurrentTimeframeStartsKey];
    [[NSUserDefaults standardUserDefaults] setInteger:[calendarTypeDefault intValue] forKey:kCalendarTypeKey];
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)loadDefaults
{
    [CMIUtility Log:@"loadDefaults()"];

    NSLog(@"NSUserDefaults dump: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    BOOL firstRun = false;
    _defaultsDidChange = [self defaultsAreDifferent];
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:kFirstRun] ) {
        //do initialization stuff here...
        firstRun = true;
		// no default values have been set, create them here based on what's in our Settings bundle info
        [self initializeDefaults];
	}
//    [CMIUtility Log:@"NSUserDefaults dump: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
    
	// we're ready to go, so lastly set the key preference values
	_calendarType = [[NSUserDefaults standardUserDefaults] integerForKey:kCalendarTypeKey];    
    _calendarTimeframeType = [[NSUserDefaults standardUserDefaults] integerForKey:kCalendarTimeframeTypeKey];
    _currentTimeframeStarts = [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentTimeframeStartsKey];
    _highlightCurrentEvents = (_currentTimeframeStarts >= 0);
    _firstRun = firstRun;
    _showCompletedEvents = [[NSUserDefaults standardUserDefaults] boolForKey:kShowCompletedEvents];
    _filterType = [[NSUserDefaults standardUserDefaults] integerForKey:kFilterTypeKey];
    _callProviderType = [[NSUserDefaults standardUserDefaults] integerForKey:kCallProviderTypeKey];
    _myConfPhoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kMyConfPhoneNumberKey];
    _myConfConfNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kMyConfConfNumberKey];
    _myConfLeaderSeparator = [[NSUserDefaults standardUserDefaults]objectForKey:kMyConfLeaderSeparatorKey];
    _myConfLeaderPIN = [[NSUserDefaults standardUserDefaults] objectForKey:kMyConfLeaderPINKey];
    
}


@end
