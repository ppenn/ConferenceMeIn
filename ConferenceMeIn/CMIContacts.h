//
//  CMIContacts.h
//  ConferenceMeIn
//
//  Created by philip penn on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@protocol CMIContactsControllerDelegate;

@interface CMIContacts : NSObject <ABPeoplePickerNavigationControllerDelegate,
ABPersonViewControllerDelegate,
ABNewPersonViewControllerDelegate,
ABUnknownPersonViewControllerDelegate>

@property (readonly, strong) UIViewController* viewController;
@property (nonatomic, unsafe_unretained) id<CMIContactsControllerDelegate> delegate;
@property (readonly, strong) NSString* selectedPhoneNumber;
@property (readonly) BOOL userDidCancel;


- (id)initWithViewController:(UIViewController*)viewController;

- (void)tryToGetConfNumber;
- (void)showPersonViewPicker;

@end

@protocol CMIContactsControllerDelegate

-(void)cmiContactsControllerDidFinish:(CMIContacts*)viewController;

@end