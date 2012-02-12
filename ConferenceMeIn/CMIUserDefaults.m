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
NSString *kfetch28DaysEventsKey = @"fetch28DaysEventsKey";
NSString *kfilterTypeKey = @"filterTypeKey";
NSString *kcallProviderTypeKey = @"callProviderTypeKey";

@implementation CMIUserDefaults

@synthesize calendarType = _calendarType;
@synthesize debugMode = _debugMode;
@synthesize firstRun = _firstRun;
@synthesize filterType = _filterType;
@synthesize callProviderType = _callProviderType;

- (void)saveDefaults
{
    [CMIUtility Log:@"saveDefaults()"];

    NSNumber *number = [NSNumber numberWithInt:_filterType];
    
    [[NSUserDefaults standardUserDefaults] setObject:number forKey:kfilterTypeKey];    
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
        
		NSNumber *calendarTypeDefault = nil;
		bool fetch28DaysEventsDefault = [[NSUserDefaults standardUserDefaults] boolForKey:kfetch28DaysEventsKey];
        
		NSDictionary *prefItem;
		for (prefItem in prefSpecifierArray)
		{
			NSString *keyValueStr = [prefItem objectForKey:@"Key"];
			id defaultValue = [prefItem objectForKey:@"DefaultValue"];
			
			if ([keyValueStr isEqualToString:kCalendarTypeKey])
			{
				calendarTypeDefault = defaultValue;
			}
		}
        
        NSDate *today = [NSDate date];        
        
		// since no default values have been set (i.e. no preferences file created), create it here		
		NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                     calendarTypeDefault, kCalendarTypeKey,
                                     today, @"firstRun",
                                     nil];
        
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"firstRun"];
		[[NSUserDefaults standardUserDefaults] setValue:0 forKey:kfilterTypeKey];
		[[NSUserDefaults standardUserDefaults] setValue:0 forKey:kcallProviderTypeKey];
		[[NSUserDefaults standardUserDefaults] setBool:fetch28DaysEventsDefault forKey:kfetch28DaysEventsKey];
        
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
    
	// we're ready to go, so lastly set the key preference values
	self.calendarType = [[NSUserDefaults standardUserDefaults] integerForKey:kCalendarTypeKey];
    self.debugMode = [[NSUserDefaults standardUserDefaults] boolForKey:kfetch28DaysEventsKey];
    self.firstRun = firstRun;
    self.filterType = [[NSUserDefaults standardUserDefaults] integerForKey:kfilterTypeKey];
    self.callProviderType = [[NSUserDefaults standardUserDefaults] integerForKey:kcallProviderTypeKey];
}


@end
