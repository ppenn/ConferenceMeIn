//
//  ConferenceMeInAppDelegate.h
//  ConferenceMeIn
//
//  Created by philip penn on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMIEvent.h"
#import "CMIUserDefaults.h"

@interface ConferenceMeInAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic, readonly) CMIUserDefaults* cmiUserDefaults;


@end
