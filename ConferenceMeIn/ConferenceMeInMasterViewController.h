//
//  ConferenceMeInMasterViewController.h
//  ConferenceMeIn
//
//  Created by philip penn on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "CMIEvent.h"
#import <EventKitUI/EventKitUI.h>
#import "CMIEKEventViewController.h"
#import "CMIMasterViewController.h"

@class ConferenceMeInDetailViewController;

@interface ConferenceMeInMasterViewController : UITableViewController {
    EKEventStore *eventStore;
	EKCalendar *defaultCalendar;
	NSMutableArray *eventsList;
	UIImageView *_imageView;
}

//@property (strong, nonatomic) ConferenceMeInDetailViewController *detailViewController;
@property (strong, nonatomic) CMIEKEventViewController *detailViewController;

@property (strong, nonatomic) EKEventStore *eventStore;
@property (strong, nonatomic) EKCalendar *defaultCalendar;

@property (strong, nonatomic) NSMutableArray *eventsList;

@property (nonatomic, retain) IBOutlet UIImageView *imageView;



- (void) storeChanged:(NSNotification *) notification;
- (NSArray *) fetchEventsForToday;
- (void)reloadTable;

@end
