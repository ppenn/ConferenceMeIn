//
//  CMIMasterViewController.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIMasterViewController.h"
#import "CMIUtility.h"
#import "CMIUserDefaults.h"

#define ROW_HEIGHT 90

static UIImage *_phoneImage;
NSInteger _tapCount = 0;
NSInteger _tappedRow = 0;
NSInteger _tappedSection = 0;
NSTimer* _tapTimer;
CMIUserDefaults* _cmiUserDefaults;
NSTimer* _refreshTimer;
callProviders _callProvider;
NSIndexPath* _indexPath;
BOOL firstLoad = YES;

@implementation CMIMasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize cmiEventCalendar = _cmiEventCalendar;
@synthesize cmiHelpViewController = _cmiHelpViewController;
@synthesize highlightCurrentEvents = _highlightCurrentEvents;
@synthesize appSettingsViewController = _appSettingsViewController;
@synthesize cmiMyConferenceNumber = _cmiMyConferenceNumber;
@synthesize cmiPhone = _cmiPhone;
@synthesize reloadDefaultsOnAppear = _reloadDefaultsOnAppear;
@synthesize megaAlert;

#pragma mark -
#pragma mark Table view delegate and data source methods

- (void)tapTimerFired:(NSTimer *)aTimer{
    
    @try {
        [CMIUtility Log:@"tapTimerFired()"];

        //timer fired, there was a single tap on indexPath.row = tappedRow
        NSInteger row = _tappedRow;
        NSInteger section = _tappedSection;
        if(_tapTimer != nil){
            _tapCount = 0;
            _tappedRow = -1;
            _tappedSection = -1;
        }
        [self showEventNatively:section row:row];
    
    }
    @catch (NSException * e) {
        [CMIUtility LogError:e.reason];
    }
}


