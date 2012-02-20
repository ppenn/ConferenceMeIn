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
#import "CMIUtility.h"

#define ALERT_NO_NUMBER_FOUND 1
#define ALERT_ENTER_CONF_DETAILS 0

BOOL _supportsNotes = false;

@implementation CMIEKEventViewController

@synthesize cmiEvent = _cmiEvent;
@synthesize cmiPhone = _cmiPhone;
@synthesize eventStore = _eventStore;
@synthesize hasDisplayedPopup = _hasDisplayedPopup;

callProviders _callProvider = phoneCarrier;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CMIUserDefaults* cmiUserDefaults = ((ConferenceMeInAppDelegate *)[[UIApplication sharedApplication] delegate]).cmiUserDefaults;
    
    //TODO: this will not refresh if someone changes the defaults while this screen is open
    //Need to register for those events ourselves?
    _callProvider = cmiUserDefaults.callProviderType;
}

- (void)showEnterConferenceDetailsAlert
{
    [CMIUtility Log:@"showEnterConferenceDetailsAlert()"];
    
    if (_supportsNotes == YES) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Conference # Details" message:@"Enter Conference # Details:" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField * alertTextField = [alert textFieldAtIndex:0];
        alertTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;// UIKeyboardTypeDefault;// UIKeyboardTypePhonePad;// UIKeyboardTypeNumberPad;
        alertTextField.placeholder = @"Conf Details #";
        alert.tag = ALERT_ENTER_CONF_DETAILS;
        [alert show];                
    }
}

- (BOOL)environmentIsAtIOS5OrHigher
{
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    
    NSInteger intOSValue = [osVersion intValue];
    
    return intOSValue >= 5;
}

- (void)tryToDial
{
    if (_cmiEvent == nil)   return;
        
    if (_cmiEvent.hasConferenceNumber == false) {
        
        UIAlertView* alert;
        
//        if ([EKEvent instancesRespondToSelector:@selector(notes:)]) {
        if ([self environmentIsAtIOS5OrHigher] == YES) {
        _supportsNotes = YES;
        alert = [[UIAlertView alloc] initWithTitle:@"No Phone#" message:@"No Phone number found for event\n\rWould you like to add one?"
                                          delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Add Number",nil];
        }
        else {
            alert = [[UIAlertView alloc] initWithTitle:@"No Phone#" message:@"No Phone number found for event" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];            
        }
        alert.tag = ALERT_NO_NUMBER_FOUND;
        [alert show];
    }
    else
    {
        [_cmiPhone dialWithConfirmation:_cmiEvent.conferenceNumber view:self.view];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    

    // This flag is so we only try to call when coming from master view
    // There may be another way to do this...
    @try {
        [CMIUtility Log:@"viewDidAppear:animated()"];
        
        if (_hasDisplayedPopup == false) {
            _hasDisplayedPopup = true;
            [self tryToDial];
        }
    }
    @catch (NSException* e) {
        [CMIUtility LogError:e.reason];
    }
    
}

- (void)saveNotes:(NSString*)conferenceDetails
{
    [CMIUtility Log:@"saveNotes()"];
    
    NSError *error = nil;
    if (conferenceDetails != nil && conferenceDetails.length > 0) {
        NSString* notes = @"";
        if (_cmiEvent.ekEvent.hasNotes == YES) {
            notes = _cmiEvent.ekEvent.notes;
            notes = [notes stringByAppendingString:@"\n\r"];
            notes = [notes stringByAppendingString:@"\n\r"];
            notes = [notes stringByAppendingString:conferenceDetails];
        }
        else {
            notes = conferenceDetails;
        }
        _cmiEvent.ekEvent.notes = notes;
        [_eventStore saveEvent:_cmiEvent.ekEvent span:EKSpanThisEvent error:&error];        
    }            
}

#pragma mark -
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{ 
    [CMIUtility Log:@"alertView:clickedButtonAtIndex()"];
    
    @try {
        if (alertView.tag == ALERT_NO_NUMBER_FOUND && _supportsNotes == YES &&
            buttonIndex == 1) {
            [self showEnterConferenceDetailsAlert];
        }
        else if (alertView.tag == ALERT_ENTER_CONF_DETAILS && buttonIndex == 0) {
            [self saveNotes:[[alertView textFieldAtIndex:0] text]];
        }
    }
    @catch (NSException *e) {
        [CMIUtility LogError:e.reason];
    }
}

@end
