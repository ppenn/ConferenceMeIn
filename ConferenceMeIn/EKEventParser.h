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

@interface EKEventParser : NSObject

+ (NSString*)parseEvent:(EKEvent*)event;

+ (NSString*)parseEventText:(NSString*)eventText;
+ (BOOL)phoneNumberContainsCode:(NSString*)phoneNumber;
+ (NSString*)getCodeFromNumber:(NSString*)phoneNumber;
+ (NSString*)getPhoneFromPhoneNumber:(NSString*)phoneNumber;

@end