- (void)showEventNatively:(NSInteger)section row:(NSInteger)row
{
    [CMIUtility Log:@"showEventNatively()"];
    
    _detailViewController = [[CMIEKEventViewController alloc] initWithNibName:nil bundle:nil];        
    CMIEvent* cmiEvent = [self.cmiEventCalendar getCMIEventByIndexPath:section eventIndex:row];
    _detailViewController.event = cmiEvent.ekEvent;
    _detailViewController.eventStore = _cmiEventCalendar.eventStore;
    _detailViewController.cmiEvent = cmiEvent;
    _detailViewController.cmiPhone = _cmiPhone;
    _detailViewController.hasDisplayedPopup = NO;

    //	Push detailViewController onto the navigation controller stack
    //	If the underlying event gets deleted, detailViewController will remove itself from
    //	the stack and clear its event property.
   self.navigationController.toolbarHidden = YES;

//    _detailViewController.delegate = _detailViewController;
    _detailViewController.allowsEditing = YES;
    [self.navigationController pushViewController:_detailViewController animated:YES];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    @try {
        [CMIUtility Log:@"numberOfSectionsInTableView()"];
        // Number of days in calendar
        NSInteger numSections = [_cmiEventCalendar.cmiDaysArray count];

        return numSections;
    }
    @catch (NSException * e) {
        [CMIUtility LogError:e.reason];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    @try {
        [CMIUtility Log:@"numberOfRowsInSection()"];
        
        if (_cmiEventCalendar.eventsList.count == 0) {
            return 1;
        }
        
        // Get number of events in a day
        CMIDay* cmiDay = [_cmiEventCalendar getCMIDayByIndex:section];
        
        return cmiDay.cmiEvents.count;
    }
    @catch (NSException * e) {
        [CMIUtility LogError:e.reason];
    }
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
    @try {
        [CMIUtility Log:@"titleForHeaderInSection()"];
	
        // Section title is the region name
        NSString* day = [_cmiEventCalendar getCMIDayNameByIndex:section];

        return day;
    }
    @catch (NSException * e) {
        [CMIUtility LogError:e.reason];
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    @try {
        [CMIUtility Log:@"cellForRowAtIndexPath()"];

        UITableViewCell* cell;
        
        if (_cmiEventCalendar.eventsList.count == 0) {
            cell = [[UITableViewCell alloc] init];
            cell.textLabel.text = NSLocalizedString(@"NoEventsMessage", @"");
            UIFont* font = [UIFont systemFontOfSize:15.0];
            cell.textLabel.font = font;		
            cell.userInteractionEnabled = NO;
            return cell;            
        }
        
        static NSString* CellIdentifier = @"EventCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [self tableViewCellWithReuseIdentifier:CellIdentifier];
        }
        
        // Add disclosure triangle to cell
        UITableViewCellAccessoryType editableCellAccessoryType =UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryType = editableCellAccessoryType;
        
        // configureCell:cell forIndexPath: sets the text and image for the cell -- the method is factored out as it's also called during minuted-based updates.
        [self configureCell:cell forIndexPath:indexPath];

        return cell;
    }
    @catch (NSException * e) {
        [CMIUtility LogError:e.reason];
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [CMIUtility Log:@"didSelectRowAtIndexPath()"];
    
    @try {
        
        _indexPath = indexPath;

        //checking for double taps here
        if(_tapCount == 1 && _tapTimer != nil && 
           _tappedRow == indexPath.row && _tappedSection == indexPath.section){
            //double tap - Put your double tap code here            
            [_tapTimer invalidate];
            _tapTimer = nil;
            CMIEvent* cmiEvent = [_cmiEventCalendar getCMIEventByIndexPath:_tappedSection eventIndex:_tappedRow];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            _tappedRow = -1;
            _tappedSection = -1;
            if ([cmiEvent hasConferenceNumber] == true) {
                [_cmiPhone dial:cmiEvent.conferenceNumber];
            }
            else {
                [self showEventNatively:indexPath.section row:indexPath.row];
            }

        }
        else if(_tapCount == 0){
            //This is the first tap. If there is no tap till tapTimer is fired, it is a single tap
            _tapCount = _tapCount + 1;
            _tappedRow = indexPath.row;
            _tappedSection = indexPath.section;
            _tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(tapTimerFired:) userInfo:nil repeats:NO];
        }        
        else if(_tappedRow != indexPath.row){
            //tap on new row
            _tapCount = 1;
            if(_tapTimer != nil){
                [_tapTimer invalidate];
                _tapTimer = nil;
            }
            _tappedRow = indexPath.row;
            _tappedSection = indexPath.section;
            _tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(tapTimerFired:) userInfo:nil repeats:NO];
            
        }
        
    }
    @catch (NSException * e) {
        [CMIUtility LogError:e.reason];
    }
}

- (void) showStartDialog
{
    [CMIUtility Log:@"showStartDialog()"];
    
    // Create the predicate. Pass it the default calendar.

    if (_cmiUserDefaults.firstRun == true) {
        NSString* alertMessage;
        if ([CMIUtility environmentIsAtIOS5OrHigher] == false) {
            alertMessage = [[NSLocalizedString(@"IntroMessage", @"") stringByAppendingString:@"\n\r"] stringByAppendingString:NSLocalizedString(@"IOS5WarningMessage", nil)];
        }
        else {
            alertMessage = NSLocalizedString(@"IntroMessage", @"");
        }
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"ConferenceMeIn" message:alertMessage                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
    }
}

//TODO:refactor?
- (void)readAppSettings
{
    [CMIUtility Log:@"readAppSettings()"];
            
    //TODO rm
    _callProvider = _cmiUserDefaults.callProviderType;
    _cmiPhone.callProvider = _cmiUserDefaults.callProviderType;
    _cmiEventCalendar.calendarType = _cmiUserDefaults.calendarType;
    _cmiEventCalendar.filterType = _cmiUserDefaults.filterType;
    _cmiEventCalendar.currentTimeframeStarts = _cmiUserDefaults.currentTimeframeStarts;
    _cmiEventCalendar.calendarTimeframeType = _cmiUserDefaults.calendarTimeframeType;
    _highlightCurrentEvents = _cmiUserDefaults.highlightCurrentEvents;
    _cmiMyConferenceNumber.cmiUserDefaults = _cmiUserDefaults;
}

