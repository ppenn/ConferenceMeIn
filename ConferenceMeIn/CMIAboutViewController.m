//
//  CMIAboutViewController.m
//  ConferenceMeIn
//
//  Created by philip penn on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIAboutViewController.h"

@implementation CMIAboutViewController

@synthesize imageView = _imageView;


- (void)viewDidLoad 
{
    NSLog(@"viewDidLoad()");
    
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UIImage *background = [UIImage imageNamed: @"About.png"];  
    _imageView = [[UIImageView alloc] initWithImage: background]; 
    [self.view addSubview: _imageView]; 
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;    
    self.view.autoresizesSubviews = true;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
    
}

@end
