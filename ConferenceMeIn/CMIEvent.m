//
//  CMIEvent.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIEvent.h"
#import "EKEventParser.h"
#import "CMIUtility.h"

#define EVENT_CONTENT_SEPARATOR @"   "

@implementation CMIEvent

@synthesize ekEvent = _ekEvent;
@synthesize conferenceNumber = _conferenceNumber;
@synthesize callProvider = _callProvider;
@synthesize cmiConferenceNumber = _cmiConferenceNumber;

+ (NSMutableArray*)createCMIEvents:(NSArray*)events
{
    [CMIUtility Log:@"createCMIEvents()"];
    
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
    [CMIUtility Log:@"initWithEKEvent()"];

    self = [super init];
    
    if (self != nil)
    {    
        _ekEvent = ekEvent;
        _conferenceNumber = nil;

        [self parseEvent];
    }
    return self;
}

- (NSString*)conferenceNumber
{
    if (_conferenceNumber == nil && _cmiConferenceNumber != nil) {
        _conferenceNumber = _cmiConferenceNumber.conferenceNumber;
    }
    return _conferenceNumber;
}

- (bool) hasConferenceNumber
{
    if (self.conferenceNumber != nil && [self.conferenceNumber length] > 0)
        return true;
    else
        return false;
}

- (void) parseEvent
{
    [CMIUtility Log:@"parseEvent()"];
    [CMIUtility LogEvent:_ekEvent];

    NSString* eventContent = @"";
    
//    if ([_ekEvent.title isEqualToString:@"testtitle2"]) {
//        int stophere = 0;
//    }
    
    if (_ekEvent.title != nil && [_ekEvent.title length] > 0) {
//        _cmiConferenceNumber = [EKEventParser eventTextToConferenceNumber:_ekEvent.title];
        eventContent = [eventContent stringByAppendingString:_ekEvent.title];
    }

    if ( _ekEvent.location != nil && [_ekEvent.location length] > 0) {
//        _cmiConferenceNumber = [EKEventParser eventTextToConferenceNumber:_ekEvent.location];
        eventContent = [[eventContent stringByAppendingString:EVENT_CONTENT_SEPARATOR] stringByAppendingString:_ekEvent.location];
    }

    if ( _ekEvent.hasNotes == YES && [_ekEvent.notes length] > 0 ) {
//        _cmiConferenceNumber = [EKEventParser eventTextToConferenceNumber:_ekEvent.notes];
        eventContent = [[eventContent stringByAppendingString:EVENT_CONTENT_SEPARATOR] stringByAppendingString:_ekEvent.notes];
    }
    
    _cmiConferenceNumber = [EKEventParser eventTextToConferenceNumber:eventContent];

    if (self.conferenceNumber != nil && [self.conferenceNumber length] > 0) {
        [CMIUtility Log:[NSString stringWithFormat:@"Found Number [ %@ ]", self.conferenceNumber]];        
    }

}


@end
