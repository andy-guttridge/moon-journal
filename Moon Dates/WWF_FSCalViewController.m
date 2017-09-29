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
@property NSUInteger journalIndex; //We use this integer to hold an index for the moon dates array to access the correct journal entry.

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
    NSUInteger i = 0; // We increment this integer with each pass of the following for loop, and use it as an index into the moondates array to identify the journal entry associated with the relevant moon date if we find one.
    
    //Next we iterate through the moon dates and compare with the date given to us by the calendar to work out if this is a moon date or not.
    
    for (NSDictionary *moonDatesDictionary in self.sharedMoonDatesManager.moonDatesArray)
    {
        NSDateComponents *moonDateComponents = [[NSCalendar currentCalendar] components: NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay fromDate: [moonDatesDictionary objectForKey:@"MoonDate"]]; //Get the components of the moon date so that we can create a new version without the time included
        
        NSDate *theMoonDate = [[NSCalendar currentCalendar] dateFromComponents:moonDateComponents]; //Create a working copy of the moon date without the time included
        
        if ([date isEqualToDate:theMoonDate]) //Compare the date provided by the calendar with the moon date in the array. If it is moon date, we return YES, otherwise we return NO (as the BOOL was initially declared with a value of NO)
            {
                isMoonDate = YES;
                self.journalIndex = i; //Set journalIndex to i. Another method will use this value to access the appropriate journal entry.
                break; // If the date is a moon date, then we break out of the for loop as we have found the moon date we are interested in.
            }
        i++; //Increment the integer
    }
                                                
    return isMoonDate;
    
}

-(void) calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
// This method is called if the calendar allowed a date to be selected, in which case we perform a segue to the journal view controller to display the journal entry. The reference to the appropriate journal entry is passed to the journal view controller in - (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender .
{
    [self performSegueWithIdentifier:@"journalsegue" sender:self];    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    WWFjournalViewController *journalViewController = (WWFjournalViewController *) [segue destinationViewController]; //Get a reference to the journal view controller via the segue which is passed to this method.
    journalViewController.indexForMoonDatesArray = self.journalIndex; //Pass the index for the journal entry to the journal view controller.
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
