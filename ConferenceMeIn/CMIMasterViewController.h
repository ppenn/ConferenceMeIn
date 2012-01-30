//
//  CMIMasterViewController.h
//  ConferenceMeIn
//
//  Created by philip penn on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "CMIEvent.h"
#import <EventKitUI/EventKitUI.h>
#import "CMIEKEventViewController.h"
#import "CMIEventSystem.h"
#import "ConferenceMeInAppDelegate.h"

@interface CMIMasterViewController : UITableViewController

@property (strong, nonatomic) CMIEKEventViewController *detailViewController;
@property (strong, nonatomic) NSMutableArray* eventsList;
@property (strong, nonatomic) CMIEventSystem* cmiEventSystem;

- (void) storeChanged:(NSNotification *) notification;
- (NSArray *)fetchEventsForTable;

- (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier;
- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;
- (void)reloadTable;


@end
