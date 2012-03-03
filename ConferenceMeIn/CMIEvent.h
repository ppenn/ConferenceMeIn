//
//  CMIEvent.h
//  ConferenceMeIn
//
//  Created by philip penn on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "CMIPhone.h"
#import "CMIConferenceNumber.h"

@interface CMIEvent : NSObject


+ (NSMutableArray*)createCMIEvents:(NSArray*)events;

- (id) initWithEKEvent:(EKEvent*)baseEvent;
- (void) parseEvent;

@property (readonly, nonatomic,strong) EKEvent* ekEvent;
@property (readonly, nonatomic,strong) NSString* conferenceNumber;
@property (readonly, nonatomic) bool hasConferenceNumber;
@property callProviders callProvider;
@property (readonly, nonatomic,strong) CMIConferenceNumber* cmiConferenceNumber;



@end
