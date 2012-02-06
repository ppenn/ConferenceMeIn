//
//  ConferenceMeInMasterViewController.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConferenceMeInMasterViewController.h"

#import "ConferenceMeInDetailViewController.h"
#import "ConferenceMeInAppDelegate.h"

#define ROW_HEIGHT 60


@implementation ConferenceMeInMasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize eventsList, eventStore, defaultCalendar;

@synthesize imageView = _imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Events", @"Events");
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark -
#pragma mark Table view data source

// Fetching events happening in the next 24 hours with a predicate, limiting to the default calendar 
- (NSArray *)fetchEventsForToday {
	
	// Create the predicate. Pass it the default calendar.
	ConferenceMeInAppDelegate *appDelegate = (ConferenceMeInAppDelegate *)[[UIApplication sharedApplication] delegate];

	NSDate *startDate = nil;
    if (appDelegate.debugMode == true)
    {
        //TODO: date arithmetic
        NSString *dateStrStart = @"20120101";    
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyyMMdd"];
        startDate = [dateFormat dateFromString:dateStrStart];  	
    }
    else
    {
        startDate = [NSDate date]; 
    }
	
	// endDate is 1 day = 60*60*24 seconds = 86400 seconds from startDate
	NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:86400];
	

    NSInteger calendarType = appDelegate.calendarType;
    NSArray* calendarArray = nil; // All calendars
    NSPredicate *predicate;
    if (calendarType == defaultCalendarType)
    {
        calendarArray = [NSArray arrayWithObject:defaultCalendar];
        predicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate 
                                                                        calendars:calendarArray]; 
    }
    else
    {
        predicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate 
                                                                        calendars:nil]; 
        
    }
	
	// Fetch all events that match the predicate.
	NSArray *events = [self.eventStore eventsMatchingPredicate:predicate];
    
//    NSString *nsString = [((EKCalendarItem*)[events objectAtIndex:0]) notes];
    
	return events;
}

- (void) storeChanged:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
//    if ([[notification name] isEqualToString:@"TestNotification"])
    NSString* logMessage = @"Successfully received the test notification!"; 
    logMessage = [logMessage stringByAppendingString:notification.name];
    NSLog(@"%@", logMessage );
//    [self.eventStore refreshSourcesIfNecessary];
    [self.eventsList removeAllObjects];
	[self.eventsList addObjectsFromArray:[self fetchEventsForToday]];    
	[self.tableView reloadData];
}

- (void) dealloc
{
    // unregister for this notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidFinishLaunchingNotification object:nil]; 

}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
        
	// Do any additional setup after loading the view, typically from a nib.
    self.tableView.rowHeight = ROW_HEIGHT;
	// watch when the app has finished launching so we can update our preference settings and apply them to the UI
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSettings:) 
                                                 name:UIApplicationDidFinishLaunchingNotification object:nil];
    
	self.title = @"Calendar Items";	
	// Initialize an event store object with the init method. Initilize the array for events.
	self.eventStore = [[EKEventStore alloc] init];
    	
	// Get the default calendar from store.
	self.defaultCalendar = [self.eventStore defaultCalendarForNewEvents];
	
	//	Create an Add button 
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeChanged:)
                                                 name:EKEventStoreChangedNotification object:eventStore];
//	self.navigationController.delegate = self;

	[self reloadTable];
}

- (void)reloadTable
{
    [self.eventsList removeAllObjects]; // not necessary because we're about to alloc and ARC prevents us from deallocing
    self.eventsList = [CMIEvent createCMIEvents:[self fetchEventsForToday]];
	[self.tableView reloadData];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.eventsList = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -
#pragma mark Table View

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return eventsList.count;
}

- (void)updateSettings:(NSNotification *)notif
{
    NSLog(@"updateSettings");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"h:mm a"];
	}
	
	// Add disclosure triangle to cell
	UITableViewCellAccessoryType editableCellAccessoryType =UITableViewCellAccessoryDisclosureIndicator;
    
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CellIdentifier];
	}
	
	cell.accessoryType = editableCellAccessoryType;
    
	// Get the event at the row selected and display it's title
    NSDate* eventDate = [[[self.eventsList objectAtIndex:indexPath.row] ekEvent] startDate];
    NSString* now = [dateFormatter stringFromDate:eventDate];
    now = [now stringByAppendingString:@" : "];
    NSString* eventRowTitle = [now stringByAppendingString:[[[self.eventsList objectAtIndex:indexPath.row]  ekEvent] title]];            
	
    cell.textLabel.text = eventRowTitle;// [[self.eventsList objectAtIndex:indexPath.row] title];
    
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	// Upon selecting an event, create an EKEventViewController to display the event.
//	self.detailViewController = [[EKEventViewController alloc] initWithNibName:nil bundle:nil];			
//	detailViewController.event = [self.eventsList objectAtIndex:indexPath.row];
	
	// Allow event editing.
//	detailViewController.allowsEditing = YES;
	
	//	Push detailViewController onto the navigation controller stack
	//	If the underlying event gets deleted, detailViewController will remove itself from
	//	the stack and clear its event property.
//	[self.navigationController pushViewController:detailViewController animated:YES];
    
//}


// Customize the appearance of table view cells.
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    // Configure the cell.
    cell.textLabel.text = NSLocalizedString(@"Detail", @"Detail");
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        
        self.detailViewController = [[CMIEKEventViewController alloc] initWithNibName:nil bundle:nil];        
        _detailViewController.event = [[self.eventsList objectAtIndex:indexPath.row] ekEvent];

        _detailViewController.allowsEditing = YES;
        _detailViewController.detailItem = [self.eventsList objectAtIndex:indexPath.row];
        //	Push detailViewController onto the navigation controller stack
        //	If the underlying event gets deleted, detailViewController will remove itself from
        //	the stack and clear its event property.
        [self.navigationController pushViewController:_detailViewController animated:YES];
        
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e); 
    }
    @finally {
        // Added to show finally works as well
    }    
}

@end
