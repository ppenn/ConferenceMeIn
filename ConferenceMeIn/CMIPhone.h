//
//  CMIConferencePhoneNumber.h
//  ConferenceMeIn
//
//  Created by philip penn on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum callProviders {
    phoneCarrier,
    google,
    skype
}callProviders;

@interface CMIPhone : NSObject

@property callProviders callProvider;

- (void) dial:(NSString*) phoneNumber;
- (void) dialWithConfirmation:(NSString*) phoneNumber view:(UIView*)view;

@end
