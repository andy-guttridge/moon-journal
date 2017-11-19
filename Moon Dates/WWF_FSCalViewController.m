//
//  WWF_FSCalViewController.m
//  Moon Journal
//
//  Created by Andy Guttridge on 23/09/2017.
//  Copyright © 2017 Andy Guttridge. All rights reserved.
//

#import "WWF_FSCalViewController.h"

@interface WWF_FSCalViewController ()

@property (weak, nonatomic) WWFmoonDatesManager *sharedMoonDatesManager; //Used to hold a reference to the shared moon dates manager.
@property NSUInteger journalIndex; //We use this integer to hold an index for the moon dates array to access the correct journal entry.
@property (copy) NSDictionary *moonDateInfo; //We use this to hold a dictionary containing information about a specific moon date, which is used to inform the FSCalendar of how to format each date cell.


@end

@implementation WWF_FSCalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sharedMoonDatesManager = [WWFmoonDatesManager sharedMoonDatesManager];
    self.sharedColoursManager = [WWFcoloursManager sharedColoursManager];
    
    //Here we register to received UIApplicationWillEnterForegroundNotification and call the [self redrawCalendar] method, to ensure that the calendar is redrawn if the user switches back to our app having been using a different app, locked their device etc.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (redrawCalendar) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //Set up display properties of our calendar, e.g. colours, scroll direction etc.
    
    self.theCalendarView.scrollDirection = FSCalendarScrollDirectionVertical;
    
    self.theCalendarView.appearance.titleOffset = CGPointMake(0, -4);
    
    self.mainView.backgroundColor = self.sharedColoursManager.backgroundColour;
    self.theCalendarView.calendarWeekdayView.backgroundColor = self.sharedColoursManager.backgroundColour;
    self.theCalendarView.appearance.titlePlaceholderColor = self.sharedColoursManager.placeholderDateColour;
    self.theCalendarView.appearance.headerTitleColor = self.sharedColoursManager.headerColour;
    self.theCalendarView.appearance.weekdayTextColor = self.sharedColoursManager.headerColour;
    self.theCalendarView.appearance.todayColor = self.sharedColoursManager.headerColour;
    
    self.todayButton.tintColor = self.sharedColoursManager.selectableColour;
    
    self.moonDateInfo = [self.sharedMoonDatesManager moonDateInfo:[NSDate dateWithTimeIntervalSinceNow:0]]; //Initialise our moon date info dictionary
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) redrawCalendar
{
    //This method refreshes the calendar data.
    [self.theCalendarView reloadData];
}

