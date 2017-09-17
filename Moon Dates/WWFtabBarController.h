//
//  ViewController.h
//  Moon Dates
//
//  Created by Andy Guttridge on 29/05/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WWFmoonDatesManager.h"
#import "WWFcalendarViewController.h"

@interface WWFtabBarController : UITabBarController <UNUserNotificationCenterDelegate>

-(void) userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler;
-(void) userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler;

@end

