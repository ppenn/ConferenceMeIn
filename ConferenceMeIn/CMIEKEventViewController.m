//
//  CMIEKEventViewController.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIEKEventViewController.h"
#import "ConferenceMeInAppDelegate.h"

@implementation CMIEKEventViewController

@synthesize detailItem = _detailItem;

callProviders _callProvider = phoneCarrier;

- (void)viewDidLoad
{
    ConferenceMeInAppDelegate *appDelegate = (ConferenceMeInAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _callProvider = appDelegate.callProviderType;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
    if ([self detailItem] == nil)   return;

    CMIEvent* cmiEvent = (CMIEvent*) self.detailItem;
    
    if (cmiEvent.hasConferenceNumber == false) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Phone#" message:@"No Phone number found for event"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        [((CMIEvent*) self.detailItem) dial:self.view confirmCall:true callProvider:_callProvider];        

//        // open a dialog with an OK and cancel button
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Dial Conference #"
//                                                                 delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:cmiEvent.conferenceNumber otherButtonTitles:nil];    
//        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
//        [actionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
        
    }
    
}


#pragma mark -
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
        [((CMIEvent*) self.detailItem) dial:self.view confirmCall:true callProvider:_callProvider];        
	}
	else
	{
		NSLog(@"cancel");
	}
}


@end