- (void) viewWillAppear:(BOOL)animated
//This method is implemented to ensure that the calendar view is refreshed if the user returns to the calendar from another view
{
    NSLog(@"WWF_FSCalViewController viewWillAppear called.");
    [super viewWillAppear:animated];
    [self redrawCalendar];
    [self.theCalendarView deselectDate:[self.sharedMoonDatesManager.moonDatesArray [self.journalIndex] objectForKey:@"MoonDate"]]; //Here we ask the calendar to deselect the date corresponding to the current moon date array index stored within this object. This ensures that the moon date is deselected in the calendar when we return from another view, e.g. the journal view.
}

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
//Here the calendar asks for the end date for the calendar
{
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:kCalendarStartDate];
    return startDate;
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
//Here the calendar asks for the end date for the calendar
{
    NSDate *endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:kCalendarEndDate];
    return endDate;
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition;
    //This calendar method is called when the calendar wants to know if the user should be permitted to select a specific date. We use the sharedMoonDatesManager to get a dictionary containing information on whether the date is a moon date, and if so what the index of the moon date is in the moon date array. If the selected date is a moon date then we should allow the user to select the date. The index of the moon date is stored in the journal index property and passed to the journal view controller in the prepareForSegue:segue sender:sender method.
{
    if (([[self.moonDateInfo objectForKey:@"date"] isEqualToDate:date]) == NO)
    {
        self.moonDateInfo = [self.sharedMoonDatesManager moonDateInfo:date];
    }
    
    BOOL isMoonDate = [[self.moonDateInfo objectForKey:@"isMoonDate"] boolValue]; //Find out if the date passed in by the calendar is a moon date.
    
    if (isMoonDate == YES) //If the date is a moon date, then find out the index of the date in the moon dates array and store the index value.
    {
        self.journalIndex = [[self.moonDateInfo objectForKey:@"index"] integerValue];
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
    //Check that the moon date info currently stored in the calendar view controller relates to the date passed in by the calendar. If note, ask the moon dates manager for the info for the correct date. We do this to ensure that each FSCalendar delegate method that requires this information only asks for it if it is needed, otherwise if every method asks for the information for every calendar cell, the performance of the calendar view is negatively impacted.
    if (([[self.moonDateInfo objectForKey:@"date"] isEqualToDate:date]) == NO)
    {
        self.moonDateInfo = [self.sharedMoonDatesManager moonDateInfo:date];
    }
    
    NSUInteger type = [[self.moonDateInfo objectForKey:@"type"] integerValue]; //If the date is a moon date get the type, if not then the value will be 0.
    BOOL canLetItGo = [[self.moonDateInfo objectForKey:@"canLetItGo"] boolValue]; //Find out whether the date is within the Let It Go range witin which the ritual can be performed.
    BOOL released = [[self.moonDateInfo objectForKey:@"released"] boolValue]; //Find out whether the journal entry for this date has been performed.
    
    if ((type == kFullMoon) && (!canLetItGo)) //If the moon date is a full moon and the date is not within the Let It Go range, then return the standard full moon icon to display on the calendar.
    {
        UIImage *image = [UIImage imageNamed:@"FullMoonIcon"];
        return image;
    }
    
    else if ((type ==kFullMoon) && (canLetItGo)) //If the moon date is a full moon and the date is  within the Let It Go range then we need to find out whether the ritual has been performed for the corresponding journal entry.
    {
        if (!released)
        {
            //If the journal entry for this date hasn't been released yet, then the cell will be highlighted and we will need to return the inverse icon image.
            UIImage *image = [UIImage imageNamed: @"FullMoonInverseIcon"];
            return image;
        }
        
        else
        {
            //Otherwise the journal entry has been been released and we return the standard full moon icon image.
            UIImage *image = [UIImage imageNamed: @"FullMoonIcon"];
            return image;
        }
    }
    
    else if ((type == kNewMoon) && (!canLetItGo)) //If the moon date is a new moon and the date is not within the Let It Go range, then return the standard new moon icon to display on the calendar.
    {
        UIImage *image = [UIImage imageNamed:@"NewMoonIcon"];
        return image;
    }
    
    else if ((type == kNewMoon) && (canLetItGo)) //If the moon date is a new moon and the date is  within the Let It Go range then we need to find out whether the ritual has been performed for the corresponding journal entry.

    {
        if (!released)
        {
            //If the journal entry for this date hasn't been released yet, then the cell will be highlighted and we will need to return the inverse icon image.
            UIImage *image = [UIImage imageNamed:@"NewMoonInverseIcon"];
            return image;
        }
        
        else
        
        {
            //Otherwise return the standard icon.
            UIImage *image = [UIImage imageNamed:@"NewMoonIcon"];
            return image;
        }
    }
    
    else
    {
        return nil;
    }
    
}

- (IBAction)goToToday:(id)sender
{
    //This method is called when the today button on the calendar is pressed, and selects and scrolls to the current date. We instantly deselect the date as we don't want it to appear highlighted in the selected date colour.
    NSDate *today = [NSDate date]; //Get today's date
    [self.theCalendarView selectDate:today scrollToDate:YES];
    [self.theCalendarView deselectDate:today];
}

- (nullable UIColor*) calendar: (FSCalendar *) calendar appearance:(nonnull FSCalendarAppearance *)appearance fillDefaultColorForDate:(nonnull NSDate *)date
{
    //Here the calendar asks for a default fill colour for dates
    
    if (([[self.moonDateInfo objectForKey:@"date"] isEqualToDate:date]) == NO)
        //Check that the moon date info currently stored in the calendar view controller relates to the date passed in by the calendar. If note, ask the moon dates manager for the info for the correct date. We do this to ensure that each FSCalendar delegate method that requires this information only asks for it if it is needed, otherwise if every method asks for the information for every calendar cell, the performance of the calendar view is negatively impacted.
    {
        self.moonDateInfo = [self.sharedMoonDatesManager moonDateInfo:date];
    }
    
    BOOL canLetItGo = [[self.moonDateInfo objectForKey:@"canLetItGo"] boolValue]; //Extract the information on whether the date is within the 'Let It Go' range within which the ritual can be performed.
    BOOL released = [[self.moonDateInfo objectForKey:@"released"] boolValue]; //Extract the information on whether the ritual has been performed for this journal entry.
    
    NSLog (@"%d", released);
    
    if ((canLetItGo) && (!released)) //If we are within the Let It Go range, and the journal entry as not been released, then return our highlighted colour to indicate that the ritual can be performed
    {
        return self.sharedColoursManager.highlightColour;
    }
    
    else //If the date is not within the Let It Go range, then return the standard background colour.
    {
        return self.sharedColoursManager.backgroundColour;
        
    }
    
    
}

- (nullable UIColor*) calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date
{
    //Here the calendar asks for a default border colour for dates
    
    NSDate *today = [NSDate date]; //Get todays date.
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:today]; //Get the components of todays date without the time units so that we can recompose it without the time included.
    NSDate *todayWithoutTime = [[NSCalendar currentCalendar] dateFromComponents:todayComponents]; //Create a new NSDate from the components of today's date.
    
    NSDateComponents *calendarDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date]; //Get the components of the date passed in by the calendar without the time units so that we can recompose it without the time included.
    NSDate *calendarDateWithoutTime = [[NSCalendar currentCalendar] dateFromComponents:calendarDateComponents]; //Create a new NSDate from the components of the date passed in by the calendar.
    
    if ([todayWithoutTime isEqualToDate:calendarDateWithoutTime])
    
        //If the date passed in by the calendar is today's date, then we return our standard header colour from the shared colours manager.
    {
        return self.sharedColoursManager.headerColour;
    }
    
    else
        
        //Otherwise we return the standard background colour from our shared colours manager so that the date cell appears with no border.
    {
        return self.sharedColoursManager.backgroundColour;
    }
    
}

