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

@implementation CMIMasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize cmiEventCalendar = _cmiEventCalendar;
@synthesize cmiHelpViewController = _cmiHelpViewController;
@synthesize cmiAboutViewController = _cmiAboutViewController;

callProviders _callProvider;



#pragma mark -
#pragma mark Table view delegate and data source methods

- (void)tapTimerFired:(NSTimer *)aTimer{
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


- (void)showEventNatively:(NSInteger)section row:(NSInteger)row
{
    NSLog(@"showEventNatively()");
    
    self.detailViewController = [[CMIEKEventViewController alloc] initWithNibName:nil bundle:nil];        
    CMIEvent* cmiEvent = [self.cmiEventCalendar getCMIEventByIndexPath:section eventIndex:row];
    _detailViewController.event = [cmiEvent ekEvent];
    
    _detailViewController.allowsEditing = YES;
    _detailViewController.detailItem = cmiEvent;
    //	Push detailViewController onto the navigation controller stack
    //	If the underlying event gets deleted, detailViewController will remove itself from
    //	the stack and clear its event property.
    [self.navigationController pushViewController:_detailViewController animated:YES];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
	// Number of days in calendar
    NSInteger numSections = [_cmiEventCalendar.cmiDaysArray count];

    return numSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    @try {
        [CMIUtility Log:@"numberOfRowsInSection()"];
        
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
        
        static NSString *CellIdentifier = @"EventCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
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
    NSLog(@"didSelectRowAtIndexPath()");
    
    @try {

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
                [cmiEvent dial:self.view confirmCall:false callProvider:_callProvider];
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
        NSLog(@"Exception: %@", e); 
    }
    @finally {
        // Added to show finally works as well
    }    
}

- (void) showStartDialog
{
    NSLog(@"showStartDialog()");
    
    // Create the predicate. Pass it the default calendar.

    if (_cmiUserDefaults.firstRun == true) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ConferenceMeIn" message:@"Double-tap calendar item to dial # directly. Single-tap item to see event details and dial number "
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
    }
}

//TODO:refactor?
- (void)readAppSettings
{
    [CMIUtility Log:@"readAppSettings()"];
            
    _callProvider = _cmiUserDefaults.callProviderType;
    _cmiEventCalendar.fetchAllEvents = _cmiUserDefaults.debugMode;
    _cmiEventCalendar.calendarType = _cmiUserDefaults.calendarType;
    _cmiEventCalendar.filterType = _cmiUserDefaults.filterType;
    
}

- (void)viewWillUnload
{
    
}

- (NSArray *)fetchEventsForTable 
{
    NSLog(@"fetchEventsForTable()");
    
    return [_cmiEventCalendar fetchEvents];
}

- (void)reloadTable
{
    NSLog(@"reloadTable()");

//    [_cmiEventCalendar createCMIEvents];
    [_cmiEventCalendar createCMIDayEvents];
    
	[self.tableView reloadData];    
}

- (void) scrollToNow
{
    NSLog(@"scrollToNow()");
    
    NSDate* now = [[NSDate alloc] init];

    NSIndexPath *scrollIndexPath = [_cmiEventCalendar getDayEventIndexForDate:now];
    if (scrollIndexPath != nil) {
        [[self tableView] scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];  
    }    
}


- (void) reloadTableScrollToNow
{
    NSLog(@"reloadTableScrollToNow()");

    [self readAppSettings];    
    [self reloadTable];
    [self scrollToNow];
    
}


- (void) storeChanged:(NSNotification *) notification
{
    
    @try {
        [CMIUtility Log:[@"storeChanged() notification" stringByAppendingFormat:@"[ %@ ] ", notification.name ]];

        // [notification name] should always be @"TestNotification"
        // unless you use this method for observation of other notifications
        // as well.
                
        _cmiEventCalendar.fetchAllEvents = _cmiUserDefaults.debugMode;
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
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"MenuButtonTitle", @"")                                                             delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"HelpButtonTitle",@""),@"About",nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:self.view];	// show from our table view (pops up in the middle of the table)
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

