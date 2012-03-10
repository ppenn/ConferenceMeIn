//
//  CMIEKEventViewController.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/25/12.
//  Copyright (c) 2012 Paleon Solutions. All rights reserved.
//

#import "CMIEKEventViewController.h"
#import "ConferenceMeInAppDelegate.h"
#import "CMIUserDefaults.h"
#import "CMIUtility.h"

#define ALERT_ENTER_CONF_DETAILS 0
#define ALERT_NO_NUMBER_FOUND 1
#define ALERT_CONFIRM_DIAL 2

BOOL _supportsNotes = false;
NSTimer* myTimer;

@implementation CMIEKEventViewController

@synthesize cmiEvent = _cmiEvent;
@synthesize cmiPhone = _cmiPhone;
@synthesize eventStore = _eventStore;
@synthesize hasDisplayedPopup = _hasDisplayedPopup;
@synthesize megaAlert = _megaAlert;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)showEnterConferenceDetailsAlert
{
    [CMIUtility Log:@"showEnterConferenceDetailsAlert()"];
    
    if (_supportsNotes == YES) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ConferenceNumberDetails", nil) message: NSLocalizedString(@"EnterConferenceNumberDetails", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ContinueButtonTitle", nil)  otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField * alertTextField = [alert textFieldAtIndex:0];
        alertTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        alertTextField.placeholder = NSLocalizedString(@"ConfDetailsNumberPlaceholder", nil);
        alert.tag = ALERT_ENTER_CONF_DETAILS;
        [alert show];                
    }
}

-(void)dismissMegaAnnoyingPopup:(NSTimer*) t
{
    if (self.megaAlert != nil) {
        [self.megaAlert dismissWithClickedButtonIndex:0 animated:YES];
        self.megaAlert = nil;
    }
}

- (void)tryToDial
{
    if (_cmiEvent == nil)   return;
        
    UIAlertView* alert = nil;
    
    if (_cmiEvent.hasConferenceNumber == false) {
        [CMIUtility Log:@"No conf# for this event"];
//        self.megaAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoPhoneNumberAbbreviated", nil)
//                                                    message:NSLocalizedString(@"AddPhoneNumberQuestion", nil) delegate:self cancelButtonTitle:nil
//                                          otherButtonTitles: nil];
//        
//        self.megaAlert.tag = ALERT_NO_NUMBER_FOUND;
//        self.megaAlert.alpha = 0.5;
//        [self.megaAlert show];
//        myTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self
//                                                          selector:@selector(dismissMegaAnnoyingPopup:) userInfo:nil repeats:NO];        
        
    }
    else // We have a phone#, sadly have to act differently depending on provider
    {
        if (_cmiPhone.callProvider == phoneCarrier) {
            [_cmiPhone dialWithConfirmation:_cmiEvent.conferenceNumber view:self.view];
        }
        else
        {
            // We want confirmation...
            NSString* dialNumberLabel = _cmiEvent.conferenceNumber;
            alert = [[UIAlertView alloc] initWithTitle:dialNumberLabel message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CancelButtonLabel", nil) otherButtonTitles: NSLocalizedString(@"DialButtonLabel", nil), nil];            
            alert.tag = ALERT_CONFIRM_DIAL;
        }
    }    
    [alert show];

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
        else if (alertView.tag == ALERT_CONFIRM_DIAL && buttonIndex == 1) {
            [_cmiPhone dial:_cmiEvent.conferenceNumber];            
        }
    }
    @catch (NSException *e) {
        [CMIUtility LogError:e.reason];
    }
}

@end