- (nullable UIColor*) calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(nonnull NSDate *)date
{
    //Here the calendar asks for the default text colour for dates. If the date is within the Let It Go range AND the journal entry for this date has not been released, then we return the background colour so that the text stands out against the highlighted cell. Otherwise we return our standard text colour.
    
    if (([[self.moonDateInfo objectForKey:@"date"] isEqualToDate:date]) == NO)
        //Check that the moon date info currently stored in the calendar view controller relates to the date passed in by the calendar. If note, ask the moon dates manager for the info for the correct date. We do this to ensure that each FSCalendar delegate method that requires this information only asks for it if it is needed, otherwise if every method asks for the information for every calendar cell, the performance of the calendar view is negatively impacted.
    {
        self.moonDateInfo = [self.sharedMoonDatesManager moonDateInfo:date];
    }
    
    BOOL canLetItGo = [[self.moonDateInfo objectForKey:@"canLetItGo"] boolValue]; //Extract the information on whether the date is within the 'Let It Go' range within which the ritual can be performed.
    BOOL released = [[self.moonDateInfo objectForKey:@"released"] boolValue]; //Find out whether the moon date ritual has already been performed for this date.
    
    if ((canLetItGo) && (!released)) //If we are within the Let It Go range, and the journal entry for this date has not been released, then return our standard background colour
    {
        return self.sharedColoursManager.backgroundColour;
    }
    
    NSDate *today = [NSDate dateWithTimeIntervalSinceNow:0]; //Get todays date
    NSDateComponents *todaysDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth| NSCalendarUnitYear fromDate:today]; //Get the components of todays date without the time included.
    NSDate *todayWithoutTime = [[NSCalendar currentCalendar] dateFromComponents:todaysDateComponents]; //Reconstitute todays date without the time.
    
    NSDateComponents *datePassedInComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth| NSCalendarUnitYear fromDate:date]; //Get the components of the date passed in by the calendar without the time included.
    NSDate *datePassedInWithoutTime = [[NSCalendar currentCalendar] dateFromComponents:datePassedInComponents]; //Reconstitute the date passed in without the time.
    
    if ([datePassedInWithoutTime isEqualToDate: todayWithoutTime])
    //If the date passed in by the calendar is todays date then return the highlight colour to highlight today's date on the calendar.
     {
         return self.sharedColoursManager.highlightColour;
     }
    
    else
    {
        return self.sharedColoursManager.textColour; //Otherwise return the standard text colour
    }
    
}

