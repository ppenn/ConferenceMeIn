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

@implementation CMIUserDefaults

@synthesize calendarType = _calendarType;
@synthesize calendarTimeframeType = _calendarTimeframeType;
@synthesize firstRun = _firstRun;
@synthesize filterType = _filterType;
@synthesize callProviderType = _callProviderType;
@synthesize currentTimeframeStarts = _currentTimeframeStarts;
@synthesize highlightCurrentEvents = _highlightCurrentEvents;

- (void)saveDefaults
{
    [CMIUtility Log:@"saveDefaults()"];

    NSNumber *number = [NSNumber numberWithInt:_filterType];
    
    [[NSUserDefaults standardUserDefaults] setObject:number forKey:kFilterTypeKey];    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)loadDefaults
{
    [CMIUtility Log:@"loadDefaults()"];

    NSLog(@"NSUserDefaults dump: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    BOOL firstRun = false;
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"firstRun"] ) {
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
        BOOL highlightCurrentEventsDefault;
        
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
			else if ([keyValueStr isEqualToString:kHighlightCurrentEventsKey])
			{
				highlightCurrentEventsDefault = [defaultValue boolValue];
			}
			else if ([keyValueStr isEqualToString:kCalendarTypeKey])
			{
				calendarTypeDefault = defaultValue;
			}
        
        }        
                
		// since no default values have been set (i.e. no preferences file created), create it here		
//		NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
//                                     kCalendarTimeframeTypeKey, kCalendarTypeKey,
//                                     today, @"firstRun",
//                                     nil];
//        
//		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"firstRun"];
		[[NSUserDefaults standardUserDefaults] setInteger:filterNone forKey:kFilterTypeKey];
		[[NSUserDefaults standardUserDefaults] setInteger:[callProviderTypeDefault intValue] forKey:kCallProviderTypeKey];
		[[NSUserDefaults standardUserDefaults] setInteger:[calendarTimeframeDefault intValue]  forKey:kCalendarTimeframeTypeKey];
		[[NSUserDefaults standardUserDefaults] setBool:highlightCurrentEventsDefault forKey:kHighlightCurrentEventsKey];
		[[NSUserDefaults standardUserDefaults] setInteger:[currentTimeframeStartsDefault intValue] forKey:kCurrentTimeframeStartsKey];
		[[NSUserDefaults standardUserDefaults] setInteger:[calendarTypeDefault intValue] forKey:kCalendarTypeKey];
        
		[[NSUserDefaults standardUserDefaults] synchronize];
        
        
	}
    NSLog(@"NSUserDefaults dump: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
	// we're ready to go, so lastly set the key preference values
	self.calendarType = [[NSUserDefaults standardUserDefaults] integerForKey:kCalendarTypeKey];
    
    self.calendarTimeframeType = [[NSUserDefaults standardUserDefaults] integerForKey:kCalendarTimeframeTypeKey];
    self.currentTimeframeStarts = [[NSUserDefaults standardUserDefaults] integerForKey:kCurrentTimeframeStartsKey];
    self.highlightCurrentEvents = [[NSUserDefaults standardUserDefaults] boolForKey:kHighlightCurrentEventsKey];
    self.firstRun = firstRun;
    self.filterType = [[NSUserDefaults standardUserDefaults] integerForKey:kFilterTypeKey];
    self.callProviderType = [[NSUserDefaults standardUserDefaults] integerForKey:kCallProviderTypeKey];
    
}


@end
