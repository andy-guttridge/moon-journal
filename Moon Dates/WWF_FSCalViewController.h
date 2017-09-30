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
#import "WWFcoloursManager.h"

@interface WWF_FSCalViewController : UIViewController
<FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance>

@property (weak, nonatomic) IBOutlet FSCalendar *theCalendarView;
@property (weak, nonatomic) WWFcoloursManager *sharedColoursManager;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *todayButton;

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition;

- (IBAction)goToToday:(id)sender;

@end
