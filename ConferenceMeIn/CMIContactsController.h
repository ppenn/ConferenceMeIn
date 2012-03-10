//
//  CMIContacts.h
//  ConferenceMeIn
//
//  Created by philip penn on 3/1/12.
//  Copyright (c) 2012 Paleon Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


typedef enum contactsControllerModes
{
    contactsControllerImportNumber = 0,
    contactsControllerAddToContacts,
    contactsControllerShowContact
}contactsControllerModes;



@protocol CMIContactsControllerDelegate;

@interface CMIContactsController : NSObject <ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate>

@property (readonly, strong) UIViewController* viewController;
@property (nonatomic, unsafe_unretained) id<CMIContactsControllerDelegate> delegate;
@property (readonly, strong) NSString* selectedPhoneNumber;
@property (readonly) BOOL userDidCancel;
@property (readonly, strong) NSString* conferenceNumber;
@property (readonly, strong) NSNumber* selectedPersonID;

- (id)initWithViewController:(UIViewController*)viewController;

- (void)tryToGetConfNumber;
- (void)showPersonViewPicker;
- (void)tryToSaveToContact:(NSString*)conferenceNumber;
- (void)showSelectedContact;

@end

@protocol CMIContactsControllerDelegate

-(void)cmiContactsControllerDidFinish:(CMIContactsController*)viewController;
-(void)cmiContactsControllerAddToContactsDidFinish:(CMIContactsController*)viewController;

@end