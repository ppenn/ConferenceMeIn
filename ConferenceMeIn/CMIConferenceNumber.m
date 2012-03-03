//
//  CMIConferenceNumber.m
//  ConferenceMeIn
//
//  Created by philip penn on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIConferenceNumber.h"
#import "CMIUtility.h"
#import "EKEventParser.h"

#define PHONE_CALL_SEPARATOR @",,"

@implementation CMIConferenceNumber

@synthesize phoneText = _phoneText;
@synthesize phoneNumber = _phoneNumber;
@synthesize code = _code;
@synthesize codeSeparator = _codeSeparator;
@synthesize leaderSeparator = _leaderSeparator;
@synthesize leaderCode = _leaderCode;
@synthesize formatted = _formatted;
@synthesize conferenceNumber = _conferenceNumber;


- (NSString*)conferenceNumber
{
    [CMIUtility Log:@"getConferenceNumber()"];
    
    if (_conferenceNumber == nil && _phoneNumber != nil && _phoneNumber.length > 0) {
        _conferenceNumber = _phoneNumber;
        if (_code != nil) {
            _conferenceNumber = [_conferenceNumber stringByAppendingString:PHONE_CALL_SEPARATOR];
            _conferenceNumber = [_conferenceNumber stringByAppendingString:_code];            
            if (_leaderCode != nil && _leaderCode.length > 0 && _leaderSeparator != nil) {
                _conferenceNumber = [_conferenceNumber stringByAppendingString:_leaderSeparator];
                _conferenceNumber = [_conferenceNumber stringByAppendingString:_leaderCode];                        
            }
        }        
    }
    return _conferenceNumber;
}

- (NSString*)formatted
{
    if (_conferenceNumber != nil && _conferenceNumber.length > 0 &&
        _formatted == nil) {
        NSString* format = NSLocalizedString(@"ConferenceNumberFormat", @"");
        _formatted = [NSString stringWithFormat:format, _phoneNumber, _code];
    }

    return _formatted;
}

-(id)init
{
    [CMIUtility Log:@"init()"];

    self = [super init];
    
    if (self != nil)
    {    
        _conferenceNumber = nil;
        _formatted = nil;
        _leaderCode = nil;
        _leaderSeparator = nil;
    }
    
    return self;
    
}

@end
