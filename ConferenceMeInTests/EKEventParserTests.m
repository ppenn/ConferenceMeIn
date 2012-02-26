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

+ (NSArray*) getFilesInFolder
{
    NSString *dir = @"/foo/bar";
    
    // OS X 10.5+
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
    
    NSEnumerator *enm = [contents objectEnumerator];
    NSString *file;
    while ((file = [enm nextObject]))
        if ([[file pathExtension] isEqualToString:@"mp3"])
            NSLog(@"%@", file);    
    
    return nil;
}

- (void)testPhoneNumberCodeShouldParse:(NSString*)phoneText expectedPhoneNumber:(NSString*)expectedPhoneNumber expectedPhoneCode:(NSString*)expectedPhoneCode
{
    NSString* phoneNumber = [EKEventParser parseEventText:phoneText];
    
    STAssertNotNil(phoneNumber, @"Phone Number shouldn't be nil");

    NSString* phoneNumberOnly = [EKEventParser getPhoneFromPhoneNumber:phoneNumber];
    NSString* code = [EKEventParser getCodeFromNumber:phoneNumber];
    if (phoneNumberOnly == nil || code == nil || 
        ![expectedPhoneNumber isEqualToString:phoneNumberOnly] || ![expectedPhoneCode isEqualToString:code])  { 
        NSLog(@"stopHere");
    }
    STAssertNotNil(phoneNumberOnly, @"Phone shouldn't be nil");
    STAssertNotNil(code, @"Code shouldn't be nil");

    STAssertTrue([expectedPhoneNumber isEqualToString:phoneNumberOnly], [@"Phone should be equal :" stringByAppendingFormat:@"phoneText[ %@ ] expected#[ %@ ] got [ %@ ]", phoneText, expectedPhoneNumber, phoneNumberOnly]);
    STAssertTrue([expectedPhoneCode isEqualToString:code], [@"Codes should be equal :" stringByAppendingFormat:@"phoneText[ %@ ] expected#[ %@ ] got [ %@ ]", phoneText, expectedPhoneCode, code]);
}

- (void)testInvitesShouldParse
{
    NSString* fileContents;
    NSError* error;
    
    //NB: encoding seems to work differently depending on device vs simulator
    //NSUTF8StringEncoding
    
    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/att_connect.txt" encoding:NSASCIIStringEncoding error:&error];   
    if (!fileContents) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"8888582144" expectedPhoneCode:@"4259370"];

    
    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/livemeeting.txt" encoding:NSASCIIStringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"8776038688" expectedPhoneCode:@"3123718"];

    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/livemeeting2.txt" encoding:NSASCIIStringEncoding error:&error];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"8776038688" expectedPhoneCode:@"2222683"];

    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/livemeeting3.txt" encoding:NSASCIIStringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"8776038688" expectedPhoneCode:@"2222683"];

    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/livemeeting4.txt" encoding:NSASCIIStringEncoding error:nil];       
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"8776038688" expectedPhoneCode:@"7677379"];
    
    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/livemeeting5.txt" encoding:NSASCIIStringEncoding error:nil];       
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"3128783081" expectedPhoneCode:@"499626030"];
    
    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/code_as_phonenumber.txt" encoding:NSASCIIStringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"8663561046" expectedPhoneCode:@"7528210973"];
    
    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/gotomeeting_1.txt" encoding:NSASCIIStringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"8775684106" expectedPhoneCode:@"575876633"];
    
    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/gotomeeting_4.txt" encoding:NSASCIIStringEncoding error:nil];       
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"8663422541" expectedPhoneCode:@"6738196610"];
    
    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/gotomeeting_3_intl.txt" encoding:NSASCIIStringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"8775684106" expectedPhoneCode:@"655784168"];
    
    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/gotomeeting_2_code_first.txt" encoding:NSASCIIStringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"8663422541" expectedPhoneCode:@"4155367256"];

    
}

