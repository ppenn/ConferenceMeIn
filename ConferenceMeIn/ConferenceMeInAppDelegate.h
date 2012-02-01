//
//  ConferenceMeInAppDelegate.h
//  ConferenceMeIn
//
//  Created by philip penn on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef enum calendarTypes
//{
//	allCalendars = 0,
//    defaultCalendarType = 1
//}calendarTypes;

@interface ConferenceMeInAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (nonatomic, assign) NSInteger calendarType;
@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, assign) BOOL firstRun;


@end