- (nullable UIColor*) calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date
{
    //Here the calendar asks for a border colour for selected dates, which is the background colour as we don't want a border for selected dates
    return self.sharedColoursManager.backgroundColour;
}

- (nullable UIColor*) calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillSelectionColorForDate:(NSDate *)date
{
    //Here the calendar asks for the fill colour for a selected date. If the date is not within the Let It Go range then we return the standard selectable item colour, if it is within the Let It Go range then we return a highlight colour.
    
    if (([[self.moonDateInfo objectForKey:@"date"] isEqualToDate:date]) == NO)
    {
        self.moonDateInfo = [self.sharedMoonDatesManager moonDateInfo:date];
    }
    
    
    BOOL canLetItGo = [[self.moonDateInfo objectForKey:@"canLetItGo"] boolValue]; //Extract the information on whether the date is within the 'Let It Go' range within which the ritual can be performed.
    
    if (canLetItGo) //If we are within the Let It Go range, then return our highlighted colour to indicate that the ritual can be performed
    {
        return self.sharedColoursManager.highlightColour;
    }
    
    else
    {
        return self.sharedColoursManager.selectableColour;
    }

    
}

- (nullable UIColor*) calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleSelectionColorForDate:(NSDate *)date
{
    //Here the calendar asks for the main text colour for a selected date. If teh date is within the Let It Go range, then we return our standard background colour, if it isn't then we return our standard text colour, or the highlighted colour if the date is today.
    
    //Here the calendar asks for a default fill colour for dates
    
    
    if (([[self.moonDateInfo objectForKey:@"date"] isEqualToDate:date]) == NO)
        //Check that the moon date info currently stored in the calendar view controller relates to the date passed in by the calendar. If note, ask the moon dates manager for the info for the correct date. We do this to ensure that each FSCalendar delegate method that requires this information only asks for it if it is needed, otherwise if every method asks for the information for every calendar cell, the performance of the calendar view is negatively impacted.
    {
        self.moonDateInfo = [self.sharedMoonDatesManager moonDateInfo:date];
    }
    
    BOOL canLetItGo = [[self.moonDateInfo objectForKey:@"canLetItGo"] boolValue]; //Extract the information on whether the date is within the 'Let It Go' range within which the ritual can be performed.
    
    if (canLetItGo) //If we are within the Let It Go range, then return our standard background colour to stand out against the highlighted cell
    {
        return self.sharedColoursManager.backgroundColour;
    }
    
    NSDate *today = [NSDate dateWithTimeIntervalSinceNow:0]; //Get todays date
    NSDateComponents *todaysDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth| NSCalendarUnitYear fromDate:today]; //Get the components of todays date without the time included.
    NSDate *todayWithoutTime = [[NSCalendar currentCalendar] dateFromComponents:todaysDateComponents]; //Reconstitute todays date without the time.
    
    NSDateComponents *datePassedInComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth| NSCalendarUnitYear fromDate:date]; //Get the components of the date passed in by the calendar without the time included.
    NSDate *datePassedInWithoutTime = [[NSCalendar currentCalendar] dateFromComponents:datePassedInComponents]; //Reconstitute the date passed in without the time.
    
    if ([datePassedInWithoutTime isEqualToDate: todayWithoutTime])
        //If the date passed in by the calendar is todays date then return the highlight colour to highlight today's date on the calendar.
    {
        return self.sharedColoursManager.highlightColour;
    }
    
    else
    {
    return self.sharedColoursManager.textColour; //Otherwise, return our standard text colour
    }
}


- (CGPoint) calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance imageOffsetForDate:(NSDate *)date
{
    //Here the calendar asks for the offset for the image for a specific date cell.
    
    CGRect theFrame = [self.theCalendarView frameForDate:date]; //Get the frame for our date cell
    CGPoint offsetForImage = CGPointMake(0, (theFrame.size.height /3.3) * -1); //Here we take the height of the date cell, and use it to calculate a negative offset for the image, to position it within the selectable date area.
    
    return offsetForImage;
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
