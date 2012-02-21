//
//  EKEventParserTests.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EKEventParserTests.h"

@implementation EKEventParserTests

// All code under test must be linked into the Unit Test bundle
- (void)testMath
{
    STAssertTrue((1 + 1) == 2, @"Compiler isn't feeling well today :-(");
}

- (void)testPhoneNumberShouldParse:(NSString*)phoneText
{
    NSString* phoneNumber = [EKEventParser parseEventText:phoneText];
    
    STAssertNotNil(phoneNumber, @"Phone Number shouldn't be nil");
    NSRange range = [phoneNumber rangeOfString:@",," options:NSCaseInsensitiveSearch];
    if(range.location == NSNotFound) {    
        STFail(@"Phone number should contain commas");
    }
    STAssertTrue([phoneNumber length] > 9, @"there needs to be a phone number in there");
}


- (void)testPhoneNumbersShouldParse
{
    NSString* phoneNumber;

    phoneNumber = [EKEventParser parseEventText:@"18776038688 12345678"];
    [self testPhoneNumberShouldParse:phoneNumber];

    phoneNumber = [EKEventParser parseEventText:@"1800 123 4567 xx 12345678"];
    [self testPhoneNumberShouldParse:phoneNumber];
    
    phoneNumber = [EKEventParser parseEventText:@"Conference Room - Aspen / Intercall: 877-603-8688 Partipant Code: 6450391 4155138001"];
    [self testPhoneNumberShouldParse:phoneNumber];
    
    phoneNumber = [EKEventParser parseEventText:@"Content of email below:->>>>  Toll-free dial-in number (U.S. and Canada): (877) 603-8688  Conference code: 6567159  -----Original Appointment-----  From:Angel Anderson [mailto:AAnderson@fcg"];
    [self testPhoneNumberShouldParse:phoneNumber];

    phoneNumber = [EKEventParser parseEventText:@"Body of email                                           When: Wednesday, January 25, 2012 9:30 AM-10:30 AM (GMT-06:00) Central Time (US & Canada).Where: Conference Call 877-603-8688 - Conf Code 1133731826 Note: The GMT offset above does not reflect daylight saving time adjustments."];
    [self testPhoneNumberShouldParse:phoneNumber];
    
    phoneNumber = [EKEventParser parseEventText:@"1-718-354-1168 Participants 25798249#"];
    [self testPhoneNumberShouldParse:phoneNumber];

    // This one is bringing back 5599 as the code. Need to ensure that phone numbers are not included. How?
    phoneNumber = [EKEventParser parseEventText:@"US Dial In:  866-262-0701    International Dial In: 706-679-5599  code 1234"];
    [self testPhoneNumberShouldParse:phoneNumber];
    
}



@end
