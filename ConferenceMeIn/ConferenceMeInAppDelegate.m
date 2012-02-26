    //
//  ConferenceMeInAppDelegate.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConferenceMeInAppDelegate.h"
#import "CMIMasterViewController.h"
#import "CMIUtility.h"


@implementation ConferenceMeInAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize cmiUserDefaults = _cmiUserDefaults;

CMIMasterViewController* _cmiMasterViewController;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSUserDefaultsDidChangeNotification
                                                  object:nil];

}


// we are being notified that our preferences have changed (user changed them in the Settings app)
// so read in the changes and update our UI.
//
- (void)defaultsChanged:(NSNotification *)notif
{
    @try {
        [CMIUtility Log:[@"defaultsChanged() " stringByAppendingString:notif.name]];
        // Get the user defaults

        if (self.navigationController.visibleViewController == _cmiMasterViewController) {
            [_cmiUserDefaults loadDefaults];
            [_cmiMasterViewController reloadTableScrollToNow];
        }
        else {
            [CMIUtility Log:@"CMI MasterView not visible, will reload later"];
            _cmiMasterViewController.reloadDefaultsOnAppear = YES;                        
        }
    }
    @catch (NSException * e) {
        [CMIUtility LogError:e.reason];
         }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    @try {
        [CMIUtility Log:@"didFinishLaunchingWithOptions()"];
        
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        // Override point for customization after application launch.
        _cmiUserDefaults = [[CMIUserDefaults alloc] init];
        [_cmiUserDefaults loadDefaults];

        // listen for changes to our preferences when the Settings app does so,
        // when we are resumed from the backround, this will give us a chance to update our UI
        //
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(defaultsChanged:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];

        CMIMasterViewController *masterViewController = [[CMIMasterViewController alloc] init];// bundle:nil];
        _cmiMasterViewController = masterViewController;
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
        self.window.rootViewController = self.navigationController;
        [self.window makeKeyAndVisible];
                
        return YES;
    }
    @catch (NSException * e) {
        [CMIUtility LogError:e.reason];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should urease this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    @try {
        [CMIUtility Log:@"applicationDidEnterBackground()"];

        [_cmiUserDefaults saveDefaults];
    }
    @catch (NSException * e) {
        [CMIUtility LogError:e.reason];
    }
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    @try {
        [CMIUtility Log:@"applicationWillTerminate()"];
        
        [_cmiUserDefaults saveDefaults];
    }
    @catch (NSException * e) {
        [CMIUtility LogError:e.reason];
    }
    @finally {
        // Insert any cleanup...
    }    

    @try {
        [CMIUtility Log:@"()"];
        
    }
    @catch (NSException * e) {
        [CMIUtility LogError:e.reason];
    }
    @finally {
        // Insert any cleanup...
    }    
    
    
    
}


@end
