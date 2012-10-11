    //
//  ConferenceMeInAppDelegate.m
//  ConferenceMeIn
//
//  Created by philip penn on 1/20/12.
//  Copyright (c) 2012 Paleon Solutions. All rights reserved.
//

#import "ConferenceMeInAppDelegate.h"
#import "CMIMasterViewController.h"
#import "CMIUtility.h"

#define EVENT_CHANGE_DELAY 0.5


@implementation ConferenceMeInAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize cmiUserDefaults = _cmiUserDefaults;
@synthesize defaultsChangedTimerWillFire = _defaultsChangedTimerWillFire;


CMIMasterViewController* _cmiMasterViewController;


- (void)defaultsChangedTimerFired:(NSTimer *)aTimer
{
    @try {
        [CMIUtility Log:@"defaultsChangedTimerFired()"];
        
        if (self.navigationController.visibleViewController == _cmiMasterViewController) {
            if ([_cmiUserDefaults allDefaultsAreIdentical] == NO ) {
                [_cmiMasterViewController invokeMegaAnnoyingPopup:NSLocalizedString(@"LoadingEventsMessage", nil)]; 
                // Next line is equivalent of old VB6's DoEvents :)
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
                [_cmiUserDefaults loadDefaults];
                [_cmiMasterViewController reloadTableScrollToNow];
            }
            else {
                [CMIUtility Log:@"Defaults were Identical -- Not Reloading"];
            }
        }
        else {
            [CMIUtility Log:@"CMI MasterView not visible, will reload later"];
            _cmiMasterViewController.reloadDefaultsOnAppear = YES;                        
        }
        
        _defaultsChangedTimerWillFire = NO;
    }
    @catch (NSException *exception) {
        [CMIUtility LogError:exception.reason];
    }

}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSUserDefaultsDidChangeNotification
                                                  object:nil];

}


// we are being notified that our preferences have changed (user changed them in the Settings app)
// so read in the changes and update our UI.
//
- (void)defaultsChanged:(NSNotification *)notification
{
    @try {
        [CMIUtility Log:[@"defaultsChanged() " stringByAppendingString:notification.name]];
        if (_cmiMasterViewController == nil)    return;

        if ([notification.name isEqualToString:NSUserDefaultsDidChangeNotification] &&
            _defaultsChangedTimerWillFire == NO) {
            
            _defaultsChangedTimerWillFire = YES;
            [NSTimer scheduledTimerWithTimeInterval:EVENT_CHANGE_DELAY target:self selector:@selector(defaultsChangedTimerFired:) userInfo:nil repeats:NO];
            
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
        _cmiMasterViewController = nil;
        _defaultsChangedTimerWillFire = NO;

        // listen for changes to our preferences when the Settings app does so,
        // when we are resumed from the backround, this will give us a chance to update our UI
        //

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(defaultsChanged:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];

        CMIMasterViewController *masterViewController = [[CMIMasterViewController alloc] init];
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

- (void)addDefaultsEventListener
{
    [CMIUtility Log:@"addDefaultsEventListener()"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(defaultsChanged:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
}
- (void)removeDefaultsEventListener
{
    [CMIUtility Log:@"removeDefaultsEventListener()"];

	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSUserDefaultsDidChangeNotification
                                                  object:nil];
    
}

- (void)saveDefaults
{
    [CMIUtility Log:@"saveDefaults()"];

    [self removeDefaultsEventListener];
    [_cmiUserDefaults saveDefaults];
    [self addDefaultsEventListener];
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    @try {
        [CMIUtility Log:@"applicationDidEnterBackground()"];

        [self saveDefaults];
        // Invalidate Refresh Timer
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
    @try {
        [CMIUtility Log:@"applicationDidBecomeActive()"];

        if (_cmiMasterViewController != nil && _cmiMasterViewController.admobIsLoaded == YES)
        {
            [_cmiMasterViewController checkCalendarPermission];
            
            // What if MVC is not visible?
            if ([CMIUtility isSameDay:[NSDate date] atDate2:_cmiMasterViewController.cmiEventCalendar.lastRefreshTime] == YES) {

                if (self.navigationController.visibleViewController == _cmiMasterViewController) {
                    [_cmiMasterViewController scrollToNow];
                }
                else {
                    _cmiMasterViewController.wakeUpAction = masterViewWakeUpScrollToNow;
                }
            }
            else {
                if (self.navigationController.visibleViewController == _cmiMasterViewController) {                    
                    [_cmiMasterViewController invokeMegaAnnoyingPopup:NSLocalizedString(@"LoadingEventsMessage", nil)];
                    [NSTimer scheduledTimerWithTimeInterval:EVENT_CHANGE_DELAY target:_cmiMasterViewController selector:@selector(refreshTimerFired:) userInfo:nil repeats:NO];
                    [_cmiMasterViewController loadAdMobBanner:nil];                    
                }
                else {
                    _cmiMasterViewController.wakeUpAction = masterViewWakeUpReload;
                }
            }
            
        }
        
    }
    @catch (NSException *exception) {
        [CMIUtility LogError:exception.reason];
    }
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

        [self saveDefaults];
    }
    @catch (NSException * e) {
        [CMIUtility LogError:e.reason];
    }
    @finally {
        // Insert any cleanup...
    }    
    
}


@end