// If event is nil, a new event is created and added to the specified event store. New events are 
// added to the default calendar. An exception is raised if set to an event that is not in the 
// specified event store.
- (void)addEvent:(id)sender {

    @try {
        
        // When add button is pushed, create an EKEventEditViewController to display the event.
        EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
        
        // set the addController's event store to the current event store.
        addController.eventStore = _cmiEventCalendar.eventStore;
        
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
//            [_cmiEventCalendar.
//            [self.eventsList addObject:thisEvent];
//			[controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
//			[self.tableView reloadData];
			break;
			
		case EKEventEditViewActionDeleted:
			// When deleting an event, remove the event from the event store, 
			// and reload table view.
			// If deleting an event from the currenly default calendar, then update its 
			// eventsList.
//			if (self.defaultCalendar ==  thisEvent.calendar) {
//				[self.eventsList removeObject:thisEvent];
//			}
			[controller.eventStore removeEvent:thisEvent span:EKSpanThisEvent error:&error];
			[self.tableView reloadData];
			break;
			
		default:
			break;
	}
	// Dismiss the modal view controller
	[controller dismissModalViewControllerAnimated:YES];
	
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
        
        //TODO: figure this out
        //	self.title = NSLocalizedString(@"Time Zones", @"Time Zones title");
        self.title = @"Calendar";
        [self createMenuButton];
        
        self.tableView.rowHeight = ROW_HEIGHT;
        _phoneImage = [UIImage imageNamed:@"phone.png"];

        _cmiEventCalendar = [[CMIEventCalendar alloc] init];
        // NB: you cannot read app settings before instantiating the calendar
        [self readAppSettings];
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
        
        
        NSArray *segmentedItems = [NSArray arrayWithObjects:@"All Events", @"Conf Call Events", nil];
        UISegmentedControl *ctrl = [[UISegmentedControl alloc] initWithItems:segmentedItems];
        ctrl.segmentedControlStyle = UISegmentedControlStyleBar;
        ctrl.selectedSegmentIndex = _cmiEventCalendar.filterType;

        [ctrl addTarget:self
              action:@selector(eventFilterChanged:)
              forControlEvents:UIControlEventValueChanged];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:ctrl];
        ctrl.frame = CGRectMake(0.0f, 5.0f, 320.0f, 30.0f);
        
        NSArray *theToolbarItems = [NSArray arrayWithObjects:item, nil];
        [self setToolbarItems:theToolbarItems];
            
        [self reloadTableScrollToNow];
        
        [self showStartDialog];
    
    }
    @catch (NSException *e) {
        [CMIUtility LogError:e.reason];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [CMIUtility Log:@"viewDidAppear()"];
    
    self.navigationController.toolbarHidden = NO;
    
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
//        UILabel *timeLabel;
//
//        // Create a label for the event time.
//        rect = CGRectMake(LEFT_COLUMN_OFFSET, (ROW_HEIGHT - LABEL_HEIGHT) / 2.0, LEFT_COLUMN_WIDTH, LABEL_HEIGHT);
//        timeLabel = [[UILabel alloc] initWithFrame:rect];
//        timeLabel.tag = TIME_TAG;
//        timeLabel.font = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
//        timeLabel.adjustsFontSizeToFitWidth = NO;
//        [cell.contentView addSubview:timeLabel];
//        timeLabel.highlightedTextColor = [UIColor whiteColor];
//        timeLabel.backgroundColor = [UIColor clearColor];

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
    @finally {
        // Insert any cleanup...
    }    

        
}