- (void)viewWillUnload
{
    
}

- (NSArray *)fetchEventsForTable 
{
    [CMIUtility Log:@"fetchEventsForTable()"];
    
    return [_cmiEventCalendar fetchEvents];
}

- (void)reloadTable
{
    [CMIUtility Log:@"reloadTable()"];

    [_cmiEventCalendar createCMIDayEvents];
    
	[self.tableView reloadData];    
}

- (void) scrollToNow
{
    [CMIUtility Log:@"scrollToNow()"];
    
    NSDate* now = [NSDate date];

    NSIndexPath *scrollIndexPath = [_cmiEventCalendar getDayEventIndexForDate:now];
    if (scrollIndexPath != nil) {
        [[self tableView] scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];  
    }    
}

-(void)invokeMegaAnnoyingPopup
{
    self.megaAlert = [[UIAlertView alloc] initWithTitle:@"Loading Events..."
                                                 message:nil delegate:self cancelButtonTitle:nil
                                       otherButtonTitles: nil];
        
    [self.megaAlert show];

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]
                                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    indicator.center = CGPointMake(self.megaAlert.bounds.size.width / 2,
                                   self.megaAlert.bounds.size.height - 45);
    [indicator startAnimating];
    [self.megaAlert addSubview:indicator];
}

-(void)dismissMegaAnnoyingPopup
{
    if (self.megaAlert != nil) {
        [self.megaAlert dismissWithClickedButtonIndex:0 animated:YES];
        self.megaAlert = nil;
    }
}
- (void) reloadTableScrollToNow
{
    [CMIUtility Log:@"reloadTableScrollToNow()"];
    [self readAppSettings];    
    [self reloadTable];
    [self scrollToNow];
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];    
    [self dismissMegaAnnoyingPopup];
}


- (void) storeChanged:(NSNotification *) notification
{
    
    @try {
        [CMIUtility Log:[@"storeChanged() notification" stringByAppendingFormat:@"[ %@ ] ", notification.name ]];

        _cmiEventCalendar.calendarType = _cmiUserDefaults.calendarType;
        
        [self reloadTableScrollToNow];
    }
    @catch (NSException *e) {
        [CMIUtility LogError:e.reason];
    }
    
}

- (void)menuAction:(id)sender
{
    @try {
        [CMIUtility Log:@"menuAction()"];
        
        // open a dialog with just an OK button
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"MenuButtonTitle", @"")                                                             delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"CallMyConfNumTitle",@""), NSLocalizedString(@"SettingsTitle", @""), NSLocalizedString(@"HelpButtonTitle",@""),nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showFromToolbar:self.navigationController.toolbar];	// show from our table view (pops up in the middle of the table)
    }
    @catch (NSException *e) {
        [CMIUtility LogError:e.reason];
    }
    
}
- (void) createMenuButton
{
    [CMIUtility Log:@"createMenuButton()"];

    // add tint bar button
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MenuButtonTitle", @"")
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(menuAction:)];
    self.navigationItem.leftBarButtonItem = menuButton;
}


- (void)addEvent:(id)sender {
    
    @try {
        [CMIUtility Log:@"addEvent:(id)sender()"];
        
        // When add button is pushed, create an EKEventEditViewController to display the event.
        EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
        
        // set the addController's event store to the current event store.
        addController.eventStore = _cmiEventCalendar.eventStore;
        EKEvent *event  = [EKEvent eventWithEventStore:_cmiEventCalendar.eventStore];        
        event.location = _cmiMyConferenceNumber.conferenceNumberFormatted;
        addController.event = event;
        
        // present EventsAddViewController as a modal view controller
        [self presentModalViewController:addController animated:YES];
        
        addController.editViewDelegate = self;
    }
    @catch (NSException *e) {
        [CMIUtility LogError:e.reason];
    }
    
}


