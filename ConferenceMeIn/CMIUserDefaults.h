//
//  CMIUserDefaults.h
//  ConferenceMeIn
//
//  Created by philip penn on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMIEvent.h"
#import "CMIEventCalendar.h"
#import "CMIPhone.h"

@interface CMIUserDefaults : NSObject

// Settings app settings
@property NSInteger calendarType;
@property NSInteger currentTimeframeStarts;
@property calendarTimeframes calendarTimeframeType;
@property BOOL highlightCurrentEvents;

@property (nonatomic, strong) NSString* myConfPhoneNumber;
@property (nonatomic, strong) NSString* myConfConfNumber;
@property (nonatomic, strong) NSString* myConfLeaderSeparator;
@property (nonatomic, strong) NSString* myConfLeaderPIN;

// Invisible setting
@property BOOL firstRun;

// Runtime-only settings
@property (nonatomic) NSInteger filterType;

@property callProviders callProviderType;

- (void)loadDefaults;
- (void)saveDefaults;
- (void)save;

- (BOOL)defaultsAreDifferent;
- (BOOL)allDefaultsAreIdentical;

@property BOOL defaultsDidChange;

@end
