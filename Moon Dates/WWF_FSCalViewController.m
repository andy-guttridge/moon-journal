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
    self.sharedColoursManager = [WWFcoloursManager sharedColoursManager];
    
    self.theCalendarView.appearance.imageOffset = CGPointMake(0, 6);
    
    self.mainView.backgroundColor = self.sharedColoursManager.backgroundColour;
    self.theCalendarView.calendarWeekdayView.backgroundColor = self.sharedColoursManager.backgroundColour;
    self.theCalendarView.appearance.titlePlaceholderColor = self.sharedColoursManager.placeholderDateColour;
    self.theCalendarView.appearance.headerTitleColor = self.sharedColoursManager.headerColour;
    self.theCalendarView.appearance.weekdayTextColor = self.sharedColoursManager.headerColour;
    
    self.todayButton.tintColor = self.sharedColoursManager.selectableColour;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition;
    //This calendar method is called when the calendar wants to know if the user should be permitted to select a specific date. We use the sharedMoonDatesManager to get a dictionary containing information on whether the date is a moon date, and if so what the index of the moon date is in the moon date array. If the selected date is a moon date then we should allow the user to select the date. The index of the moon date is stored in the journal index property and passed to the journal view controller in the prepareForSegue:segue sender:sender method.
{
    NSDictionary *dateInfo = [self.sharedMoonDatesManager moonDateInfo:date];
    BOOL isMoonDate = [[dateInfo objectForKey:@"isMoonDate"] boolValue]; //Find out if the date passed in by the calendar is a moon date.
    
    if (isMoonDate == YES) //If the date is a moon date, then find out the index of the date in the moon dates array and store the index value.
    {
        self.journalIndex = [[dateInfo objectForKey:@"index"] integerValue];
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

-(nullable UIImage *) calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date
//FSCalendar uses this method to ask for an image for each date cell. If the date is a new moon or full moon, then we return an appropriate image to use as an icon, otherwise we return nil.
{
    NSDictionary *moonDateInfo = [self.sharedMoonDatesManager moonDateInfo:date]; //Get the information about this date from the sharedMoonDatesManager
    NSUInteger type = [[moonDateInfo objectForKey:@"type"] integerValue]; //If the date is a moon date get the type, if not then the value will be 0.
    
    if (type == kFullMoon) //If the moon date is a full moon, then return the full moon icon to display on the calendar.
    {
        UIImage *image = [UIImage imageNamed:@"FullMoonIcon"];
        return image;
    }
    
    else if (type == kNewMoon) //If the moon date is a new moon, then return the new moon icon to display on the calendar.
    {
        UIImage *image = [UIImage imageNamed:@"NewMoonIcon"];
        return image;
    }
    
    else
    {
        
    }
    return nil;
}

- (IBAction)goToToday:(id)sender
{
    [self.theCalendarView selectDate:[NSDate date] scrollToDate:YES];
}

- (nullable UIColor*) calendar: (FSCalendar *) calendar appearance:(nonnull FSCalendarAppearance *)appearance fillDefaultColorForDate:(nonnull NSDate *)date
{
    //Here the calendar asks for a default fill colour for dates
    return self.sharedColoursManager.backgroundColour;
}

- (nullable UIColor*) calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date
{
    //Here the calendar asks for a default border colour for dates
    return self.sharedColoursManager.backgroundColour;
}

- (nullable UIColor*) calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(nonnull NSDate *)date:(NSDate *)date
{
    //Here the calendar asks for the default text colour for dates
    return self.sharedColoursManager.textColour;
}

- (nullable UIColor*) calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date
{
    //Here the calendar asks for a border colour for selected dates
    return self.sharedColoursManager.selectableColour;
}

- (nullable UIColor*) calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillSelectionColorForDate:(NSDate *)date
{
    //Here the calendar asks for the fill colour for a selected date
    return self.sharedColoursManager.textColour;
}

- (nullable UIColor*) calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleSelectionColorForDate:(NSDate *)date
{
    //Here the calendar asks for the main text colour for a selected date
    return self.sharedColoursManager.backgroundColour;
}

- (nullable UIColor*) calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date
{
    //Here the calendar asks for the default text colour for a date
    return self.sharedColoursManager.textColour;
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
