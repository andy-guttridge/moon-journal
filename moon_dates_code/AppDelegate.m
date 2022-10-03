//
//  AppDelegate.m
//  Moon Dates
//
//  Created by Andy Guttridge on 29/05/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#import "AppDelegate.h"
#import "WWFtabBarController.h"
#import "WWFmoonDatesManager.h"

@interface AppDelegate ()
@property (strong, nonatomic) WWFmoonDatesManager *sharedMoonDatesManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.sharedMoonDatesManager = [WWFmoonDatesManager sharedMoonDatesManager]; //Initialise the sharedMoonDatesManager.
    
    //Register to receive notifications
    
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    [notificationCenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionBadge + UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        //Code to respond to allowed types of notification goes here. Do nothing for now, rely on OS behaviour.
    }];
    
    //Set delegate for the UNNotificationCenter
    WWFtabBarController *theTabBarController = (WWFtabBarController *) self.window.rootViewController;
    notificationCenter.delegate = theTabBarController;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   }

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self.sharedMoonDatesManager removeOldNotificationBadge]; //We call this method on the sharedMoonDatesManager to clean up any old notification badges that are no longer relevant.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
