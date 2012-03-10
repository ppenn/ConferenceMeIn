//
//  CMIConferencePhoneNumber.h
//  ConferenceMeIn
//
//  Created by philip penn on 2/15/12.
//  Copyright (c) 2012 Paleon Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "CMIMyConferenceNumber.h"

typedef enum callProviders {
    phoneCarrier,
    googleTalkatone,
    skype
}callProviders;

@class CMIMyConferenceNumber;

@interface CMIPhone : NSObject

@property callProviders callProvider;
@property (readonly, strong) NSURL* phoneURL;

- (void) dialConferenceNumber:(CMIMyConferenceNumber*) cmiMyConferenceNumber;
- (void) dialConferenceNumberWithConfirmation:(CMIMyConferenceNumber*) cmiMyConferenceNumber view:(UIView*)view;
- (void) dial:(NSString*) phoneNumber;
- (void) dialWithConfirmation:(NSString*) phoneNumber view:(UIView*)view;
- (id) initWithCallProvider:(callProviders)callProvider;

@end
