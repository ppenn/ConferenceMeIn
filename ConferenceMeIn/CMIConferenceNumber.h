//
//  CMIConferenceNumber.h
//  ConferenceMeIn
//
//  Created by philip penn on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMIConferenceNumber : NSObject

@property (strong, nonatomic) NSString* phoneText;

@property (nonatomic,strong) NSString* conferenceNumber;
@property (readonly, nonatomic,strong) NSString* formatted;
@property (nonatomic,strong) NSString* phoneNumber;
@property (nonatomic,strong) NSString* codeSeparator;
@property (nonatomic,strong) NSString* code;
@property (nonatomic,strong) NSString* leaderSeparator;
@property (nonatomic,strong) NSString* leaderCode;

-(id)init;

@end
