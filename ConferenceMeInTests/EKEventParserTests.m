//
//  EKEventParserTests.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/25/12.
//  Copyright (c) 2012 Paleon Solutions. All rights reserved.
//

#import "EKEventParserTests.h"
#import "CMIUtility.h"

@implementation EKEventParserTests


// All code under test must be linked into the Unit Test bundle
- (void)testMath
{
    STAssertTrue((1 + 1) == 2, @"Compiler isn't feeling well today :-(");
}

- (void)testMaxLines
{
    NSString* badgers = @"participant\n\n\n\n\nbadgers1234";
    
    BOOL shouldExceedMaxLines = [EKEventParser maxNewLinesExceeded:badgers range:NSMakeRange(0, [badgers length])];
    STAssertTrue(shouldExceedMaxLines == YES, @"should exceed");

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
    expectedPhoneNumber = [EKEventParser stripRegex:expectedPhoneNumber regexToStrip:@"\\D"];

    NSString* phoneNumberOnly = [EKEventParser getPhoneFromPhoneNumber:phoneNumber];
    NSString* code = [EKEventParser getCodeFromNumber:phoneNumber];
    if (phoneNumberOnly == nil ||  
        ![expectedPhoneNumber isEqualToString:phoneNumberOnly])  { 
        NSLog(@"stopHere PhoneBadgered");
    }
    STAssertNotNil(phoneNumberOnly, @"Phone shouldn't be nil");

    STAssertTrue([expectedPhoneNumber isEqualToString:phoneNumberOnly], [@"Phone should be equal :" stringByAppendingFormat:@"phoneText[ %@ ] expected#[ %@ ] got [ %@ ]", phoneText, expectedPhoneNumber, phoneNumberOnly]);

    if ((expectedPhoneCode != nil && (code == nil || ![expectedPhoneCode isEqualToString:code]))
        || (expectedPhoneCode == nil && code != nil)) {
          { 
            NSLog(@"stopHere Code Badgered");
        }
        STAssertNotNil(code, @"Code shouldn't be nil");
        STAssertTrue([expectedPhoneCode isEqualToString:code], [@"Codes should be equal :" stringByAppendingFormat:@"phoneText[ %@ ] expected#[ %@ ] got [ %@ ]", phoneText, expectedPhoneCode, code]);
    }
}

- (void)testLeaderCodeShouldParse:(NSString*)phoneText expectedPhoneNumber:(NSString*)expectedPhoneNumber expectedPhoneCode:(NSString*)expectedPhoneCode expectedLeaderSeparator:(NSString*)expectedLeaderSeparator expectedLeaderCode:(NSString*)expectedLeaderCode
{
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:expectedPhoneNumber expectedPhoneCode:expectedPhoneCode];
    
    //NSString* phoneIOSText;
    NSString* leaderSeparator = [EKEventParser getLeaderSeparatorFromNumber:phoneText];
    NSString* leaderCode = [EKEventParser getLeaderCodeFromNumber:phoneText];

    STAssertNotNil(leaderSeparator, @"leaderSeparator shouldn't be nil");
    STAssertNotNil(leaderCode, @"Code shouldn't be nil");
    
    STAssertTrue([leaderSeparator isEqualToString:expectedLeaderSeparator], [@"LeaderSeparator should be equal :" stringByAppendingFormat:@"phoneText[ %@ ] expected#[ %@ ] got [ %@ ]", phoneText, expectedLeaderSeparator, leaderSeparator]);
    STAssertTrue([expectedLeaderCode isEqualToString:leaderCode], [@"Codes should be equal :" stringByAppendingFormat:@"phoneText[ %@ ] expected#[ %@ ] got [ %@ ]", phoneText, expectedLeaderCode, leaderCode]);

}


