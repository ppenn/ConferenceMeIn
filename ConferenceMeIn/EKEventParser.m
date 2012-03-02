

//
//  EKEventParser.m
//  SimpleEKDemo
//
//  Created by philip penn on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EKEventParser.h"
#import "CMIUtility.h"

#define REGEX_CODE_SPECIFIC @"(\\bpin|participant|password|code)[\\s:\\)\\#]*\\d{3,12}[\\s-]?\\d{1,12}+[\\s-]?\\d{0,12}"
#define REGEX_CODE_GENERIC @"\\d{4,12}"
#define REGEX_SEPARATOR @"[^\\d]*"
#define REGEX_CODE_IN_FORMATTED_NUMBER @"(?<=,,)\\d{4,12}"

#define REGEX_PHONE_NUMBER_FIRST @"(?<![\\d\\/])[01]?(\\d{3}[\\s(\\.]*-?[\\s)\\.]*\\d{3}[\\s\\.]*-?\\s*\\d{4})(?!\\w)"

#define REGEX_PHONE_NUMBER_COUNTRY_TOLLFREE @"(u\\.s\\.|usa|united\\ss)[\\D]*[toll(\\-|\\s)?free\\D]*?(?=[18])"
#define REGEX_PHONE_NUMBER_TOLLFREE @"toll(\\-|\\s)?free\\D*(?=[18])"

#define REGEX_LEADER_SEPARATOR_START @"(?<=,,)\\d{4,12}[^\\d]+"
#define REGEX_LEADER_CODE @"(?<=,,)\\d{4,12}[^\\d]+[\\d]{4,12}"

#define PHONE_NUMBER_LENGTH 10
#define MAX_PHONE_NUMBER_LENGTH 11

@implementation EKEventParser

+ (NSString*)parseEvent:(EKEvent*)event
{
    return event.location;
}

+ (BOOL)phoneNumberContainsCode:(NSString*)phoneNumber
{
    if([phoneNumber rangeOfString:PHONE_CALL_SEPARATOR].location == NSNotFound) {
        return false;
    }
    else {
        return true;
    }

}

//NB: Can't get positive-lookbehind working for my regex :(
+ (NSString*)stripRegex:(NSString *)searchTerm regexToStrip:(NSString*)regexToStrip
{
    [CMIUtility Log:@"stripRegex()"];

	// Setup an error to catch stuff in 
	NSError *error = NULL;
	//Create the regular expression to match against
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexToStrip options:NSRegularExpressionCaseInsensitive error:&error];
	// create the new string by replacing the matching of the regex pattern with the template pattern(whitespace)
	NSString *newSearchString = [regex stringByReplacingMatchesInString:searchTerm options:0 range:NSMakeRange(0, [searchTerm length]) withTemplate:@""];	

//	NSLog(@"New string: %@",newSearchString);
	return newSearchString;
}

+ (NSString*)getLeaderSeparatorFromNumber:(NSString*)phoneNumber
{
    [CMIUtility Log:@"getLeaderSeparatorFromNumber()"];
    NSString* separator = nil;
    NSError* error = nil;
    
    NSRegularExpression *regexSeparator = [NSRegularExpression regularExpressionWithPattern:REGEX_LEADER_SEPARATOR_START
                                                                                    options:NSRegularExpressionCaseInsensitive
                                                                                      error:&error];
    
    NSRange range = [regexSeparator rangeOfFirstMatchInString:phoneNumber options:0 range:NSMakeRange(0, [phoneNumber  length])];
    if (range.location != NSNotFound) {
        separator = [EKEventParser stripRegex:[phoneNumber substringWithRange:range] regexToStrip:@"[\\d]"];
    }

    return separator;
}
+ (NSString*)getLeaderCodeFromNumber:(NSString*)phoneNumber
{
    [CMIUtility Log:@"getLeaderCodeFromNumber()"];
    NSString* leaderCode = nil;
    NSError* error = nil;
    
    NSRegularExpression *regexLeader = [NSRegularExpression regularExpressionWithPattern:REGEX_LEADER_SEPARATOR_START
                                                                                    options:NSRegularExpressionCaseInsensitive
                                                                                      error:&error];
    NSRegularExpression *regexCode = [NSRegularExpression regularExpressionWithPattern:REGEX_CODE_GENERIC
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:&error];

    NSRange range = [regexLeader rangeOfFirstMatchInString:phoneNumber options:0 range:NSMakeRange(0, [phoneNumber  length])];
    if (range.location != NSNotFound) {
        NSString* remainderText = [phoneNumber substringFromIndex:range.location];
        
        NSArray* codes = [regexCode matchesInString:remainderText options:0 range:NSMakeRange(0, [remainderText length])];
        
        if (codes != nil && [codes count] == 2) {
            NSTextCheckingResult* codeResult = (NSTextCheckingResult*)[codes objectAtIndex:1]; 
            leaderCode = [remainderText substringWithRange:codeResult.range];    
        }
    }
    
    return leaderCode;
}

