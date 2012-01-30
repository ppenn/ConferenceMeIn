//
//  CMIEventSystemTests.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIEventSystemTests.h"

@implementation CMIEventSystemTests

@synthesize cmiEventSystem = _cmiEventSystem;

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    _cmiEventSystem = [[CMIEventSystem alloc] init];
    
}
// All code under test must be linked into the Unit Test bundle
- (void)testFetchEvents
{
    _cmiEventSystem.fetchAllEvents = true;
    NSArray* eventsList = [_cmiEventSystem fetchEvents];
    STAssertTrue([eventsList count] > 0, @"Need some events :-(");
}

@end
