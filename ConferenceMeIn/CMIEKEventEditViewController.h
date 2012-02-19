//
//  CMIEKEventEditViewController.h
//  ConferenceMeIn
//
//  Created by philip penn on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <EventKitUI/EventKitUI.h>
#import "CMIEvent.h"

@interface CMIEKEventEditViewController : EKEventEditViewController <EKEventEditViewDelegate>

@property (nonatomic, strong) CMIEvent* cmiEvent;

@property (nonatomic, strong) NSString* conferenceNumber;

@end
