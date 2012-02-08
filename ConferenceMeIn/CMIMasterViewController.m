//
//  CMIMasterViewController.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIMasterViewController.h"

#define ROW_HEIGHT 80

static UIImage *_phoneImage;
NSInteger _tapCount = 0;
NSInteger _tappedRow = 0;
NSInteger _tappedSection = 0;
NSTimer* _tapTimer;

@implementation CMIMasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize eventsList = _eventsList;
@synthesize cmiEventSystem = _cmiEventSystem;


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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
	// Number of sections is the number of regions
    NSInteger numSections = [_cmiEventSystem.daysEvents count];
    return numSections;
}

//TODO: sort this out per section...when sections arrive
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray* events = [_cmiEventSystem.daysEvents objectForKey:[_cmiEventSystem.eventDays objectAtIndex:section]];
    return [events count];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
    NSLog(@"titleForHeaderInSection()");
	
    // Section title is the region name
//TODO: make this today, tomorrow and then other dates    
//	Region *region = [displayList objectAtIndex:section];
//	return region.name;
    NSString* day = [_cmiEventSystem formatDateAsDay:[_cmiEventSystem.eventDays objectAtIndex:section]];    
    return day;//[_cmiEventSystem formatDateAsDay:[_cmiEventSystem.eventDays objectAtIndex:section]];    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {

	NSLog(@"cellForRowAtIndexPath()");
    
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

- (void)showEventNatively:(NSInteger)section row:(NSInteger)row
{
    NSLog(@"showEventNatively()");
    
    self.detailViewController = [[CMIEKEventViewController alloc] initWithNibName:nil bundle:nil];        
    CMIEvent* cmiEvent = [self.cmiEventSystem getCMIEvent:section eventIndex:row];
    _detailViewController.event = [cmiEvent ekEvent];
    
    _detailViewController.allowsEditing = YES;
    _detailViewController.detailItem = cmiEvent;
    //	Push detailViewController onto the navigation controller stack
    //	If the underlying event gets deleted, detailViewController will remove itself from
    //	the stack and clear its event property.
    [self.navigationController pushViewController:_detailViewController animated:YES];

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
            CMIEvent* cmiEvent = [_cmiEventSystem getCMIEvent:_tappedSection eventIndex:_tappedRow];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            _tappedRow = -1;
            _tappedSection = -1;
            if ([cmiEvent hasConferenceNumber] == true) {
                [cmiEvent dial:self.view confirmCall:false];
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
	ConferenceMeInAppDelegate *appDelegate = (ConferenceMeInAppDelegate *)[[UIApplication sharedApplication] delegate];

    if (appDelegate.firstRun == true) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ConferenceMeIn" message:@"Double-tap calendar item to dial # directly. Single-tap item to see event details and dial number "
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
    }
}

- (NSArray *)fetchEventsForTable 
{
    NSLog(@"fetchEventsForTable()");

	// Create the predicate. Pass it the default calendar.
	ConferenceMeInAppDelegate *appDelegate = (ConferenceMeInAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _cmiEventSystem.fetchAllEvents = appDelegate.debugMode;
    _cmiEventSystem.calendarType = appDelegate.calendarType;
    
    return [_cmiEventSystem fetchEvents];
}

- (void)reloadTable
{
    NSLog(@"reloadTable()");

    if (_eventsList != nil) {
    //TODO: remove
    [self.eventsList removeAllObjects]; // not necessary because we're about to alloc and ARC prevents us         
    }
    self.eventsList = [CMIEvent createCMIEvents:[self fetchEventsForTable]];
	[self.tableView reloadData];    
}


- (void) scrollToNow
{
    NSLog(@"scrollToNow()");
    
    NSDate* now = [[NSDate alloc] init];
    NSDate* currentDay = [_cmiEventSystem getMidnightDate:now];
    NSInteger currentDaySection = -1;
    NSInteger currentDayRow = -1;
    
    for (NSInteger i = 0; i < [_cmiEventSystem.eventDays count]; i++ ) {
        NSDate* date = (NSDate*)[_cmiEventSystem.eventDays objectAtIndex:i];
        if ([date isEqualToDate:currentDay] == TRUE) {
            currentDaySection = i;
            break;
        }
    }
    
    if (currentDaySection != -1) {
        NSArray* events = [_cmiEventSystem.daysEvents objectForKey:currentDay];
        if (events.count > 0) {
            for (currentDayRow = 0; currentDayRow < (events.count -1); currentDayRow++) {
                CMIEvent* event = [events objectAtIndex:currentDayRow];            
                // If event is current
                if ([CMIEventSystem date:now isBetweenDate:event.ekEvent.startDate andDate:event.ekEvent.endDate] == true) {
                    break;
                }
                // if current event is later than now, then bail too
                if ([now compare:event.ekEvent.startDate] == NSOrderedAscending ||
                    [now compare:event.ekEvent.startDate] == NSOrderedSame) {
                    break;
                }
            }
        }
    }
    
    if (currentDayRow > -1) {
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:currentDayRow inSection:currentDaySection];
        [[self tableView] scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];  
    }    
}

- (void) reloadTableScrollToNow
{
    NSLog(@"reloadTableScrollToNow()");

    [self reloadTable];
    [self scrollToNow];
    
}



- (void) storeChanged:(NSNotification *) notification
{
    NSLog(@"storeChanged() notification  [ %@ ] ", notification.name);

    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    //    if ([[notification name] isEqualToString:@"TestNotification"])
    NSString* logMessage = @"Successfully received the test notification!"; 
    logMessage = [logMessage stringByAppendingString:notification.name];
    NSLog(@"Exception: %@", logMessage );

    [self reloadTableScrollToNow];
}

