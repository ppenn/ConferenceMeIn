//
//  CMIMyConferenceNumber.m
//  ConferenceMeIn
//
//  Created by philip penn on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIMyConferenceNumber.h"
#import "CMIUtility.h"
#import "EKEventParser.h"

@implementation CMIMyConferenceNumber

@synthesize isValid = _isValid;
@synthesize conferenceNumber = _conferenceNumber;
@synthesize leaderInfo = _leaderInfo;
@synthesize cmiUserDefaults = _cmiUserDefaults;
@synthesize conferenceNumberFormatted;
@synthesize fullConferenceNumber;

- (NSString*)fullConferenceNumber
{
    return [_conferenceNumber stringByAppendingString:_leaderInfo];
}

- (NSString*)conferenceNumberFormatted
{
    NSString* retval = nil;
    
    if ([self isValid]) {
        NSString* format = NSLocalizedString(@"ConferenceNumberFormat", @"");
        retval = [NSString stringWithFormat:format,_cmiUserDefaults.myConfPhoneNumber, _cmiUserDefaults.myConfConfNumber];
    }
    
    return retval;
}

- (void) validateConferenceNumber
{
    [CMIUtility Log:@"validateConferenceNumber()"];
    
    // Need to parse all phone number info
    if (_cmiUserDefaults.myConfPhoneNumber != nil && _cmiUserDefaults.myConfConfNumber != nil) {
        _conferenceNumber = [EKEventParser parseEventText:[[_cmiUserDefaults.myConfPhoneNumber stringByAppendingString:@" "] stringByAppendingString:_cmiUserDefaults.myConfConfNumber]];        
    }
    if (_conferenceNumber != nil) {
        _isValid = true;
    }
    else {
        _isValid = false;
    }
    
    // Parse Leader Info
    if (_cmiUserDefaults.myConfLeaderPIN != nil) {
        _leaderInfo = @"";
        if (_cmiUserDefaults.myConfLeaderSeparator != nil && [_cmiUserDefaults.myConfLeaderSeparator length] > 0) {
            _leaderInfo = _cmiUserDefaults.myConfLeaderSeparator;
        }
        _leaderInfo = [_leaderInfo stringByAppendingString:_cmiUserDefaults.myConfLeaderPIN];
    }
}
- (void) setCmiUserDefaults:(CMIUserDefaults *)cmiUserDefaults
{
    [CMIUtility Log:@"setCmiUserDefaults()"];

    _cmiUserDefaults = cmiUserDefaults;
    [self validateConferenceNumber];
}

- (id) initWithUserDefaults:(CMIUserDefaults*)cmiUserDefaults
{
    [CMIUtility Log:@"initWithUserDefaults()"];

    self = [super init];
    
    if (self != nil)
    {
        _cmiUserDefaults = cmiUserDefaults;
        [self validateConferenceNumber];
    }
    return self;
    
}

@end