- (void)testInvitesShouldParse
{
    if (![[CMIUtility getCountryName] isEqualToString:@"United States"]) return;

    NSString* fileContents;
    NSError* error;
    
    NSStringEncoding stringEncoding;
#if TARGET_IPHONE_SIMULATOR
    // Simulator specific code
    stringEncoding = NSASCIIStringEncoding;
#else // TARGET_IPHONE_SIMULATOR
    // Device specific code
    stringEncoding = NSUTF8StringEncoding;
#endif // TARGET_IPHONE_SIMULATOR    
    
    //NB: encoding seems to work differently depending on device vs simulator
    //NSUTF8StringEncoding
    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/att_connect.txt" encoding:stringEncoding error:&error];   
    if (!fileContents) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"18888582144" expectedPhoneCode:@"4259370"];

    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/faux_fax.txt" encoding:stringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"3037796161" expectedPhoneCode:nil];
    
    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/lotuslive.txt" encoding:stringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"18773660711" expectedPhoneCode:@"54466542"];

    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/accuconference.txt" encoding:stringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"18009778002" expectedPhoneCode:@"4681186"];
    
    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/webex.txt" encoding:stringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"18775616828" expectedPhoneCode:@"123456789"];

    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/webex2.txt" encoding:stringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"18776693239" expectedPhoneCode:@"929759712"];

    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/verizon.txt" encoding:stringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"8666924538" expectedPhoneCode:@"8711113"];
    
    
    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/livemeeting.txt" encoding:stringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"18776038688" expectedPhoneCode:@"3123718"];

    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/livemeeting2.txt" encoding:stringEncoding error:&error];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"18776038688" expectedPhoneCode:@"2222683"];

    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/livemeeting3.txt" encoding:stringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"18776038688" expectedPhoneCode:@"2222683"];

    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/livemeeting4.txt" encoding:stringEncoding error:nil];       
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"8776038688" expectedPhoneCode:@"7677379"];
    
    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/livemeeting5.txt" encoding:stringEncoding error:nil];       
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"13128783081" expectedPhoneCode:@"499626030"];
    
    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/code_as_phonenumber.txt" encoding:stringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"8663561046" expectedPhoneCode:@"7528210973"];
    
    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/gotomeeting_1.txt" encoding:stringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"18775684106" expectedPhoneCode:@"575876633"];
    
    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/gotomeeting_4.txt" encoding:stringEncoding error:nil];       
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"18663422541" expectedPhoneCode:@"6738196610"];
    
    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/gotomeeting_3_intl.txt" encoding:stringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"18775684106" expectedPhoneCode:@"655784168"];
    
    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/gotomeeting_2_code_first.txt" encoding:stringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"18663422541" expectedPhoneCode:@"4155367256"];

    fileContents = [NSString stringWithContentsOfFile:@"/Users/ppenn/dev/xcode/ConferenceMeIn/ConferenceMeInTests/test_invites/microsoft.txt" encoding:stringEncoding error:nil];   
    [self testPhoneNumberCodeShouldParse:fileContents expectedPhoneNumber:@"18883203585" expectedPhoneCode:@"35734328"];
    
}

