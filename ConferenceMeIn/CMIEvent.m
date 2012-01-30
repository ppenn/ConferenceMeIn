//
//  CMIEvent.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIEvent.h"
#import "EKEventParser.h"

@implementation CMIEvent

@synthesize ekEvent = _ekEvent;
@synthesize conferenceNumber = _conferenceNumber;

+ (NSMutableArray*)createCMIEvents:(NSArray*)events
{
    NSLog(@"createCMIEvents()");
    
    NSMutableArray* cmiEvents = [[NSMutableArray alloc] initWithCapacity:[events count]];
    
    for(id event in events)
    {
        CMIEvent* cmiEvent = [[CMIEvent alloc] initWithEKEvent:event];
        [cmiEvents addObject:cmiEvent];
    }
    return cmiEvents; 
}

- (id) initWithEKEvent:(EKEvent*)ekEvent
{
    _ekEvent = ekEvent;
    _conferenceNumber = nil;
    
    [self parseEvent];
    
    return self;
}

- (bool) hasConferenceNumber
{
    if (_conferenceNumber != nil && [_conferenceNumber length] > 0)
        return true;
    else
        return false;
}

- (NSString*) conferenceNumberURL
{
    NSString* telLink = @"tel:";
    telLink = [telLink stringByAppendingString:_conferenceNumber];

    return telLink;
}

- (void) parseEvent
{
    if (_ekEvent.title != nil && [_ekEvent.title length] > 0) {
        _conferenceNumber = [EKEventParser parseEventText:_ekEvent.title];        
    }

    if ( (_conferenceNumber == nil || [_conferenceNumber length] == 0) && 
       _ekEvent.location != nil && [_ekEvent.location length] > 0) {
        _conferenceNumber = [EKEventParser parseEventText:_ekEvent.location];        
    }

    if ( (_conferenceNumber == nil || [_conferenceNumber length] == 0) && 
        _ekEvent.notes != nil && [_ekEvent.notes length] > 0) {
        _conferenceNumber = [EKEventParser parseEventText:_ekEvent.notes];        
    }

}

- (void) dial
{
    NSLog(@"Dialling");
    
    [[UIApplication sharedApplication] 
     openURL:[NSURL URLWithString:self.conferenceNumberURL]];    

}

@end
