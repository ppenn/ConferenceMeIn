//
//  CMIHelpViewController.h
//  ConferenceMeIn
//
//  Created by philip penn on 2/7/12.
//  Copyright (c) 2012 Paleon Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMIHelpViewController : UIViewController <UITextViewDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *contentTextView;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *cmiImageView;


@end