- (void)testPhoneNumbersShouldNotParse
{
    if (![[CMIUtility getCountryName] isEqualToString:@"United States"]) return;

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

- (void)testLeaderNumbersShouldParse
{
    if (![[CMIUtility getCountryName] isEqualToString:@"United States"]) return;

    NSString* phoneText;
    
    phoneText = [EKEventParser parseIOSPhoneText:@"(303)564-3459,123456#*,1234"];
    [self testLeaderCodeShouldParse:phoneText expectedPhoneNumber:@"3035643459" expectedPhoneCode:@"123456" expectedLeaderSeparator:@"#*," expectedLeaderCode:@"1234"];

    phoneText = [EKEventParser parseIOSPhoneText:@"3035643459,,123456,,*,,1234678"];
    [self testLeaderCodeShouldParse:phoneText expectedPhoneNumber:@"3035643459" expectedPhoneCode:@"123456" expectedLeaderSeparator:@",,*,," expectedLeaderCode:@"1234678"];

    phoneText = [EKEventParser parseIOSPhoneText:@"13035643459,,12346 1234678"];
    [self testLeaderCodeShouldParse:phoneText expectedPhoneNumber:@"13035643459" expectedPhoneCode:@"12346" expectedLeaderSeparator:@" " expectedLeaderCode:@"1234678"];

    NSString* phoneNumberOnly;
    NSString* code;
    NSString* leaderSeparator;
    NSString* leaderCode;
    
    
    phoneText = [EKEventParser parseIOSPhoneText:@"13035643459"];
    phoneNumberOnly = [EKEventParser getPhoneFromPhoneNumber:phoneText];
    STAssertTrue([phoneNumberOnly isEqualToString:@"13035643459"], @"phoneNumberOnly should be nil");
    code = [EKEventParser getCodeFromNumber:phoneText];
    STAssertNil(code, @"Code should be nil");

    leaderSeparator = [EKEventParser getLeaderSeparatorFromNumber:phoneText];
    leaderCode = [EKEventParser getLeaderCodeFromNumber:phoneText];
    STAssertNil(leaderSeparator, @"Leader Separator should be nil");
    STAssertNil(leaderCode, @"Leader Code should be nil");

    phoneText = [EKEventParser parseIOSPhoneText:@"3035643459,123456"];
    phoneNumberOnly = [EKEventParser getPhoneFromPhoneNumber:phoneText];
    STAssertTrue([phoneNumberOnly isEqualToString:@"3035643459"], @"Code should be nil");
    code = [EKEventParser getCodeFromNumber:phoneText];
    STAssertTrue([code isEqualToString:@"123456"], @"Code should be same");

    leaderSeparator = [EKEventParser getLeaderSeparatorFromNumber:phoneText];
    leaderCode = [EKEventParser getLeaderCodeFromNumber:phoneText];
    STAssertNil(leaderSeparator, @"Leader Separator should be nil");
    STAssertNil(leaderCode, @"Leader Code should be nil");

    phoneText = [EKEventParser parseIOSPhoneText:@"13035643459,123456#,*"];
    phoneNumberOnly = [EKEventParser getPhoneFromPhoneNumber:phoneText];
    STAssertTrue([phoneNumberOnly isEqualToString:@"13035643459"], @"Code should be nil");
    code = [EKEventParser getCodeFromNumber:phoneText];
    STAssertTrue([code isEqualToString:@"123456"], @"Code should be same");

    leaderSeparator = [EKEventParser getLeaderSeparatorFromNumber:phoneText];
    leaderCode = [EKEventParser getLeaderCodeFromNumber:phoneText];
    STAssertTrue([leaderSeparator isEqualToString:@"#,*"], @"Leader Separator should be =");
    STAssertNil(leaderCode, @"Leader Code should be nil");
                                    
}

- (void)testAustralianPhoneNumbersShouldParse
{
    if ([[CMIUtility getCountryName] isEqualToString:@"Australia"]) {
        NSString* phoneText;

        phoneText = [EKEventParser parseEventText:@"(04) 1234 5678 12345678"];
        [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"(04) 1234 5678" expectedPhoneCode:@"12345678"];
        
        phoneText = [EKEventParser parseEventText:@"Dial-in\
                     MeetingPlace Main Number 425-456-2500\
                     Toll Free Number 1 800 129 278\
                     Meeting ID: 2690\
                     Password: 123456"];
        [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"1 800 129 278" expectedPhoneCode:@"123456"];
        
    }
}

- (void)testUKPhoneNumbersShouldParse
{
    if ([[CMIUtility getCountryName] isEqualToString:@"United Kingdom"]) {
    
//    NSString* test = NSLocalizedString(@"RegexPhoneNumber", nil);
    
    NSString* phoneText;

    phoneText = [EKEventParser parseEventText:@"08776038688 12345678"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"08776038688" expectedPhoneCode:@"12345678"];

    phoneText = [EKEventParser parseEventText:@"Dial-in\
                 MeetingPlace Main Number 425-456-2500\
                 Toll Free Number 0-888-228-0484\
                 Meeting ID: 2690\
                 Password: 123456"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"08882280484" expectedPhoneCode:@"123456"];
    }
}

- (void)testPhoneNumbersShouldParse
{
    if (![[CMIUtility getCountryName] isEqualToString:@"United States"]) return;

    NSString* phoneText;

    phoneText = [EKEventParser parseEventText:@"8776038688"];
    STAssertNotNil([EKEventParser getPhoneFromPhoneNumber:phoneText], @"Phone Text shouldn't be nil");
    STAssertNil([EKEventParser getCodeFromNumber:phoneText], @"Code should be nil");

    phoneText = [EKEventParser parseEventText:@"8776038688 12"];
    STAssertNotNil([EKEventParser getPhoneFromPhoneNumber:phoneText], @"Phone Text shouldn't be nil");
    STAssertNil([EKEventParser getCodeFromNumber:phoneText], @"Code should be nil");    
    
    phoneText = [EKEventParser parseEventText:@"18776038688 12345678"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"18776038688" expectedPhoneCode:@"12345678"];

    phoneText = [EKEventParser parseEventText:@"8776038688 12345678"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"8776038688" expectedPhoneCode:@"12345678"];

    phoneText = [EKEventParser parseEventText:@"18776038688 #12345678"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"18776038688" expectedPhoneCode:@"12345678"];

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
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"18776038688" expectedPhoneCode:@"12345678"];

    phoneText = [EKEventParser parseEventText:@"1800 123 4567 xx 12345678"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"18001234567" expectedPhoneCode:@"12345678"];
    
    phoneText = [EKEventParser parseEventText:@"Conference Room - Aspen / Intercall: 877-603-8688 Partipant Code: 6450391.4155138001"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"8776038688" expectedPhoneCode:@"6450391"];
    
    phoneText = [EKEventParser parseEventText:@"Content of email below:->>>>  Toll-free dial-in number (U.S. and Canada): (877) 603-8688  Conference code: 6567159  -----Original Appointment-----  From:Angel Anderson [mailto:AAnderson@fcg"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"8776038688" expectedPhoneCode:@"6567159"];

    phoneText = [EKEventParser parseEventText:@"Body of email                                           When: Wednesday, January 25, 2012 9:30 AM-10:30 AM (GMT-06:00) Central Time (US & Canada).Where: Conference Call 877-603-8688 - Conf Code 1133731826 Note: The GMT offset above does not reflect daylight saving time adjustments."];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"8776038688" expectedPhoneCode:@"1133731826"];
    
    phoneText = [EKEventParser parseEventText:@"1-718-354-1168 Participants 25798249#"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"17183541168" expectedPhoneCode:@"25798249"];

    // This one is bringing back 5599 as the code. Need to ensure that phone numbers are not included. How?
    phoneText = [EKEventParser parseEventText:@"US Dial In:  866-262-0701    International Dial In: 706-679-5599  code 1234"];
    [self testPhoneNumberCodeShouldParse:phoneText expectedPhoneNumber:@"8662620701" expectedPhoneCode:@"1234"];
    
}



@end
