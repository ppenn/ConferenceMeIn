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
@synthesize callProvider = _callProvider;


//UIPasteboard *pasteboard;

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
//    telLink = @"tktn://call?destination=";
//    telLink = @"skype:";  
    
//    telLink = [telLink stringByAppendingString:@"18776038688%2C%2C8113067"];
//    telLink = [telLink stringByAppendingString:@"%23"];

//    pasteboard = [UIPasteboard generalPasteboard];    
//    pasteboard.string = @"8113067";
//    return @"skype:18776038688?call";//&skype:8113067?call";//&token=8113067";

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

- (void) dial:(UIView*)view confirmCall:(BOOL)confirmCall
{
    NSLog(@"Dialling");

    if (confirmCall == false) {
        [[UIApplication sharedApplication] 
         openURL:[NSURL URLWithString:self.conferenceNumberURL]];            
    }
    else
    {
        UIWebView *webview = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame]; 
        NSURL *telURL = [NSURL URLWithString:self.conferenceNumberURL];
        [webview loadRequest:[NSURLRequest requestWithURL:telURL]]; 
        webview.hidden = YES; 
        // Assume we are in a view controller and have access to self.view 
        [view addSubview:webview];
    }


    
}

@end
