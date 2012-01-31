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
	// Section title is the region name
//TODO: make this today, tomorrow and then other dates    
//	Region *region = [displayList objectAtIndex:section];
//	return region.name;
    NSString* day = [_cmiEventSystem formatDateAsDay:[_cmiEventSystem.eventDays objectAtIndex:section]];    
    return day;//[_cmiEventSystem formatDateAsDay:[_cmiEventSystem.eventDays objectAtIndex:section]];    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
	
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
    @try {

        //checking for double taps here
        if(_tapCount == 1 && _tapTimer != nil && 
           _tappedRow == indexPath.row && _tappedSection == indexPath.section){
            //double tap - Put your double tap code here            
            [_tapTimer invalidate];
            _tapTimer = nil;
            CMIEvent* cmiEvent = [_cmiEventSystem getCMIEvent:_tappedSection eventIndex:_tappedRow];
            if ([cmiEvent hasConferenceNumber] == true) {
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                _tappedRow = -1;
                _tappedSection = -1;
                [cmiEvent dial:self.view confirmCall:false];
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

- (NSArray *)fetchEventsForTable 
{
	// Create the predicate. Pass it the default calendar.
	ConferenceMeInAppDelegate *appDelegate = (ConferenceMeInAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _cmiEventSystem.fetchAllEvents = appDelegate.debugMode;
    _cmiEventSystem.calendarType = appDelegate.calendarType;
    
    return [_cmiEventSystem fetchEvents];
}

- (void)reloadTable
{
    if (_eventsList != nil) {
    //TODO: remove
    [self.eventsList removeAllObjects]; // not necessary because we're about to alloc and ARC prevents us         
    }
    self.eventsList = [CMIEvent createCMIEvents:[self fetchEventsForTable]];
	[self.tableView reloadData];    
}


- (void) scrollToNow
{
    NSDate* now = [[NSDate alloc] init];
    NSDate* currentDay = [_cmiEventSystem getMidnightDate:now];
    NSInteger currentDaySection = -1;
    NSInteger currentDayRow = 0;
    
    for (NSInteger i = 0; i < [_cmiEventSystem.eventDays count]; i++ ) {
        NSDate* date = (NSDate*)[_cmiEventSystem.eventDays objectAtIndex:i];
        if ([date isEqualToDate:currentDay] == TRUE) {
            currentDaySection = i;
            break;
        }
    }
    
    if (currentDaySection != -1) {
        NSArray* dayEvents = [_cmiEventSystem.daysEvents objectForKey:currentDay];
        for (NSDate* date in dayEvents) {            
            // If event is later than now
        }
    }
    
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:currentDayRow inSection:currentDaySection];
    [[self tableView] scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];    
}

- (void) reloadTableScrollToNow
{
    [self reloadTable];
    [self scrollToNow];
    
}

- (void) storeChanged:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    //    if ([[notification name] isEqualToString:@"TestNotification"])
    NSString* logMessage = @"Successfully received the test notification!"; 
    logMessage = [logMessage stringByAppendingString:notification.name];
    NSLog(@"Exception: %@", logMessage );

    [self reloadTableScrollToNow];
}

#pragma mark -
#pragma mark View life-cycle

- (void)viewDidLoad {
    //TODO: figure this out
    //	self.title = NSLocalizedString(@"Time Zones", @"Time Zones title");
	self.title = @"Calendar";
	self.tableView.rowHeight = ROW_HEIGHT;
    _phoneImage = [UIImage imageNamed:@"phone.png"];

    _cmiEventSystem = [[CMIEventSystem alloc] init];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeChanged:)
                                                 name:EKEventStoreChangedNotification object:_cmiEventSystem.eventStore];
    
    [self reloadTableScrollToNow];
}

#pragma mark -
#pragma mark Configuring table view cells

#define TIME_TAG 1
#define IMAGE_TAG 2
#define NAME_TAG 3

#define EVENT_TITLE_TAG 4
#define EVENT_ORGANIZER_TAG 5
#define EVENT_PHONE_NUMBER_TAG 6

//#define LEFT_COLUMN_OFFSET 10.0
//#define LEFT_COLUMN_WIDTH 160.0
//
//#define MIDDLE_COLUMN_OFFSET 170.0
//#define MIDDLE_COLUMN_WIDTH 90.0
//
//#define RIGHT_COLUMN_OFFSET 280.0
//
//#define MAIN_FONT_SIZE 18.0
//#define LABEL_HEIGHT 26.0
//
//#define IMAGE_SIDE 30.0

#define LEFT_COLUMN_OFFSET 10.0
#define LEFT_COLUMN_WIDTH 80.0

#define IMAGE_COLUMN_OFFSET 100.0
#define IMAGE_COLUMN_WIDTH 40.0

#define RIGHT_COLUMN_OFFSET 95.0
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
	UILabel *label;
	CGRect rect;
	
	// Create a label for the event time.
	rect = CGRectMake(LEFT_COLUMN_OFFSET, (ROW_HEIGHT - LABEL_HEIGHT) / 2.0, LEFT_COLUMN_WIDTH, LABEL_HEIGHT);
	label = [[UILabel alloc] initWithFrame:rect];
	label.tag = TIME_TAG;
	label.font = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
	label.adjustsFontSizeToFitWidth = NO;
	[cell.contentView addSubview:label];
	label.highlightedTextColor = [UIColor whiteColor];
	    
	UILabel *topLabel;
	UILabel *middleLabel;
	UILabel *bottomLabel;
    
    topLabel =
    [[UILabel alloc]
      initWithFrame:
      CGRectMake(
                 RIGHT_COLUMN_OFFSET,
                 LABEL_UPPER,// 0.5 * (self.tableView.rowHeight - 2 * LABEL_HEIGHT),
                 RIGHT_COLUMN_WIDTH,
                 LABEL_HEIGHT)];
    topLabel.tag = EVENT_TITLE_TAG;
//    topLabel.backgroundColor = [UIColor clearColor];
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
	[cell.contentView addSubview:imageView];
	
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    /*
	 Cache the formatter. Normally you would use one of the date formatter styles (such as NSDateFormatterShortStyle), but here we want a specific format that excludes seconds.
	 */
	static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"h:mm a"];
	}
	
	// Get the event at the row selected and display it's title
//    CMIEvent* cmiEvent = [self.eventsList objectAtIndex:indexPath.row];
    CMIEvent* cmiEvent = [self.cmiEventSystem getCMIEvent:indexPath.section eventIndex:indexPath.row];
    NSDate* eventDate = [[cmiEvent ekEvent] startDate];
    NSString* eventDateStr = [dateFormatter stringFromDate:eventDate];
//    now = [now stringByAppendingString:@" : "];
//    NSString* eventRowTitle = [now stringByAppendingString:[[[self.eventsList objectAtIndex:indexPath.row]  ekEvent] title]];            
	
//    cell.textLabel.text = eventRowTitle;// [[self.eventsList objectAtIndex:indexPath.row] title];
	
	UILabel *label;
	
    
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


@end