#pragma mark -
#pragma mark EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller 
          didCompleteWithAction:(EKEventEditViewAction)action {
	
    @try {
        [CMIUtility Log:@"eventEditViewController:didCompleteWithAction()"];

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
                [controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
                [self reloadTableScrollToNow];
                break;
                
            case EKEventEditViewActionDeleted:
                // When deleting an event, remove the event from the event store, 
                // and reload table view.
                // If deleting an event from the currenly default calendar, then update its 
                // eventsList.
                [controller.eventStore removeEvent:thisEvent span:EKSpanThisEvent error:&error];
                [self reloadTableScrollToNow];
                break;
                
            default:
                break;
        }
    }
    @catch (NSException *e) {
        [CMIUtility LogError:e.reason];
    }
    @finally {
        // Dismiss the modal view controller
        [controller dismissModalViewControllerAnimated:YES];
    }
	
}

- (void)eventFilterChanged:(id)sender
{    
    @try {
        
        [CMIUtility Log:@"eventFilterChanged()"];

        eventFilterTypes selectionIndex = ((UISegmentedControl*)sender).selectedSegmentIndex;

        if (selectionIndex != _cmiEventCalendar.filterType) {    
            _cmiUserDefaults.filterType = selectionIndex;
        
            [self reloadTableScrollToNow];
        }    
    }
    @catch (NSException *e) {
        [CMIUtility LogError:e.reason];
    }

}

#pragma mark -
#pragma mark View life-cycle

- (void)viewDidLoad {
    
    @try {
        [CMIUtility Log:@"viewDidLoad()"];
        
        _cmiUserDefaults = ((ConferenceMeInAppDelegate *)[[UIApplication sharedApplication] delegate]).cmiUserDefaults;
        
        _cmiMyConferenceNumber = [[CMIMyConferenceNumber alloc] initWithUserDefaults:_cmiUserDefaults];
        _cmiPhone = [[CMIPhone alloc] initWithCallProvider:_cmiUserDefaults.callProviderType];
        
        self.title = NSLocalizedString(@"MainWindowTitle", nil);
        [self createMenuButton];
        
        self.tableView.rowHeight = ROW_HEIGHT;
        _phoneImage = [UIImage imageNamed:@"phone.png"];

        _cmiEventCalendar = [[CMIEventCalendar alloc] init];
        // NB: you cannot read app settings before instantiating the calendar
        [self readAppSettings];
        _cmiUserDefaults.defaultsDidChange = NO;

        // This will only do anything if we are in the Simulator
        [CMIUtility createTestEvents:_cmiEventCalendar.eventStore];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeChanged:)
                                                     name:EKEventStoreChangedNotification object:_cmiEventCalendar.eventStore];

        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;    
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;    
        self.view.autoresizesSubviews = true;
        self.tableView.autoresizesSubviews = true;

        //	Create an Add button 
        UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                                          UIBarButtonSystemItemAdd target:self action:@selector(addEvent:)];
        self.navigationItem.rightBarButtonItem = addButtonItem;
        
        
        NSArray *segmentedItems = [NSArray arrayWithObjects:NSLocalizedString(@"SegmentAllEventsButton", nil), NSLocalizedString(@"SegmentConfCallEventsButton", nil), nil];
        UISegmentedControl *ctrl = [[UISegmentedControl alloc] initWithItems:segmentedItems];
        ctrl.segmentedControlStyle = UISegmentedControlStyleBar;
        ctrl.selectedSegmentIndex = _cmiEventCalendar.filterType;

        [ctrl addTarget:self
              action:@selector(eventFilterChanged:)
              forControlEvents:UIControlEventValueChanged];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:ctrl];
        CGFloat margin = 10.0;
        CGFloat width = self.navigationController.toolbar.frame.size.width - margin;
        CGFloat height = self.navigationController.toolbar.frame.size.height - margin; 
        ctrl.frame = CGRectMake(margin, margin, width, height);
        ctrl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        NSArray *theToolbarItems = [NSArray arrayWithObjects:item, nil];
        [self setToolbarItems:theToolbarItems];
            
        [self reloadTableScrollToNow];        
        [self showStartDialog];
            
    }
    @catch (NSException *e) {
        [CMIUtility LogError:e.reason];
    }
}