- (void)testPhoneNumbersShouldNotParse
{
    NSString* phoneText;
    
    phoneText = [EKEventParser parseEventText:@"1876038688 12345678"];    
    STAssertTrue(phoneText == nil || [phoneText length] == 0, @"PhoneNumber should be nil");

    phoneText = [EKEventParser parseEventText:@"877a6038688 12345678"];    
    STAssertTrue(phoneText == nil || [phoneText length] == 0, @"PhoneNumber should be nil");

    phoneText = [EKEventParser parseEventText:@"877789"];    
    STAssertTrue(phoneText == nil || [phoneText length] == 0, @"PhoneNumber should be nil");

    phoneText = [EKEventParser parseEventText:@"415513800 1"];    
    STAssertTrue(phoneText == nil || [phoneText length] == 0, @"PhoneNumber should be nil");

    phoneText = [EKEventParser parseEventText:@""];    
    STAssertTrue(phoneText == nil || [phoneText length] == 0, @"PhoneNumber should be nil");

    phoneText = [EKEventParser parseEventText:@" "];    
    STAssertTrue(phoneText == nil || [phoneText length] == 0, @"PhoneNumber should be nil");
    
}

- (void)testPhoneNumbersShouldParse
{
    NSString* phoneText;

    phoneText = [EKEventParser parseEventText:@"8776038688"];
    STAssertNotNil([EKEventParser getPhoneFromPhoneNumber:phoneText], @"Phone Text shouldn't be nil");
    STAssertNil([EKEventParser getCodeFromNumber:phoneText], @"Code should be nil");

    phoneText = [EKEventParser parseEventText:@"8776038688 12"];
    STAssertNotNil([EKEventParser getPhoneFromPhoneNumber:phoneText], @"Phone Text shouldn't be nil");
    STAssertNil([EKEventParser getCodeFromNumber:phoneText], @"Code should be nil");    
    
    phoneText = [EKEventParser parseEventText:@"18776038688 12345678"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"8776038688" expectedPhoneCode:@"12345678"];

    phoneText = [EKEventParser parseEventText:@"8776038688 12345678"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"8776038688" expectedPhoneCode:@"12345678"];

    phoneText = [EKEventParser parseEventText:@"18776038688 #12345678"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"8776038688" expectedPhoneCode:@"12345678"];

    phoneText = [EKEventParser parseEventText:@"Dial-in\
                   MeetingPlace Main Number 425-456-2500\
                   Toll Free Number 888-228-0484\
                   Meeting ID: 2690\
                   Password: 123456"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"8882280484" expectedPhoneCode:@"123456"];

    phoneText = [EKEventParser parseEventText:@"Dial-in\
                 MeetingPlace Main Number 425-456-2500\
                 united states Toll Free Number 888-228-0484\
                 Meeting ID: 2690\
                 Password: 123456"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"8882280484" expectedPhoneCode:@"123456"];

    phoneText = [EKEventParser parseEventText:@"Dial-in\
                 MeetingPlace Main Number 425-456-2500\
                 U.S. Toll Free Number 888-228-0484\
                 Meeting ID: 2690\
                 Password: 123456"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"8882280484" expectedPhoneCode:@"123456"];
    
    
    phoneText = [EKEventParser parseEventText:@"18776038688 12345678 1234"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"8776038688" expectedPhoneCode:@"12345678"];

    phoneText = [EKEventParser parseEventText:@"1800 123 4567 xx 12345678"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"8001234567" expectedPhoneCode:@"12345678"];
    
    phoneText = [EKEventParser parseEventText:@"Conference Room - Aspen / Intercall: 877-603-8688 Partipant Code: 6450391.4155138001"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"8776038688" expectedPhoneCode:@"6450391"];
    
    phoneText = [EKEventParser parseEventText:@"Content of email below:->>>>  Toll-free dial-in number (U.S. and Canada): (877) 603-8688  Conference code: 6567159  -----Original Appointment-----  From:Angel Anderson [mailto:AAnderson@fcg"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"8776038688" expectedPhoneCode:@"6567159"];

    phoneText = [EKEventParser parseEventText:@"Body of email                                           When: Wednesday, January 25, 2012 9:30 AM-10:30 AM (GMT-06:00) Central Time (US & Canada).Where: Conference Call 877-603-8688 - Conf Code 1133731826 Note: The GMT offset above does not reflect daylight saving time adjustments."];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"8776038688" expectedPhoneCode:@"1133731826"];
    
    phoneText = [EKEventParser parseEventText:@"1-718-354-1168 Participants 25798249#"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"7183541168" expectedPhoneCode:@"25798249"];

    // This one is bringing back 5599 as the code. Need to ensure that phone numbers are not included. How?
    phoneText = [EKEventParser parseEventText:@"US Dial In:  866-262-0701    International Dial In: 706-679-5599  code 1234"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"8662620701" expectedPhoneCode:@"1234"];
    
}



@end
