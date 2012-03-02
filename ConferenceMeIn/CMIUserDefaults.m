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
    if (self.calendarTimeframeType != [[NSUserDefaults standardUserDefaults] integerForKey:kCalendarTimeframeTypeKey]) return true;
    if (self.currentTimeframeStarts != [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentTimeframeStartsKey]) return true;
    if (self.highlightCurrentEvents != (self.currentTimeframeStarts >= 0)) return true;
    if (self.filterType != [[NSUserDefaults standardUserDefaults] integerForKey:kFilterTypeKey]) return true;
    if (self.callProviderType != [[NSUserDefaults standardUserDefaults] integerForKey:kCallProviderTypeKey]) return true;
    //I don't think we care about the Conf# details...hopefully
//    if (![self.myConfPhoneNumber isEqualToString:((NSString*) [[NSUserDefaults standardUserDefaults] objectForKey:kMyConfPhoneNumberKey])]) 
//          return true;
//    if (![self.myConfConfNumber isEqualToString:((NSString*) [[NSUserDefaults standardUserDefaults] objectForKey:kMyConfConfNumberKey])]) 
//        return true;
//    if (![self.myConfLeaderSeparator isEqualToString:((NSString*) [[NSUserDefaults standardUserDefaults] objectForKey:kMyConfLeaderSeparatorKey])]) 
//        return true;
//    if (![self.myConfLeaderPIN isEqualToString:((NSString*) [[NSUserDefaults standardUserDefaults] objectForKey:kMyConfLeaderPINKey])]) 
//        return true;
    
    return false;
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
        
        if ([keyValueStr isEqualToString:kCallProviderTypeKey])
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
    _filterType = [[NSUserDefaults standardUserDefaults] integerForKey:kFilterTypeKey];
    _callProviderType = [[NSUserDefaults standardUserDefaults] integerForKey:kCallProviderTypeKey];
    _myConfPhoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kMyConfPhoneNumberKey];
    _myConfConfNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kMyConfConfNumberKey];
    _myConfLeaderSeparator = [[NSUserDefaults standardUserDefaults]objectForKey:kMyConfLeaderSeparatorKey];
    _myConfLeaderPIN = [[NSUserDefaults standardUserDefaults] objectForKey:kMyConfLeaderPINKey];
    
}


@end