+ (NSString*)getPhoneFromPhoneNumber:(NSString*)phoneText
{
    NSString* phoneNumber;

    //UGH 10 vs 11 digit phone#s...
    
    //    if ([phoneText length] >= MAX_PHONE_NUMBER_LENGTH) {
//        phoneNumber = [EKEventParser stripRegex:[phoneText substringToIndex:MAX_PHONE_NUMBER_LENGTH] regexToStrip:@"[^\\d]"];
//    }
//    else {
//        phoneNumber = [phoneNumber substringToIndex:PHONE_NUMBER_LENGTH];
//    } 
    phoneNumber = [[EKEventParser stripLeadingZeroOrOne:phoneText] substringToIndex:PHONE_NUMBER_LENGTH];
    
    return phoneNumber;
}

+ (NSString*)getCodeFromNumber:(NSString*)phoneText
{
    [CMIUtility Log:@"getCodeFromNumber()"];

    NSString* code = nil;
    
	NSError *error = NULL;
	//Create the regular expression to match against
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:REGEX_CODE_IN_FORMATTED_NUMBER options:NSRegularExpressionCaseInsensitive error:&error];

    NSRange range = [regex rangeOfFirstMatchInString:phoneText options:0 range:NSMakeRange(0, [phoneText  length])];
    
    if (range.location != NSNotFound) {
        code = [phoneText substringWithRange:range];
    }
    return code;
}

+ (NSString*)parsePhoneNumber:(NSString*)eventText
{
    [CMIUtility Log:@"parsePhoneNumber()"];
    NSError *error = NULL;
    NSString* phoneNumber = @"";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:REGEX_PHONE_NUMBER_FIRST 
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    
    NSString *substringForFirstMatch = nil;
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:eventText options:0 range:NSMakeRange(0, [eventText  length])];
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
        substringForFirstMatch = [EKEventParser stripRegex:[eventText substringWithRange:rangeOfFirstMatch] regexToStrip:@"[^\\d]"];
        
        phoneNumber = [phoneNumber stringByAppendingString:substringForFirstMatch];
    }
    
    return phoneNumber;
}

+ (NSString*)tryToGetCodeSpecific:(NSString*)eventText
{
    [CMIUtility Log:@"tryToGetCodeSpecific()"];

    NSError *error = NULL;
    NSString* code = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:REGEX_CODE_SPECIFIC
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:eventText options:0 range:NSMakeRange(0, [eventText  length])];
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
        code = [EKEventParser stripRegex:[eventText substringWithRange:rangeOfFirstMatch] regexToStrip:@"[^\\d]"];
    }
        
    return code;
}

+ (NSString*)tryToGetCodeGeneric:(NSString*)eventText
{
    [CMIUtility Log:@"tryToGetCodeGeneric()"];
    if (eventText.length < 4)   return nil;

    NSError *error = NULL;
    NSString* PIN = nil;
    NSRegularExpression *regexPIN = [NSRegularExpression regularExpressionWithPattern:REGEX_CODE_GENERIC                                                                                                                   options:NSRegularExpressionCaseInsensitive                                                                                  error:&error];

    NSArray* possiblePINs = [regexPIN matchesInString:eventText options:0 range:NSMakeRange(0, [eventText length])];

    // for each potential pin, check it's not part of a phone number. return the first.
    for (NSTextCheckingResult* possiblePIN in possiblePINs) 
    {
        
        NSString* pinNumber = [eventText substringWithRange:possiblePIN.range];            
        NSRange substringToCheck;
        if (((NSInteger)(possiblePIN.range.location) - 8) >= 0) {
            substringToCheck.location = possiblePIN.range.location - 8;
            substringToCheck.length = eventText.length - substringToCheck.location;
        
            NSString* secondPhoneNumber = [EKEventParser parsePhoneNumber:[eventText substringWithRange:substringToCheck]];
            if ([secondPhoneNumber rangeOfString:pinNumber].location == NSNotFound) {
                PIN = pinNumber;
                break;
            }
        }
        else {
            PIN = pinNumber;
            break;
        }
    }

    return PIN;
    
}



