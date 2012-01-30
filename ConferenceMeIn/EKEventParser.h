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
// NB will have to return an array of candidates

+ (NSString*)parseEventText:(NSString*)eventText;

@end

