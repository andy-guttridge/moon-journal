//
//  WWF_FSCalViewController.h
//  Moon Journal
//
//  Created by Andy Guttridge on 23/09/2017.
//  Copyright © 2017 Andy Guttridge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"
#import "WWFmoonDatesManager.h"
#import "WWFjournalViewController.h"

@interface WWF_FSCalViewController : UIViewController
<FSCalendarDataSource, FSCalendarDelegate>

@property (weak, nonatomic) IBOutlet FSCalendar *theCalendarView;

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition;

@end
