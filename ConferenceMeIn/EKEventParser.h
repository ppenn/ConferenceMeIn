//
//  EKEventParser.h
//  SimpleEKDemo
//
//  Created by philip penn on 1/18/12.
//  Copyright (c) 2012 Paleon Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <Foundation/NSRegularExpression.h>
#import "CMIConferenceNumber.h"

@interface EKEventParser : NSObject

+ (NSString*)parseEvent:(EKEvent*)event;

+ (NSString*)parseEventText:(NSString*)eventText;
+ (BOOL)phoneNumberContainsCode:(NSString*)phoneNumber;
+ (NSString*)getCodeFromNumber:(NSString*)phoneNumber;
+ (NSString*)getPhoneFromPhoneNumber:(NSString*)phoneNumber;
+ (NSString*)getLeaderSeparatorFromNumber:(NSString*)phoneNumber;
+ (NSString*)getLeaderCodeFromNumber:(NSString*)phoneNumber;
+ (NSString*)parseIOSPhoneText:(NSString*)eventText;
+ (BOOL)maxNewLinesExceeded:(NSString*)text range:(NSRange)range;
+ (NSString*)stripRegex:(NSString *)searchTerm regexToStrip:(NSString*)regexToStrip;

+ (CMIConferenceNumber*)eventTextToConferenceNumber:(NSString*)eventText;

@end

