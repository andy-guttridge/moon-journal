//
//  WWFcalendarViewControllerTableViewController.h
//  Moon Dates
//
//  Created by Andy Guttridge on 29/05/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "WWFmoonDatesManager.h"

@interface WWFcalendarViewController : UITableViewController

@property (weak, nonatomic) WWFmoonDatesManager *sharedMoonDatesManager;

@end
