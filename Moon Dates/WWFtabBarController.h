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

@interface WWFtabBarController : UITabBarController

-(void) didReceiveNotificationWhileAppRunning: (UILocalNotification *) theNotification;
-(void) didReceiveNotificationOnAppLaunch: (UILocalNotification *) theNotification;

@end

