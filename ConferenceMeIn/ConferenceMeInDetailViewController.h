//
//  ConferenceMeInDetailViewController.h
//  ConferenceMeIn
//
//  Created by philip penn on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "EKEventParser.h"
#import "CMIEvent.h"

@interface ConferenceMeInDetailViewController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate>

@property (unsafe_unretained, nonatomic)     NSString* phoneNumber;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *NotesLabel;

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