//TODO: MOVE this somewhere...parameterize
- (BOOL) eventIsNow:(EKEvent*) event
{
    NSDate* now = [[NSDate alloc] init];
    // endDate is 1 day = 60*60*24 seconds = 86400 seconds from startDate
    NSDate* trueStartDate = [NSDate dateWithTimeInterval:-(15*60) sinceDate:event.startDate];

    return [CMIUtility date:now isBetweenDate:trueStartDate andDate:event.endDate];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell1:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMIEvent* cmiEvent = [self.cmiEventCalendar getCMIEventByIndexPath:indexPath.section eventIndex:indexPath.row];

    if ([self eventIsNow:cmiEvent.ekEvent] ) {
        ((UILabel *)[cell viewWithTag:TIME_TAG]).backgroundColor = 
        ((UILabel *)[cell viewWithTag:NAME_TAG]).backgroundColor = 
        ((UILabel *)[cell viewWithTag:EVENT_TITLE_TAG]).backgroundColor = 
        ((UILabel *)[cell viewWithTag:EVENT_ORGANIZER_TAG]).backgroundColor = 
        ((UILabel *)[cell viewWithTag:EVENT_PHONE_NUMBER_TAG]).backgroundColor = 
        ((UIImageView *)[cell viewWithTag:IMAGE_TAG]).backgroundColor = 
        cell.backgroundColor = [UIColor redColor];
	}
    else {
        ((UILabel *)[cell viewWithTag:TIME_TAG]).backgroundColor = 
        ((UILabel *)[cell viewWithTag:NAME_TAG]).backgroundColor = 
        ((UILabel *)[cell viewWithTag:EVENT_TITLE_TAG]).backgroundColor = 
        ((UILabel *)[cell viewWithTag:EVENT_ORGANIZER_TAG]).backgroundColor = 
        ((UILabel *)[cell viewWithTag:EVENT_PHONE_NUMBER_TAG]).backgroundColor = 
        ((UIImageView *)[cell viewWithTag:IMAGE_TAG]).backgroundColor = 
        cell.backgroundColor = [UIColor whiteColor];
    }
        
    
}


- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {

    @try {
        NSLog(@"configureCell()");
        
        /*
         Cache the formatter. Normally you would use one of the date formatter styles (such as NSDateFormatterShortStyle), but here we want a specific format that excludes seconds.
         */
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"h:mm a"];
        }
        
        // Get the event at the row selected and display it's title
        CMIEvent* cmiEvent = [self.cmiEventCalendar getCMIEventByIndexPath:indexPath.section eventIndex:indexPath.row];
        NSDate* eventStartDate = [[cmiEvent ekEvent] startDate];
        NSString* eventStartDateStr = [dateFormatter stringFromDate:eventStartDate];
        NSDate* eventEndDate = [[cmiEvent ekEvent] endDate];
        NSString* eventEndDateStr = [dateFormatter stringFromDate:eventEndDate];
        
        UILabel *label;
        UIImage *rowBackground;
        if ([self eventIsNow:cmiEvent.ekEvent] ) {
            rowBackground = [UIImage imageNamed:@"middleRowSelected.png"];            
        }
        else {
            rowBackground = [UIImage imageNamed:@"middleRow.png"];            
        }
        ((UIImageView *)cell.backgroundView).image = rowBackground;
        
        // Set the event title name.
        label = (UILabel *)[cell viewWithTag:EVENT_TITLE_TAG];
        label.text = ([[cmiEvent ekEvent] title] != nil) ? [[cmiEvent ekEvent] title] : @"New Event";// wrapper.localeName;
        
        label = (UILabel *)[cell viewWithTag:EVENT_ORGANIZER_TAG];
        label.text = ([[cmiEvent ekEvent] organizer] != nil) ? [[[cmiEvent ekEvent] organizer] name] : @"No Organizer";// wrapper.	
        
        // Set the time.
//        if ([eventEndDateStr length] > [eventStartDateStr length]) {
//            eventStartDateStr = [@" " stringByAppendingString:eventStartDateStr];
//        }

        label = (UILabel *)[cell viewWithTag:START_TIME_TAG];
        label.text = eventStartDateStr;
//        label = (UILabel *)[cell viewWithTag:TIME_SEPARATOR_TAG];
//        label.text = @"-";
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
    @finally {
        // Insert any cleanup...
    }    
    
}    

- (void) showAboutDialog
{
    [CMIUtility Log:@"showAboutDialog()"];
    
    _cmiAboutViewController = [CMIAboutViewController alloc];
    [self.navigationController pushViewController:_cmiAboutViewController animated:YES];
}
- (void) showHelpDialog
{
    [CMIUtility Log:@"showHelpDialog()"];

    _cmiHelpViewController = [[CMIHelpViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:_cmiHelpViewController animated:YES];
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
                NSLog(@"Help");
                [self showHelpDialog];
                break;
            case 1:
                NSLog(@"About"); 
                [self showAboutDialog];
                break;
            default:
                NSLog(@"Cancel");
                break;
        }
    }
    @catch (NSException * e) {
        [CMIUtility LogError:e.reason];
    }
    @finally {
        // Insert any cleanup...
    }    

}
    

@end
