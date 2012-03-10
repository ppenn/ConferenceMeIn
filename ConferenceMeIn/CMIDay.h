//
//  CMIDay.h
//  ConferenceMeIn
//
//  Created by philip penn on 2/10/12.
//  Copyright (c) 2012 Paleon Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMIDay : NSObject

@property (readonly, nonatomic, strong) NSMutableArray* cmiEvents;
@property (readonly, nonatomic, strong) NSDate* dateAtMidnight;

- (id) initWithDay:(NSDate*)dateAtMidnight;


@end
