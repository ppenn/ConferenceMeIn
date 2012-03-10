//
//  CMIContacts.m
//  ConferenceMeIn
//
//  Created by philip penn on 3/1/12.
//  Copyright (c) 2012 Paleon Solutions. All rights reserved.
//

#import "CMIContactsController.h"
#import "CMIUtility.h"
#import "ABContact.h"
#import "ABContactsHelper.h"


contactsControllerModes _contactsControllerMode;

@implementation CMIContactsController

@synthesize viewController = _viewController;
@synthesize delegate=_delegate;
@synthesize selectedPhoneNumber = _selectedPhoneNumber;
@synthesize userDidCancel = _userDidCancel;
@synthesize conferenceNumber = _conferenceNumber;
@synthesize selectedPersonID = _selectedPersonID;

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
}

-(void)tryToGetConfNumber
{
    [CMIUtility Log:@"tryToGetConfNumber()"];
    
    _selectedPhoneNumber = nil;
    _userDidCancel = NO;
    _contactsControllerMode = contactsControllerImportNumber;
    [self showPeoplePickerController];
}

-(void)tryToSaveToContact:(NSString*)conferenceNumber
{
    [CMIUtility Log:@"tryToSaveToContact()"];
    
    _selectedPersonID = nil;
    _userDidCancel = NO;
    _contactsControllerMode = contactsControllerAddToContacts;
    _conferenceNumber = conferenceNumber;
    [self showPeoplePickerController];
    //    [self.delegate cmiContactsControllerDidFinish:self];
}

-(void)saveConferenceNumberToContact:(ABAddressBookRef) addressBook person:(ABRecordRef)person
{
    [CMIUtility Log:@"saveConferenceNumberToContact()"];
    
    _selectedPersonID = [NSNumber numberWithInteger: ABRecordGetRecordID(person)];        
    CFStringRef cfString = (__bridge CFStringRef)_conferenceNumber;
    
    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(multiPhone, cfString, kABPersonPhonePagerLabel, NULL);            
    ABRecordSetValue(person, kABPersonPhoneProperty, multiPhone,nil);
    
    // Fetch the address book ... do we need to save?
    ABAddressBookSave(addressBook, nil);  

//    CFRelease(cfString); um, guess that bridge line means don't release this...
    CFRelease(multiPhone);
//    CFRelease(addressBook);
}

#pragma mark ABPeoplePickerNavigationControllerDelegate methods
// Displays the information of a selected person
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    BOOL retval = YES;
    switch (_contactsControllerMode) {
        case contactsControllerImportNumber:
            retval = YES;        
            break;
        case contactsControllerAddToContacts:
            [self saveConferenceNumberToContact:peoplePicker.addressBook person:person];
            [_viewController dismissModalViewControllerAnimated:YES];
            [self.delegate cmiContactsControllerAddToContactsDidFinish:self];
            retval = YES;
            break;
        case contactsControllerShowContact:
            break;
        default:
            break;
    }
    return retval;
}

-(void)showSelectedContact
{
    [CMIUtility Log:@"showSelectedContact()"];
    if (_selectedPersonID == nil)   return;
    
    _contactsControllerMode = contactsControllerShowContact;

	ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook,_selectedPersonID.integerValue);        
    ABPersonViewController *picker = [[ABPersonViewController alloc] init];
    picker.personViewDelegate = self;
    picker.displayedPerson = person;
    picker.allowsEditing = NO;
    picker.allowsActions = YES;

    CFRelease(addressBook);
    [_viewController.navigationController pushViewController:picker animated:YES];

}

// Does not allow users to perform default actions such as dialing a phone number, when they select a person property.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if (_contactsControllerMode == contactsControllerImportNumber) {
        ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
        CFStringRef phone = ABMultiValueCopyValueAtIndex(multi, identifier);
        _selectedPhoneNumber = [(__bridge NSString *)phone copy];
        CFRelease(phone);
        CFRelease(multi);
        [_viewController dismissModalViewControllerAnimated:YES];
        [self.delegate cmiContactsControllerDidFinish:self];
        return YES;
    }
    else {
        return YES;
    }
}


// Dismisses the people picker and shows the application when users tap Cancel. 
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
    _userDidCancel = YES;
	[_viewController dismissModalViewControllerAnimated:YES];
}


- (BOOL) personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}

@end
