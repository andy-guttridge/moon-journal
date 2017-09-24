//
//  WWF_FSCalViewController.m
//  Moon Journal
//
//  Created by Andy Guttridge on 23/09/2017.
//  Copyright © 2017 Andy Guttridge. All rights reserved.
//

#import "WWF_FSCalViewController.h"

@interface WWF_FSCalViewController ()

@property (weak, nonatomic) WWFmoonDatesManager *sharedMoonDatesManager;

@end

@implementation WWF_FSCalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sharedMoonDatesManager = [WWFmoonDatesManager sharedMoonDatesManager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition;
    //This calendar method is called when the calendar wants to know if the user should be permitted to select a specific date. We will test whether the date selected corresponds with a moon date. If so then we should allow the user to select the date.
{
    BOOL isMoonDate = NO; //This is the bool value we will return to state whether the user should be able to select the date or not.
    
    //Next we iterate through the moon dates and compare with the date given to us by the calendar to work out if this is a moon date or not.
    
    for (NSDictionary *moonDatesDictionary in self.sharedMoonDatesManager.moonDatesArray)
    {
        NSDateComponents *moonDateComponents = [[NSCalendar currentCalendar] components: NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay fromDate: [moonDatesDictionary objectForKey:@"MoonDate"]]; //Get the components of the moon date so that we can create a new version without the time included
        
        NSDate *theMoonDate = [[NSCalendar currentCalendar] dateFromComponents:moonDateComponents]; //Create a working copy of the moon date without the time included
        
        if ([date isEqualToDate:theMoonDate]) //Compare the date provided by the calendar with the moon date in the array. If it is moon date, we return YES, otherwise we return NO (as the BOOL was initially declared with a value of NO)
            {
                isMoonDate = YES;
            }
        
    }
                                                
    return isMoonDate;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
