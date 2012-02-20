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


- (void)saveDefaults
{
    [CMIUtility Log:@"saveDefaults()"];

    NSNumber *number = [NSNumber numberWithInt:_filterType];
    
    [[NSUserDefaults standardUserDefaults] setObject:number forKey:kFilterTypeKey];    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)loadMyConferenceNumberDefaults:(NSString*) settingsBundlePath
{
    NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"ChildCMINumber.plist"];
    
    NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
    prefSpecifierArray = nil;
    
}


- (void)loadDefaults
{
    [CMIUtility Log:@"loadDefaults()"];

    NSLog(@"NSUserDefaults dump: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    BOOL firstRun = false;
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:kFirstRun] ) {
        //do initialization stuff here...
        firstRun = true;
		// no default values have been set, create them here based on what's in our Settings bundle info
		//
		NSString *pathStr = [[NSBundle mainBundle] bundlePath];
		NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
		NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
        
		NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
		NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];

        NSNumber* calendarTypeDefault = nil;
        NSNumber* callProviderTypeDefault = nil;
        NSNumber* calendarTimeframeDefault = nil;
        NSNumber* currentTimeframeStartsDefault = nil;
//        BOOL highlightCurrentEventsDefault;
        
		NSDictionary *prefItem;
		for (prefItem in prefSpecifierArray)
		{
			NSString *keyValueStr = [prefItem objectForKey:@"Key"];
			id defaultValue = [prefItem objectForKey:@"DefaultValue"];
            NSLog(@"%@",keyValueStr);

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
//			else if ([keyValueStr isEqualToString:kHighlightCurrentEventsKey])
//			{
//				highlightCurrentEventsDefault = [defaultValue boolValue];
//			}
			else if ([keyValueStr isEqualToString:kCalendarTypeKey])
			{
				calendarTypeDefault = defaultValue;
			}
        
        }        
                
		// since no default values have been set (i.e. no preferences file created), create it here		
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kFirstRun];
		[[NSUserDefaults standardUserDefaults] setInteger:filterNone forKey:kFilterTypeKey];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		[[NSUserDefaults standardUserDefaults] setInteger:[callProviderTypeDefault intValue] forKey:kCallProviderTypeKey];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setInteger:googleTalkatone forKey:kCallProviderTypeKey];            
        }
		[[NSUserDefaults standardUserDefaults] setInteger:[calendarTimeframeDefault intValue]  forKey:kCalendarTimeframeTypeKey];
//		[[NSUserDefaults standardUserDefaults] setBool:highlightCurrentEventsDefault forKey:kHighlightCurrentEventsKey];
		[[NSUserDefaults standardUserDefaults] setInteger:[currentTimeframeStartsDefault intValue] forKey:kCurrentTimeframeStartsKey];
		[[NSUserDefaults standardUserDefaults] setInteger:[calendarTypeDefault intValue] forKey:kCalendarTypeKey];
        
        
		[[NSUserDefaults standardUserDefaults] synchronize];
        
        
	}
//    NSLog(@"NSUserDefaults dump: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
	// we're ready to go, so lastly set the key preference values
	self.calendarType = [[NSUserDefaults standardUserDefaults] integerForKey:kCalendarTypeKey];
    
    self.calendarTimeframeType = [[NSUserDefaults standardUserDefaults] integerForKey:kCalendarTimeframeTypeKey];
    self.currentTimeframeStarts = [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentTimeframeStartsKey];
    self.highlightCurrentEvents = (self.currentTimeframeStarts >= 0);
    self.firstRun = firstRun;
    self.filterType = [[NSUserDefaults standardUserDefaults] integerForKey:kFilterTypeKey];
    self.callProviderType = [[NSUserDefaults standardUserDefaults] integerForKey:kCallProviderTypeKey];

    self.myConfPhoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kMyConfPhoneNumberKey];
    self.myConfConfNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kMyConfConfNumberKey];
    self.myConfLeaderSeparator = [[NSUserDefaults standardUserDefaults]objectForKey:kMyConfLeaderSeparatorKey];
    self.myConfLeaderPIN = [[NSUserDefaults standardUserDefaults] objectForKey:kMyConfLeaderPINKey];
    
}


@end