- (void)dealloc
{
    @try {
        [CMIUtility Log:@"dealloc()"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
    }
    @catch (NSException *e) {
        [CMIUtility LogError:e.reason];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    @try {
        [CMIUtility Log:@"viewDidUnload()"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];

    }
    @catch (NSException *e) {
        [CMIUtility LogError:e.reason];
    }
}

- (BOOL)reloadDue
{
    if (_reloadDefaultsOnAppear == YES && _cmiUserDefaults.defaultsDidChange == YES) {
        return YES;
    }    
    else {
        return NO;
    }
}


- (void)viewDidLayoutSubviews
{
    if ([self reloadDue] == YES || firstLoad == YES) {
        firstLoad = NO;
        [self invokeMegaAnnoyingPopup];    
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [CMIUtility Log:@"viewDidAppear()"];
    
    @try {
        if (_reloadDefaultsOnAppear == YES && _cmiUserDefaults.defaultsDidChange == YES) {
            _reloadDefaultsOnAppear = NO;
            _cmiUserDefaults.defaultsDidChange = NO;
            [self reloadTableScrollToNow];
        }
        else {
            if (_indexPath != nil) {
                [self.tableView deselectRowAtIndexPath:_indexPath animated:YES];        
                _indexPath = nil;
            }
            
            // If the toolbar's not been hidden then this "didAppear" event was fired
            // by the app coming back to life, not from touching back from a forward screen
            if (self.navigationController.toolbarHidden == NO) {
                [self scrollToNow];
            }
        }    
        self.navigationController.toolbarHidden = NO;
    }
    @catch (NSException *e) {
        [CMIUtility LogError:e.reason];
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [CMIUtility Log:@"shouldAutorotateToInterfaceOrientation()"];

    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
#pragma mark Configuring table view cells

#define TIME_TAG 1
#define IMAGE_TAG 2
#define NAME_TAG 3

#define EVENT_TITLE_TAG 4
#define EVENT_ORGANIZER_TAG 5
#define EVENT_PHONE_NUMBER_TAG 6
#define DUMMY_LEFT_CELL_TAG 7

#define START_TIME_TAG 8
#define TIME_SEPARATOR_TAG 9
#define END_TIME_TAG 10


#define LEFT_COLUMN_OFFSET 10.0
#define LEFT_COLUMN_WIDTH 70.0
#define LEFT_SEPARATOR_WIDTH 12.0

#define IMAGE_COLUMN_OFFSET 100.0
#define IMAGE_COLUMN_WIDTH 40.0

#define RIGHT_COLUMN_OFFSET 90.0
#define RIGHT_COLUMN_WIDTH 205.0

#define ORGANIZER_WIDTH 100.0

#define MAIN_FONT_SIZE 16.0
#define TIME_FONT_SIZE 14.0
#define LABEL_HEIGHT 26.0
#define TIME_LABEL_HEIGHT 26.0
#define SEPARATOR_OFFSET 5.0

#define LABEL_UPPER 2.0
#define LABEL_MIDDLE 28.0
#define LABEL_LOWER 54.0

#define IMAGE_SIDE 15.0
#define VERTICAL_ALIGNMENT_OFFSET 2.0

- (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier {
	
	/*
	 Create an instance of UITableViewCell and add tagged subviews for the name, local time, and quarter image of the time zone.
	 */

    @try {
        [CMIUtility Log:@"tableViewCellWithReuseIdentifier()"];
        
    
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        /*
         Create labels for the text fields; set the highlight color so that when the cell is selected it changes appropriately.
         */
        CGRect rect;

        UIFont* fontTime = [UIFont systemFontOfSize:TIME_FONT_SIZE];
        NSString* sampleTime = @"4:56 PM";
        CGSize sizeOfTimeString = [sampleTime sizeWithFont:fontTime];
        CGFloat timeStringHeight = sizeOfTimeString.height;
        CGFloat rowMiddle = self.tableView.rowHeight / 2.0;
        
        double timeLabelHeight = self.tableView.rowHeight / 2.85;
        timeLabelHeight = timeStringHeight + SEPARATOR_OFFSET;
        UILabel* timeStartLabel =
        [[UILabel alloc]
         initWithFrame:
         CGRectMake(
                    LEFT_COLUMN_OFFSET,
                    rowMiddle - (timeLabelHeight - VERTICAL_ALIGNMENT_OFFSET), 
                    LEFT_COLUMN_WIDTH,
                    timeStringHeight)];
        timeStartLabel.tag = START_TIME_TAG;
        timeStartLabel.font = fontTime;
        timeStartLabel.textAlignment = UITextAlignmentCenter;
        timeStartLabel.adjustsFontSizeToFitWidth = NO;
        [cell.contentView addSubview:timeStartLabel];
        timeStartLabel.highlightedTextColor = [UIColor whiteColor];
        timeStartLabel.backgroundColor = [UIColor clearColor];
        
        UILabel* timeEndLabel =
        [[UILabel alloc]
         initWithFrame:
         CGRectMake(
                    LEFT_COLUMN_OFFSET,
                    rowMiddle, 
                    LEFT_COLUMN_WIDTH,
                    timeLabelHeight)];
        timeEndLabel.tag = END_TIME_TAG;
        timeEndLabel.textAlignment = UITextAlignmentCenter;
        timeEndLabel.font = [UIFont systemFontOfSize:TIME_FONT_SIZE];
        timeEndLabel.adjustsFontSizeToFitWidth = NO;
        [cell.contentView addSubview:timeEndLabel];
        timeEndLabel.highlightedTextColor = [UIColor whiteColor];
        timeEndLabel.backgroundColor = [UIColor clearColor];
        
        
        CGFloat leftMiddle = (LEFT_COLUMN_OFFSET + LEFT_COLUMN_WIDTH) / 2.0;
        UILabel* timeSeparatorRect =
        [[UILabel alloc]
         initWithFrame:
         CGRectMake(
                    leftMiddle - (LEFT_SEPARATOR_WIDTH / 2.0),
                    rowMiddle, 
                    LEFT_SEPARATOR_WIDTH,
                    1.0)];
        timeSeparatorRect.tag = TIME_SEPARATOR_TAG;
        //        timeSeparatorRect.font = [UIFont systemFontOfSize:TIME_FONT_SIZE];
        timeSeparatorRect.adjustsFontSizeToFitWidth = NO;
        [cell.contentView addSubview:timeSeparatorRect];
        timeSeparatorRect.highlightedTextColor = [UIColor whiteColor];
        timeSeparatorRect.backgroundColor = [UIColor blackColor];
        
        UILabel *topLabel;
        UILabel *middleLabel;
        UILabel *bottomLabel;
        
        topLabel =
        [[UILabel alloc]
          initWithFrame:
          CGRectMake(
                     RIGHT_COLUMN_OFFSET,
                     0.333333 * (self.tableView.rowHeight - 3 * LABEL_HEIGHT), 
                     self.tableView.bounds.size.width - (2 * cell.indentationWidth) - RIGHT_COLUMN_OFFSET,
                     LABEL_HEIGHT)];
        topLabel.tag = EVENT_TITLE_TAG;
        topLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth; 
        topLabel.backgroundColor = [UIColor clearColor];
        topLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize] - 2];

        middleLabel =
        [[UILabel alloc]
         initWithFrame:
         CGRectMake(
                    RIGHT_COLUMN_OFFSET,
                    LABEL_MIDDLE,// 0.5 * (self.tableView.rowHeight - 2 * LABEL_HEIGHT) + LABEL_HEIGHT,
                    RIGHT_COLUMN_WIDTH, // - (LABEL_HEIGHT + 4),
                    LABEL_HEIGHT)];
        
        middleLabel.tag = EVENT_ORGANIZER_TAG;
        middleLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize] - 4];
        middleLabel.backgroundColor = [UIColor clearColor];

        
        bottomLabel =
        [[UILabel alloc]
          initWithFrame:
          CGRectMake(
                     RIGHT_COLUMN_OFFSET + (LABEL_HEIGHT + 4),
                     LABEL_LOWER,// 0.5 * (self.tableView.rowHeight - 2 * LABEL_HEIGHT) + LABEL_HEIGHT,
                     RIGHT_COLUMN_WIDTH - (LABEL_HEIGHT + 4), // - (LABEL_HEIGHT + 4),
                     LABEL_HEIGHT)];
        
        bottomLabel.tag = EVENT_PHONE_NUMBER_TAG;
        bottomLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize] - 6];
        bottomLabel.backgroundColor = [UIColor clearColor];

        [cell.contentView addSubview:topLabel];
        [cell.contentView addSubview:middleLabel];
        [cell.contentView addSubview:bottomLabel];

        // Create an image view for the quarter image.// MCW WAS IMAGE_SIDE
        rect = CGRectMake(RIGHT_COLUMN_OFFSET, 
                          LABEL_LOWER,// 0.5 * (self.tableView.rowHeight - 2 * LABEL_HEIGHT) + LABEL_HEIGHT,
                          LABEL_HEIGHT - 4, 
                          LABEL_HEIGHT - 4);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.tag = IMAGE_TAG;
        imageView.backgroundColor = [UIColor clearColor];

        [cell.contentView addSubview:imageView];

        cell.backgroundView =[[UIImageView alloc] init];
        
        return cell;
    }
    @catch (NSException * e) {
        [CMIUtility LogError:e.reason];
    }

        
}

