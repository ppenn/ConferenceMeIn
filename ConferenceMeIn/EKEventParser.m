

//
//  EKEventParser.m
//  SimpleEKDemo
//
//  Created by philip penn on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EKEventParser.h"


@implementation EKEventParser

+ (NSString*)parseEvent:(EKEvent*)event
{
    return event.location;
}

+ (NSString*)parsePhoneNumber:(NSString*)eventText
{
    NSError *error = NULL;
    NSString* phoneNumber = @"";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d{3}[\\s(\\.]*-?[\\s)\\.]*\\d{3}[\\s\\.]*-?\\s*\\d{4})" 
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    
    NSString *substringForFirstMatch = nil;
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:eventText options:0 range:NSMakeRange(0, [eventText  length])];
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
        substringForFirstMatch = [[[[[[eventText substringWithRange:rangeOfFirstMatch] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        phoneNumber = [phoneNumber stringByAppendingString:substringForFirstMatch];
    }
    
    return phoneNumber;
}

+ (NSString*)stripLeading1:(NSString*)eventText
{
    return @"1";
}

+ (NSString*)parseEventText:(NSString*)eventText
{
    NSError *error = NULL;
    NSString* phoneNumber = @"";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"1?(\\d{3}[\\s(\\.]*-?[\\s)\\.]*\\d{3}[\\s\\.]*-?\\s*\\d{4})" 
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    
    NSString *substringForFirstMatch = nil;
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:eventText options:0 range:NSMakeRange(0, [eventText  length])];
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
        substringForFirstMatch = [[[[[[eventText substringWithRange:rangeOfFirstMatch] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        if ([substringForFirstMatch characterAtIndex:0] == '1') {
            substringForFirstMatch = [substringForFirstMatch substringFromIndex:1];
        }
        
        phoneNumber = [phoneNumber stringByAppendingString:substringForFirstMatch];
        // Get extension, if there is one?
        
        // Get PIN
        NSUInteger afterPhoneNumberPosition = rangeOfFirstMatch.location + rangeOfFirstMatch.length;
        NSString* remainderText = [eventText substringFromIndex:afterPhoneNumberPosition];
        NSRegularExpression *regexPIN = [NSRegularExpression regularExpressionWithPattern:@"\\d{4,12}"                                                                                                                   options:NSRegularExpressionCaseInsensitive                                                                                  error:&error];
        NSRange rangeOfFirstMatchPIN = [regexPIN rangeOfFirstMatchInString:remainderText options:0 range:NSMakeRange(0, [remainderText  length])];
        if (!NSEqualRanges(rangeOfFirstMatchPIN, NSMakeRange(NSNotFound, 0))) {
            NSString* pinNumber = [remainderText substringWithRange:rangeOfFirstMatchPIN];            
            //TODO: Search for another phone#, make sure the PIN isn't part of that #
            NSString* secondPhoneNumber = [EKEventParser parsePhoneNumber:remainderText];
            if ([secondPhoneNumber rangeOfString:pinNumber].location == NSNotFound) {
                phoneNumber = [phoneNumber stringByAppendingString:@",,"];
                phoneNumber = [phoneNumber stringByAppendingString:pinNumber];            
            }
        }
    }    
    
    return phoneNumber;
}



@end
