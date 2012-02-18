//
//  CMIConferencePhoneNumber.m
//  ConferenceMeIn
//
//  Created by philip penn on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIPhone.h"
#import "CMIUtility.h"

NSURL* _phoneURL;

@implementation CMIPhone

@synthesize callProvider;

- (void) setPhoneURL
{
    NSString* phoneNumberURL = nil;
    //memleak?
    _phoneURL = [NSURL URLWithString:phoneNumberURL];
}

- (void) dial:(NSString*) phoneNumber
{
    [CMIUtility Log:@"dial()"];
    
    [self setPhoneURL];

    [[UIApplication sharedApplication] openURL:_phoneURL];            
    
}

- (void) dialWithConfirmation:(NSString*) phoneNumber view:(UIView*)view
{
    [CMIUtility Log:@"dialWithConfirmation()"];

    [self setPhoneURL];

    UIWebView *webview = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame]; 
    [webview loadRequest:[NSURLRequest requestWithURL:_phoneURL]]; 
    webview.hidden = YES; 
    // Assume we are in a view controller and have access to self.view 
    [view addSubview:webview];
    
}


@end
