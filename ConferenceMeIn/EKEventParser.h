//
//  EKEventParser.h
//  SimpleEKDemo
//
//  Created by philip penn on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
+ (NSString*)stripLeadingZeroOrOne:(NSString*)phoneText;

+ (CMIConferenceNumber*)eventTextToConferenceNumber:(NSString*)eventText;

@end

