//
//  CMIEKEventViewController.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIEKEventViewController.h"
#import "ConferenceMeInAppDelegate.h"
#import "CMIUserDefaults.h"

BOOL _loaded = false;

@implementation CMIEKEventViewController

//@synthesize detailItem = _detailItem;
@synthesize cmiEvent = _cmiEvent;
@synthesize cmiPhone = _cmiPhone;


callProviders _callProvider = phoneCarrier;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CMIUserDefaults* cmiUserDefaults = ((ConferenceMeInAppDelegate *)[[UIApplication sharedApplication] delegate]).cmiUserDefaults;
    
    //TODO: this will not refresh if someone changes the defaults while this screen is open
    //Need to register for those events ourselves?
    _callProvider = cmiUserDefaults.callProviderType;
}

- (void)tryToDial
{
    if (_cmiEvent == nil)   return;
        
    if (_cmiEvent.hasConferenceNumber == false) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Phone#" message:@"No Phone number found for event"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        [_cmiPhone dialWithConfirmation:_cmiEvent.conferenceNumber view:self.view];
//        [_cmiEvent dial:self.view confirmCall:true callProvider:_callProvider];        
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    

    // This flag is so we only try to call when coming from master view
    // There may be another way to do this...
    if (_loaded == false) {
        _loaded = true;
        [self tryToDial];
    }
    
}


#pragma mark -
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
        [_cmiPhone dialWithConfirmation:_cmiEvent.conferenceNumber view:self.view];
//        [_cmiEvent dial:self.view confirmCall:true callProvider:_callProvider];        
	}
	else
	{
		NSLog(@"cancel");
	}
}


@end