+ (NSRange)tryToGetFirstPhone:(NSString*)eventText
{
    [CMIUtility Log:@"tryToGetFirstPhone()"];
    
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:REGEX_PHONE_NUMBER_FIRST
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:eventText options:0 range:NSMakeRange(0, [eventText  length])];  
    
    return rangeOfFirstMatch;
}

+ (NSRange)tryToGetFirstTollFree:(NSString*)eventText
{
    [CMIUtility Log:@"tryToGetFirstTollFree()"];
    
    //This regex returns TOLL-FREE numbers...
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:REGEX_PHONE_NUMBER_TOLLFREE                                                                                                                   options:NSRegularExpressionCaseInsensitive                                                                                  error:&error];
    
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:eventText options:0 range:NSMakeRange(0, [eventText  length])];
    
    NSRange range;
    range.location = NSNotFound;
    if (rangeOfFirstMatch.location != NSNotFound) {
        range.location = rangeOfFirstMatch.location + rangeOfFirstMatch.length;
        range.length = eventText.length - range.location;
        
    }
    
    return range;
}

+ (NSRange)tryToGetCountryTollFreePhone:(NSString*)eventText
{
    [CMIUtility Log:@"tryToGetCountryTollFreePhone()"];
    
    //This regex returns US and US TOLL-FREE numbers...
    NSError *error = NULL;
    NSRegularExpression *regexUS = [NSRegularExpression regularExpressionWithPattern:REGEX_PHONE_NUMBER_COUNTRY_TOLLFREE                                                                                                                   options:NSRegularExpressionCaseInsensitive                                                                                  error:&error];
    
    NSArray* possibleUSNumbers = [regexUS matchesInString:eventText options:0 range:NSMakeRange(0, [eventText length])];
    
    
    NSTextCheckingResult* tollFreeNumber = nil;
    // for each potential pin, check it's not part of a phone number. return the first.
    for (NSTextCheckingResult* possibleUSNumber in possibleUSNumbers) 
    {        
        NSString* usSection = [eventText substringWithRange:possibleUSNumber.range];            
        if ([usSection rangeOfString:@"free" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            tollFreeNumber = possibleUSNumber;
        }
    }

    NSRange range;
    range.location = NSNotFound;
    if (tollFreeNumber != nil) {
        [CMIUtility Log:@"Toll-Free :)"];
        range.location = tollFreeNumber.range.location + tollFreeNumber.range.length;
        range.length = eventText.length - range.location;
    }
    else if (possibleUSNumbers.count > 0) {
        [CMIUtility Log:@"Found country-specific #"];
        NSTextCheckingResult* firstNumber = (NSTextCheckingResult*)[possibleUSNumbers objectAtIndex:0];
        range.location = firstNumber.range.location + firstNumber.range.length;
        range.length = eventText.length - range.location;        
    }
    

    return range;
}

+ (NSRange)tryToGetPhone:(NSString*)eventText
{
    [CMIUtility Log:@"tryToGetPhone()"];

    NSRange range = [EKEventParser tryToGetCountryTollFreePhone:eventText];
    if (range.location != NSNotFound) {
        [CMIUtility Log:@"matched CountryTollFree"];
        return range;
    }
    else {
        // Try to Get the first Toll-Free number
        range = [EKEventParser tryToGetFirstTollFree:eventText];
    }
    // If that didn't work then just try the whole thing
    if (range.location == NSNotFound) {
        range = [EKEventParser tryToGetFirstPhone:eventText];
        if (range.location != NSNotFound) {
            [CMIUtility Log:@"matched FirstPhoneNumber"];                    
        }
        else {
            [CMIUtility Log:@"no match"];                                
        }
    }
    else {
        [CMIUtility Log:@"matched FirstTollFree"];        
    }
    
    return range;
    
}

+ (NSString*)stripLeadingZeroOrOne:(NSString*)phoneText
{
    //Remove leading 0 or 1...this should be safe to do, the regex should ensure we have a real phone # after it (i.e. 10 digits)
    if ([phoneText characterAtIndex:0] == '1' ||
        [phoneText characterAtIndex:0] == '0') {
        phoneText = [phoneText substringFromIndex:1];
    }
    
    return phoneText;
}

+ (NSString*)parseEventText:(NSString*)eventText
{
    [CMIUtility Log:@"parseEventText()"];
    if (eventText.length < 10)   return nil;

    NSString* phoneNumber = @"";

    // 2-phase pass, first of all find 
    NSRange rangeOfFirstMatch = [EKEventParser tryToGetPhone:eventText];
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
        NSString* firstSubstring = [eventText substringWithRange:rangeOfFirstMatch];
        NSRange rangeOfSecondMatch = [EKEventParser tryToGetFirstPhone:firstSubstring];
        if (rangeOfSecondMatch.location != NSNotFound) {
            NSString *substringForSecondMatch = [EKEventParser stripRegex:[firstSubstring substringWithRange:rangeOfSecondMatch] regexToStrip:@"[^\\d]"];
            
            substringForSecondMatch = [EKEventParser stripLeadingZeroOrOne:substringForSecondMatch];
            
            phoneNumber = [phoneNumber stringByAppendingString:substringForSecondMatch];
            
            // Get PIN / Code. Try a couple of ways...
            NSUInteger afterPhoneNumberPosition = rangeOfFirstMatch.location + rangeOfSecondMatch.location + rangeOfSecondMatch.length;
            NSString* remainderText = [eventText substringFromIndex:afterPhoneNumberPosition];
            NSString* code;
            code = [EKEventParser tryToGetCodeSpecific:eventText];
            if (code == nil) {
                code = [EKEventParser tryToGetCodeGeneric:remainderText];
            }
            if (code != nil) {
                phoneNumber = [phoneNumber stringByAppendingString:PHONE_CALL_SEPARATOR];
                phoneNumber = [phoneNumber stringByAppendingString:code];            
            }        
        }
    }    

    //TODO: fix this 
    if ([phoneNumber length] > 1 &&
        ([phoneNumber characterAtIndex:0] == '1' || [[EKEventParser getPhoneFromPhoneNumber:phoneNumber]  rangeOfString:@","].location != NSNotFound)) {
        phoneNumber = @"";
    }
    
    return phoneNumber;
}