- (void)menuAction:(id)sender
{
	// open a dialog with just an OK button
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Menu"
                                                             delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"HelpButtonTitle",@""),@"About",nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view];	// show from our table view (pops up in the middle of the table)
    
}
- (void) createMenuButton
{
    // add tint bar button
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(menuAction:)];
    self.navigationItem.leftBarButtonItem = menuButton;
}


#pragma mark -
#pragma mark View life-cycle

- (void)viewDidLoad {
    NSLog(@"viewDidLoad()");
    
    //TODO: figure this out
    //	self.title = NSLocalizedString(@"Time Zones", @"Time Zones title");
	self.title = @"Calendar";
    [self createMenuButton];
    
	self.tableView.rowHeight = ROW_HEIGHT;
    _phoneImage = [UIImage imageNamed:@"phone.png"];

    _cmiEventSystem = [[CMIEventSystem alloc] init];
    [CMIEventSystem createTestEvents:_cmiEventSystem.eventStore];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeChanged:)
                                                 name:EKEventStoreChangedNotification object:_cmiEventSystem.eventStore];

    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;    
    self.view.autoresizesSubviews = true;
    self.tableView.autoresizesSubviews = true;
    
    [self reloadTableScrollToNow];
    
    [self showStartDialog];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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

#define LEFT_COLUMN_OFFSET 10.0
#define LEFT_COLUMN_WIDTH 80.0

#define IMAGE_COLUMN_OFFSET 100.0
#define IMAGE_COLUMN_WIDTH 40.0

#define RIGHT_COLUMN_OFFSET 90.0
#define RIGHT_COLUMN_WIDTH 205.0

#define ORGANIZER_WIDTH 100.0

#define MAIN_FONT_SIZE 16.0
#define TIME_FONT_SIZE 24.0
#define LABEL_HEIGHT 26.0

#define LABEL_UPPER 2.0
#define LABEL_MIDDLE 28.0
#define LABEL_LOWER 54.0

#define IMAGE_SIDE 15.0

- (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier {
	
	/*
	 Create an instance of UITableViewCell and add tagged subviews for the name, local time, and quarter image of the time zone.
	 */
    
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
	/*
	 Create labels for the text fields; set the highlight color so that when the cell is selected it changes appropriately.
     */
	UILabel *timeLabel;
	CGRect rect;

//	// Create a label for the event time.
//	rect = CGRectMake(0, 0, RIGHT_COLUMN_OFFSET, ROW_HEIGHT);
//	timeLabel = [[UILabel alloc] initWithFrame:rect];
//	timeLabel.tag = DUMMY_LEFT_CELL_TAG;
//	[cell.contentView addSubview:timeLabel];
	
	// Create a label for the event time.
	rect = CGRectMake(LEFT_COLUMN_OFFSET, (ROW_HEIGHT - LABEL_HEIGHT) / 2.0, LEFT_COLUMN_WIDTH, LABEL_HEIGHT);
	timeLabel = [[UILabel alloc] initWithFrame:rect];
	timeLabel.tag = TIME_TAG;
	timeLabel.font = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
	timeLabel.adjustsFontSizeToFitWidth = NO;
	[cell.contentView addSubview:timeLabel];
	timeLabel.highlightedTextColor = [UIColor whiteColor];
    timeLabel.backgroundColor = [UIColor clearColor];
	    
	UILabel *topLabel;
	UILabel *middleLabel;
	UILabel *bottomLabel;
    
    topLabel =
    [[UILabel alloc]
      initWithFrame:
      CGRectMake(
                 RIGHT_COLUMN_OFFSET,
                 0.333333 * (self.tableView.rowHeight - 3 * LABEL_HEIGHT), //LABEL_UPPER,//
                 self.tableView.bounds.size.width - (2 * cell.indentationWidth) - RIGHT_COLUMN_OFFSET,
                 LABEL_HEIGHT)];
    topLabel.tag = EVENT_TITLE_TAG;
    topLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth; 
    topLabel.backgroundColor = [UIColor clearColor];
//    topLabel.textColor = [UIColor colorWithRed:0.25 green:0.0 blue:0.0 alpha:1.0];
//    topLabel.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
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

//TODO: MOVE this somewhere...parameterize
- (BOOL) eventIsNow:(EKEvent*) event
{
    NSDate* now = [[NSDate alloc] init];
    // endDate is 1 day = 60*60*24 seconds = 86400 seconds from startDate
    NSDate* trueStartDate = [NSDate dateWithTimeInterval:-(15*60) sinceDate:event.startDate];

    return [CMIEventSystem date:now isBetweenDate:trueStartDate andDate:event.endDate];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell1:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMIEvent* cmiEvent = [self.cmiEventSystem getCMIEvent:indexPath.section eventIndex:indexPath.row];

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
    CMIEvent* cmiEvent = [self.cmiEventSystem getCMIEvent:indexPath.section eventIndex:indexPath.row];
    NSDate* eventStartDate = [[cmiEvent ekEvent] startDate];
    NSDate* eventEndDate = [[cmiEvent ekEvent] endDate];
    NSString* eventDateStr = [dateFormatter stringFromDate:eventStartDate];
    
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
	label = (UILabel *)[cell viewWithTag:TIME_TAG];
	label.text = eventDateStr;// [dateFormatter stringFromDate:[NSDate date]];
	
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

#pragma mark -
#pragma mark - UIActionSheetDelegate
    
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // the user clicked one of the OK/Cancel buttons
    switch (buttonIndex) {
        case 0:
            NSLog(@"Help");
            break;
        case 1:
            NSLog(@"About");            
            break;
        default:
            NSLog(@"Cancel");
            break;
    }
}
    

@end
