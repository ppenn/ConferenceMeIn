//
//  CMIMasterViewController.h
//  ConferenceMeIn
//
//  Created by philip penn on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "CMIEvent.h"
#import <EventKitUI/EventKitUI.h>
#import "CMIEKEventViewController.h"
#import "CMIEventCalendar.h"
#import "ConferenceMeInAppDelegate.h"
#import "CMIHelpViewController.h"
#import "IASKAppSettingsViewController.h"
#import "CMIMyConferenceNumber.h"
#import "CMIPhone.h"
#import "CMIContactsController.h"
#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"

typedef enum menuActionButtons
{
    menuActionDial = 0,
    menuActionEmail,
    menuActionAddToContacts,
    menuActionSettings,
    menuActionCancel
}menuActionButtons;

typedef enum contextMenuActionButtons
{
    contextMenuActionDial = 0,
    contextMenuActionEmail,
    contextMenuActionAddToContacts,
    contextMenuActionCopy,
    contextMenuActionCancel
}contextMenuActionButtons;

typedef enum enterConfNumberActionButtons
{
    enterConfNumberEnterSettings = 0,
    enterConfNumberImportFromContacts
}enterConfNumberActionButtons;


@interface CMIMasterViewController : UITableViewController <UIActionSheetDelegate, EKEventEditViewDelegate, IASKSettingsDelegate, UIGestureRecognizerDelegate, CMIContactsControllerDelegate, GADBannerViewDelegate>
{
    GADBannerView *bannerView_;    
    UIView *admobContainerView;
}

@property (strong, nonatomic) UIAlertView* megaAlert;
@property (strong, nonatomic) CMIEKEventViewController *detailViewController;
@property (strong, nonatomic) CMIHelpViewController* cmiHelpViewController;
@property (strong, nonatomic) CMIEventCalendar* cmiEventCalendar;
@property (strong, nonatomic) IASKAppSettingsViewController *appSettingsViewController;
@property BOOL highlightCurrentEvents;
@property (strong, nonatomic) CMIMyConferenceNumber* cmiMyConferenceNumber;
@property (strong, nonatomic) CMIPhone* cmiPhone;
@property BOOL reloadDefaultsOnAppear;
@property (strong, nonatomic) CMIContactsController* cmiContacts;
@property (strong, nonatomic) CMIEvent* selectedCMIEvent;
@property (atomic) BOOL eventStoreChangeTimerWillFire;
@property BOOL admobIsLoaded;

- (void)setToolbarHidden:(BOOL)hide;
- (void) storeChanged:(NSNotification *) notification;
- (NSArray *)fetchEventsForTable;
- (void)createAdMobBanner;

- (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier;
- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;
- (void)reloadTable;
- (void)showEventNatively:(NSInteger)section row:(NSInteger)row;
- (void) reloadTableScrollToNow;
- (void) showStartDialog;
- (void)readAppSettings;
- (void) warnPhoneNumberNotInSettings;
- (void)invokeMegaAnnoyingPopup:(NSString*)message;
- (void)dismissMegaAnnoyingPopup;
- (void)handleMainActionSheetClick:(NSInteger)buttonIndex;
- (void)handleContextMenu:(NSInteger)buttonIndex;

@end
