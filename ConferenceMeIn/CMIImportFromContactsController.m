//
//  CMIContacts.m
//  ConferenceMeIn
//
//  Created by philip penn on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIImportFromContactsController.h"
#import "CMIUtility.h"
#import "ABContact.h"
#import "ABContactsHelper.h"

@implementation CMIImportFromContactsController

@synthesize viewController = _viewController;
@synthesize delegate=_delegate;
@synthesize selectedPhoneNumber = _selectedPhoneNumber;
@synthesize userDidCancel = _userDidCancel;

- (id)initWithViewController:(UIViewController*)viewController
{
    [CMIUtility Log:@"initWithViewController()"];
    
    self = [super init];
    
    if (self != nil)
    {    
        _viewController = viewController;
    }
    return self;    
    
}

-(void)showPersonViewPicker
{
    [CMIUtility Log:@"showPersonViewPicker()"];
    
}

-(void)showPeoplePickerController
{
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
	// Display only a person's phone, email, and birthdate
	NSArray *displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty], 
                               [NSNumber numberWithInt:kABPersonEmailProperty],
                               [NSNumber numberWithInt:kABPersonBirthdayProperty], nil];
	
	
	picker.displayedProperties = displayedItems;
    
	// Show the picker 
	[_viewController presentModalViewController:picker animated:YES];
//    [picker release];	
}

-(void)tryToGetConfNumber
{
    [CMIUtility Log:@"tryToGetConfNumber()"];
    
    _selectedPhoneNumber = nil;
    _userDidCancel = NO;
    [self showPeoplePickerController];
//    [self.delegate cmiContactsControllerDidFinish:self];
}

#pragma mark ABPeoplePickerNavigationControllerDelegate methods
// Displays the information of a selected person
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    //	[self dismissModalViewControllerAnimated:YES];
	return YES;
}


// Does not allow users to perform default actions such as dialing a phone number, when they select a person property.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
    CFStringRef phone = ABMultiValueCopyValueAtIndex(multi, identifier);
    _selectedPhoneNumber = [(__bridge NSString *)phone copy];
    CFRelease(phone);
    
    [_viewController dismissModalViewControllerAnimated:YES];
    [self.delegate cmiContactsControllerDidFinish:self];
    return NO;
}


// Dismisses the people picker and shows the application when users tap Cancel. 
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
    _userDidCancel = YES;
	[_viewController dismissModalViewControllerAnimated:YES];
}


@end
