//
//  CMIHelpViewController.m
//  ConferenceMeIn
//
//  Created by philip penn on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIHelpViewController.h"

@implementation CMIHelpViewController

@synthesize textView = _textView;


- (void)viewDidLoad {
	self.textView = [[UITextView alloc] initWithFrame:self.view.frame];
	self.textView.textColor = [UIColor blackColor];
	self.textView.font = [UIFont fontWithName:@"Arial" size:18.0];
	self.textView.delegate = self;
	self.textView.backgroundColor = [UIColor whiteColor];
	
	self.textView.text = @"Double-tap to dial a conference associated with a calendar item.\n\nSingle-tap to view the calendar item and be prompted to dial a conference.";
	self.textView.returnKeyType = UIReturnKeyDefault;
	self.textView.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	self.textView.scrollEnabled = YES;
	
	// this will cause automatic vertical resize when the table is resized
	self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	
	// note: for UITextView, if you don't like autocompletion while typing use:
	// myTextView.autocorrectionType = UITextAutocorrectionTypeNo;
	
	[self.view addSubview: self.textView];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
    
}


//- (void)viewDidLoad {
//    NSLog(@"viewDidLoad()");
//    
//	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
//    _textView = [[UITextView alloc] init];// initWithFrame:CGRectMake(0, 0, 320, 480)]; 
//    [self.view addSubview: _textView]; 
//    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;    
//    self.view.autoresizesSubviews = true;
//    
//	self.title = NSLocalizedString(@"HelpViewTitle", @"");
//
//    _textView.text = @"Badgers.\n\nGnadgers.";
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


@end
