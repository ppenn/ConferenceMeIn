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

@interface CMIUserDefaults : NSObject

// Settings app settings
@property (nonatomic, assign) NSInteger calendarType;
@property (nonatomic, assign) callProviders callProviderType;
@property (nonatomic, assign) NSInteger currentTimeframeStarts;
@property (nonatomic, assign) calendarTimeframes calendarTimeframeType;
@property (nonatomic, assign) BOOL highlightCurrentEvents;

@property (nonatomic, assign) NSString* myConfPhoneNumber;
@property (nonatomic, assign) NSString* myConfConfNumber;
@property (nonatomic, assign) NSString* myConfLeaderSeparator;
@property (nonatomic, assign) NSString* myConfLeaderPIN;

// Invisible setting
@property (nonatomic, assign) BOOL firstRun;

// Runtime-only settings
@property (nonatomic, assign) NSInteger filterType;

- (void)loadDefaults;
- (void)saveDefaults;

@end
