//
//  CMIDay.h
//  ConferenceMeIn
//
//  Created by philip penn on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMIDay : NSObject

@property (readonly, nonatomic, strong) NSArray* cmiEvents;
@property (readonly, nonatomic, strong) NSDate* dateAtMidnight;

- (id) initWithCMIEvents:(NSDate*)dateAtMidnight cmiEvents:(NSArray*)cmiEvents;


@end
