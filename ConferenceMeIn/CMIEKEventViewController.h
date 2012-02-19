//
//  CMIEKEventViewController.h
//  ConferenceMeIn
//
//  Created by philip penn on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "CMIEvent.h"

@interface CMIEKEventViewController : EKEventViewController
<UIAlertViewDelegate, UIActionSheetDelegate, EKEventViewDelegate>

@property (strong, nonatomic) id detailItem;


@end
