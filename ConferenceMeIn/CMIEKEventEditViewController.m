//
//  CMIEKEventEditViewController.m
//  ConferenceMeIn
//
//  Created by philip penn on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIEKEventEditViewController.h"


@implementation CMIEKEventEditViewController

@synthesize cmiEvent = _cmiEvent;
@synthesize conferenceNumber = _conferenceNumber;

- (void) setConferenceNumber:(NSString *)conferenceNumber
{
    self.event.location = _conferenceNumber;    
}

- (void) viewDidLoad
{
}

- (void) eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    NSError *error = nil;
    EKEvent *thisEvent = controller.event;
    
    switch (action) {
        case EKEventEditViewActionCanceled:
            // Edit action canceled, do nothing. 
            break;
            
        case EKEventEditViewActionSaved:
            // When user hit "Done" button, save the newly created event to the event store, 
            // and reload table view.
            // If the new event is being added to the default calendar, then update its 
            // eventsList.
            break;
            
        case EKEventEditViewActionDeleted:
            // When deleting an event, remove the event from the event store, 
            // and reload table view.
            // If deleting an event from the currenly default calendar, then update its 
            // eventsList.
            break;
            
        default:
            break;
    }    
    // Dismiss the modal view controller
    [controller dismissModalViewControllerAnimated:YES];
}

- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller
{
    return [self.eventStore defaultCalendarForNewEvents];
}

@end
