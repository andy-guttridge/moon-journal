//
//  ViewController.h
//  Moon Dates
//
//  Created by Andy Guttridge on 29/05/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WWFmoonDatesManager.h"

@interface WWFtabBarController : UITabBarController

-(void) didReceiveNotification: (UILocalNotification *) theNotification;

@end