//TODO: MOVE this somewhere...parameterize
- (BOOL) eventIsNow:(EKEvent*) event
{
    [CMIUtility Log:@"eventIsNow()"];
    
    NSDate* now = [NSDate date];
    // endDate is 1 day = 60*60*24 seconds = 86400 seconds from startDate
    NSDate* trueStartDate = [NSDate dateWithTimeInterval:-(15*60) sinceDate:event.startDate];

    return [CMIUtility date:now isBetweenDate:trueStartDate andDate:event.endDate];
    
}



- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {

    @try {
        [CMIUtility Log:@"configureCell()"];
        
        /*
         Cache the formatter. Normally you would use one of the date formatter styles (such as NSDateFormatterShortStyle), but here we want a specific format that excludes seconds.
         */
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:NSLocalizedString(@"DateFormat", nil)];
        }
        
        // Get the event at the row selected and display it's title
        CMIEvent* cmiEvent = [self.cmiEventCalendar getCMIEventByIndexPath:indexPath.section eventIndex:indexPath.row];
        NSDate* eventStartDate = [[cmiEvent ekEvent] startDate];
        NSString* eventStartDateStr = [dateFormatter stringFromDate:eventStartDate];
        NSDate* eventEndDate = [[cmiEvent ekEvent] endDate];
        NSString* eventEndDateStr = [dateFormatter stringFromDate:eventEndDate];
        
        UILabel *label;
        UIImage *rowBackground;
        if (_highlightCurrentEvents == YES && [self eventIsNow:cmiEvent.ekEvent]) {
            rowBackground = [UIImage imageNamed:@"middleRowSelected.png"];            
        }
        else {
            rowBackground = [UIImage imageNamed:@"middleRow.png"];            
        }
        ((UIImageView *)cell.backgroundView).image = rowBackground;
        
        // Set the event title name.
        label = (UILabel *)[cell viewWithTag:EVENT_TITLE_TAG];
        label.text = ([[cmiEvent ekEvent] title] != nil) ? [[cmiEvent ekEvent] title] : NSLocalizedString(@"NewEventLabel", nil);
        
        label = (UILabel *)[cell viewWithTag:EVENT_ORGANIZER_TAG];
        label.text = ([[cmiEvent ekEvent] organizer] != nil) ? [[[cmiEvent ekEvent] organizer] name] : NSLocalizedString(@"NoOrganizerLabel", nil);
        

        label = (UILabel *)[cell viewWithTag:START_TIME_TAG];
        label.text = eventStartDateStr;
        label = (UILabel *)[cell viewWithTag:END_TIME_TAG];
        label.text = eventEndDateStr;
        
        // Set the image.
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:IMAGE_TAG];
        if (cmiEvent.hasConferenceNumber == true) {
            imageView.image = _phoneImage;        
            label = (UILabel *)[cell viewWithTag:EVENT_PHONE_NUMBER_TAG];
            label.text = cmiEvent.conferenceNumber;
        }
        else {
            imageView.image = nil;
            label = (UILabel *)[cell viewWithTag:EVENT_PHONE_NUMBER_TAG];
            label.text = @"";
        }
    
    }
    @catch (NSException * e) {
        [CMIUtility LogError:e.reason];
    }
    
}    

