//
//  CMIEvent.h
//  ConferenceMeIn
//
//  Created by philip penn on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

typedef enum callProviders {
    phoneCarrier,
    google,
    skype
}callProviders;

@interface CMIEvent : NSObject


+ (NSMutableArray*)createCMIEvents:(NSArray*)events;

- (id) initWithEKEvent:(EKEvent*)baseEvent;
- (void) parseEvent;
- (void) dial:(UIView*)view confirmCall:(BOOL)confirmCall callProvider:(NSInteger)callProvider;

@property (readonly, nonatomic,strong) EKEvent* ekEvent;
@property (readonly, nonatomic,strong) NSString* conferenceNumber;
@property (readonly, nonatomic) bool hasConferenceNumber;
@property (readonly, nonatomic,strong) NSString* conferenceNumberURL;
@property callProviders callProvider;



@end
