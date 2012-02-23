

//
//  EKEventParser.m
//  SimpleEKDemo
//
//  Created by philip penn on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EKEventParser.h"
#import "CMIUtility.h"

#define REGEX_CODE_SPECIFIC @"(password|code)[\\s:\t\\)\\#]*\\d{3,12}[\\s-]?\\d{1,12}+[\\s-]?\\d{0,12}"
#define REGEX_CODE_GENERIC @"\\d{4,12}"

#define REGEX_PHONE_NUMBER_FIRST @"1?(\\d{3}[\\s(\\.]*-?[\\s)\\.]*\\d{3}[\\s\\.]*-?\\s*\\d{4})"
#define REGEX_PHONE_NUMBER_US_TOLLFREE @""

#define PHONE_NUMBER_LENGTH 10

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

+ (NSString*)getPhoneFromPhoneNumber:(NSString*)phoneNumber
{
    return [phoneNumber substringToIndex:PHONE_NUMBER_LENGTH];
}

+ (NSString*)getCodeFromNumber:(NSString*)phoneNumber
{
    [CMIUtility Log:@"getCodeFromNumber()"];

    NSString* code = nil;
    
    if (!([phoneNumber rangeOfString:PHONE_CALL_SEPARATOR].location == NSNotFound)) {
        code = [phoneNumber substringFromIndex:[phoneNumber rangeOfString:PHONE_CALL_SEPARATOR].location + [PHONE_CALL_SEPARATOR length]];
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
        substringForFirstMatch = [[[[[[eventText substringWithRange:rangeOfFirstMatch] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        phoneNumber = [phoneNumber stringByAppendingString:substringForFirstMatch];
    }
    
    return phoneNumber;
}

+ (NSString*)tryToGetCodeSpecific:(NSString*)eventText
{
    [CMIUtility Log:@"tryToGetCodeSpecific()"];
    
    return nil;
}

+ (NSString*)tryToGetPIN:(NSString*)eventText
{
    [CMIUtility Log:@"tryToGetPIN()"];
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

+ (NSString*)parseEventText:(NSString*)eventText
{
    [CMIUtility Log:@"parseEventText()"];
    if (eventText.length < 9)   return nil;

    NSError *error = NULL;
    NSString* phoneNumber = @"";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"1?(\\d{3}[\\s(\\.]*-?[\\s)\\.]*\\d{3}[\\s\\.]*-?\\s*\\d{4})" 
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    
    NSString *substringForFirstMatch = nil;
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:eventText options:0 range:NSMakeRange(0, [eventText  length])];
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
        substringForFirstMatch = [EKEventParser stripRegex:[eventText substringWithRange:rangeOfFirstMatch] regexToStrip:@"[^\\d]"];
//        substringForFirstMatch = [[[[[[eventText substringWithRange:rangeOfFirstMatch] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        if ([substringForFirstMatch characterAtIndex:0] == '1') {
            substringForFirstMatch = [substringForFirstMatch substringFromIndex:1];
        }
        
        phoneNumber = [phoneNumber stringByAppendingString:substringForFirstMatch];
        // Get extension, if there is one?
        
        // Get PIN
        NSUInteger afterPhoneNumberPosition = rangeOfFirstMatch.location + rangeOfFirstMatch.length;
        NSString* remainderText = [eventText substringFromIndex:afterPhoneNumberPosition];
        NSString* PIN = [EKEventParser tryToGetPIN:remainderText];

        if (PIN != nil) {
            phoneNumber = [phoneNumber stringByAppendingString:PHONE_CALL_SEPARATOR];
            phoneNumber = [phoneNumber stringByAppendingString:PIN];            
        }        
    }    
    
    return phoneNumber;
}



@end