- (void) showHelpDialog
{
    [CMIUtility Log:@"showHelpDialog()"];

    _cmiHelpViewController = [[CMIHelpViewController alloc] initWithNibName:@"CMIHelpIPhoneView" bundle:nil];
    [self.navigationController pushViewController:_cmiHelpViewController animated:YES];
}

- (IASKAppSettingsViewController*)appSettingsViewController {
	if (!_appSettingsViewController) {
		_appSettingsViewController = [[IASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];
		_appSettingsViewController.delegate = self;
	}
	return _appSettingsViewController;
}

- (void) showSettingsDialog
{
    [CMIUtility Log:@"showSettingsDialog()"];

    if ([self.appSettingsViewController.file isEqualToString:@"Root"]) {
        _appSettingsViewController = nil;
    }
    
    if ([self.appSettingsViewController.file isEqualToString:@"ChildCMINumber"]) {
        _appSettingsViewController = nil;
    }
    self.appSettingsViewController.file = @"Root";
    self.appSettingsViewController.showDoneButton = YES;
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
    [self presentModalViewController:aNavController animated:YES];
    
}

- (void) warnPhoneNumberNotInSettings
{
    [CMIUtility Log:@"warnPhoneNumberNotInSettings()"];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ConferenceMeIn" message:NSLocalizedString(@"WarnInvalidPhoneNumberMessage", @"")                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
    if ([self.appSettingsViewController.file isEqualToString:@"ChildCMINumber"]) {
        _appSettingsViewController = nil;
    }
    self.appSettingsViewController.file = @"ChildCMINumber";
    self.appSettingsViewController.showDoneButton = YES;
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
    [self presentModalViewController:aNavController animated:YES];
    
}

- (void) callMyNumber
{
    [CMIUtility Log:@"callMyNumber()"];

    if(_cmiMyConferenceNumber.isValid == FALSE) {
        [self warnPhoneNumberNotInSettings];
    }
    else {
        // Call the number...
        [_cmiPhone dialConferenceNumber:_cmiMyConferenceNumber];
    }
}


#pragma mark -
#pragma mark - UIActionSheetDelegate
    
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    @try {
        [CMIUtility Log:@"clickedButtonAtIndex()"];

        // the user clicked one of the OK/Cancel buttons
        switch (buttonIndex) {
            case 0:
                [CMIUtility Log:@"Call My Number"];
                [self callMyNumber];
                break;
            case 1:
                [CMIUtility Log:@"Settings"];
                [self showSettingsDialog];
                break;
            case 2:
                [CMIUtility Log:@"Help"];
                [self showHelpDialog];
                break;
            default:
                [CMIUtility Log:@"Cancel"];
                break;
        }
    }
    @catch (NSException * e) {
        [CMIUtility LogError:e.reason];
    }

}
    
#pragma mark -
#pragma mark IASKAppSettingsViewControllerDelegate protocol
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    [self dismissModalViewControllerAnimated:YES];

    @try {
        [CMIUtility Log:@"settingsViewControllerDidEnd()"];
	
        // your code here to reconfigure the app for changed settings
        // If we now have phone and conf numbers...then we can proceed
        [_cmiUserDefaults loadDefaults];
        [self readAppSettings];
        if([sender.file isEqualToString:@"ChildCMINumber"] && _cmiMyConferenceNumber.isValid) {
            // Call the number...
            [_cmiPhone dialConferenceNumberWithConfirmation:_cmiMyConferenceNumber view:self.tableView];
        }    

    }
    @catch (NSException * e) {
        [CMIUtility LogError:e.reason];
    }
        
}


@end
