//
//  CMIHelpViewController.m
//  ConferenceMeIn
//
//  Created by philip penn on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIHelpViewController.h"

@implementation CMIHelpViewController

@synthesize contentTextView = _contentTextView;
@synthesize cmiImageView = _cmiImageView;

- (void)setupHelp
{
    
}

- (void)viewDidLoad {
	[super viewDidLoad];

    self.navigationController.toolbarHidden = YES;
	self.title = NSLocalizedString(@"HelpViewTitle", @"");

    self.contentTextView.text = NSLocalizedString(@"HelpMessage", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self setupHelp];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void)viewDidUnload {
    [self setContentTextView:nil];
    [self setCmiImageView:nil];
    [super viewDidUnload];
}
@end
