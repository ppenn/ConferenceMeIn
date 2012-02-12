//
//  CMIUserDefaults.h
//  ConferenceMeIn
//
//  Created by philip penn on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMIEvent.h"

@interface CMIUserDefaults : NSObject


@property (nonatomic, assign) NSInteger calendarType;
@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, assign) BOOL firstRun;
@property (nonatomic, assign) NSInteger filterType;
@property (nonatomic, assign) callProviders callProviderType;

- (void)loadDefaults;
- (void)saveDefaults;

@end
