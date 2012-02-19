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
#import "CMIPhone.h"
@interface CMIEKEventViewController : EKEventViewController
<UIAlertViewDelegate, UIActionSheetDelegate>

//@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) CMIEvent* cmiEvent;
@property (strong, nonatomic) CMIPhone* cmiPhone;

@end
