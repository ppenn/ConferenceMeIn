//
//  CMIConferencePhoneNumber.m
//  ConferenceMeIn
//
//  Created by philip penn on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIPhone.h"
#import "CMIUtility.h"
#import "CMIMyConferenceNumber.h"

NSURL* _phoneURL;

@implementation CMIPhone

@synthesize callProvider = _callProvider;

- (void) setPhoneURL:(NSString*) phoneNumber
{
    NSString* phoneNumberURL = nil;
    //memleak?

    //TODO: phone vs other
    switch (_callProvider)
    {
        case phoneCarrier:
            phoneNumberURL = @"tel:";
            phoneNumberURL = [phoneNumberURL stringByAppendingString:phoneNumber];
            break;
        case google:
            phoneNumberURL = @"tktn://call?destination=";            
            phoneNumberURL = [phoneNumberURL stringByAppendingString:phoneNumber];
            phoneNumberURL = [phoneNumberURL stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
            phoneNumberURL = [phoneNumberURL stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
            phoneNumberURL = [phoneNumberURL stringByAppendingString:@"%23"];
            //            telLink = @"tktn://call?destination=18776038688%2C%2C8113067%23";
            break;
        case skype:
            break;
        default:
            break;
    }
    
    _phoneURL = [NSURL URLWithString:phoneNumberURL];
}

- (void) dial:(NSString*) phoneNumber
{
    [CMIUtility Log:@"dial()"];

    [self setPhoneURL:phoneNumber];

    [[UIApplication sharedApplication] openURL:_phoneURL];            
    
}

- (id) initWithCallProvider:(callProviders)callProvider
{
    self = [super init];
    
    if (self != nil)
    {    
        _callProvider = callProvider;
    }
    return self;
    
}
- (void) dialWithConfirmation:(NSString*) phoneNumber view:(UIView*)view
{
    [CMIUtility Log:@"dialWithConfirmation()"];

    [self setPhoneURL:phoneNumber];

    UIWebView *webview = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame]; 
    [webview loadRequest:[NSURLRequest requestWithURL:_phoneURL]]; 
    webview.hidden = YES; 
    // Assume we are in a view controller and have access to self.view 
    [view addSubview:webview];
    
}

- (void) dialConferenceNumber:(CMIMyConferenceNumber*) cmiMyConferenceNumber
{
    [CMIUtility Log:@"dialConferenceNumber()"];
    
    // Only works with talkataone for now
    if (cmiMyConferenceNumber.leaderInfo != nil && _callProvider == google) {
        [self dial:cmiMyConferenceNumber.fullConferenceNumber];
    } 
    else {
        [self dial:cmiMyConferenceNumber.conferenceNumber];
    }
    
}

- (void) dialConferenceNumberWithConfirmation:(CMIMyConferenceNumber*) cmiMyConferenceNumber view:(UIView*)view
{
    [CMIUtility Log:@"dialConferenceNumberWithConfirmation()"];
    
    // Only works with talkataone for now
    if (cmiMyConferenceNumber.leaderInfo != nil && _callProvider == google) {
        [self dialWithConfirmation:cmiMyConferenceNumber.fullConferenceNumber view:view];
    } 
    else {
        [self dialWithConfirmation:cmiMyConferenceNumber.conferenceNumber view:view];
    }
    
}


@end