+ (NSString*)parseIOSPhoneText:(NSString*)eventText
{
    [CMIUtility Log:@"parseIOSPhoneText()"];
    if (eventText.length < 10)   return nil;

    NSError *error = NULL;
    NSRegularExpression *regexCode = [NSRegularExpression regularExpressionWithPattern:REGEX_CODE_GENERIC 
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSRegularExpression *regexSeparator = [NSRegularExpression regularExpressionWithPattern:REGEX_SEPARATOR 
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        
    NSString* phoneNumber = nil;
    NSRange range = [EKEventParser tryToGetFirstPhone:eventText];
    if (range.location != NSNotFound) {
        phoneNumber = [eventText substringWithRange:range];        
        phoneNumber = [EKEventParser stripRegex:phoneNumber regexToStrip:@"[^\\d]"];        
        
        NSRange rangeOfCode = [regexCode rangeOfFirstMatchInString:eventText options:0 range:NSMakeRange(range.location + range.length, [eventText  length]-(range.location + range.length))];
        if (rangeOfCode.location != NSNotFound) {
            phoneNumber = [phoneNumber stringByAppendingString:PHONE_CALL_SEPARATOR];
            phoneNumber = [phoneNumber stringByAppendingString:[eventText substringWithRange:rangeOfCode]];            
            
            NSRange rangeOfSeparator = [regexSeparator rangeOfFirstMatchInString:eventText options:0 range:NSMakeRange(rangeOfCode.location + rangeOfCode.length, [eventText  length] - (rangeOfCode.location + rangeOfCode.length))];
            if (rangeOfSeparator.location != NSNotFound) {
                phoneNumber = [phoneNumber stringByAppendingString:[eventText substringWithRange:rangeOfSeparator]];            

                NSRange rangeOfLeader = [regexCode rangeOfFirstMatchInString:eventText options:0 range:NSMakeRange(rangeOfSeparator.location + rangeOfSeparator.length, [eventText  length] - (rangeOfSeparator.location + rangeOfSeparator.length))];
                if (rangeOfLeader.location != NSNotFound) {
                    phoneNumber = [phoneNumber stringByAppendingString:[eventText substringWithRange:rangeOfLeader]];            
                }

            }
            
        }
    }    
    return phoneNumber;
    
}

@end
