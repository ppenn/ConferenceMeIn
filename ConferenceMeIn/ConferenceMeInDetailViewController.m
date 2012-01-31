//
//  ConferenceMeInDetailViewController.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConferenceMeInDetailViewController.h"

@interface ConferenceMeInDetailViewController ()
- (void)configureView;
@end

@implementation ConferenceMeInDetailViewController

@synthesize phoneNumber = _phoneNumber;
@synthesize NotesLabel = _NotesLabel;
@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        EKEvent* event = ((CMIEvent*) self.detailItem).ekEvent;
        NSString* eventTitle = event.title;
        self.detailDescriptionLabel.text = eventTitle;
        self.NotesLabel.text = event.notes;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


- (void)openCallAlertDialog
{
    CMIEvent* cmiEvent = (CMIEvent*) self.detailItem;
        
    if (cmiEvent.hasConferenceNumber == false) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Phone#" message:@"No Phone number found for event"
                                          delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        // open a dialog with an OK and cancel button
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Dial Conference #"
                                                                 delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:cmiEvent.conferenceNumber otherButtonTitles:nil];    
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
                
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidUnload
{
    [self setNotesLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.detailItem) {
        [self openCallAlertDialog];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
    if (self.detailItem) {

    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// use "buttonIndex" to decide your action
	//
    NSLog(@"ok");
}


#pragma mark -
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
        [((CMIEvent*) self.detailItem) dial:self.view confirmCall:true];        
	}
	else
	{
		NSLog(@"cancel");
	}
}




@end
