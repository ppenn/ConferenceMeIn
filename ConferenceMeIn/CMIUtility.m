//
//  CMIUtility.m
//  ConferenceMeIn
//
//  Created by philip penn on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMIUtility.h"

@implementation CMIUtility

+ (void)Log:(NSString*)logMessage
{
    NSLog(@"%@", logMessage);
}

+ (void)LogError:(NSString*)logMessage
{
    NSLog(@"%@", logMessage);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:logMessage
                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];    
}

@end
