//
//  WWF_FSCalViewController.m
//  Moon Journal
//
//  Created by Andy Guttridge on 23/09/2017.
//  Copyright © 2017 Andy Guttridge. All rights reserved.
//

#import "WWFFSCalViewController.h"

@interface WWFFSCalViewController ()

//Reference to shared moon dates manager
@property (weak, nonatomic) WWFmoonDatesManager *sharedMoonDatesManager;
//Index for moon dates array to access the correct journal entry
@property NSUInteger journalIndex;
//Holds key info about each moon date
@property (copy) NSDictionary *moonDateInfo;


@end

@implementation WWFFSCalViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sharedMoonDatesManager = [WWFmoonDatesManager sharedMoonDatesManager];
    self.sharedColoursManager = [WWFcoloursManager sharedColoursManager];
    
    //Register to receive UIApplicationWillEnterForegroundNotification and call [self redrawCalendar] method.
    //Ensures calendar is redrawn if user switches back to our app from somewhere else.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (redrawCalendar) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //Set up display properties of calendar, e.g. colours, scroll direction etc.
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

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//This method refreshes the calendar data.
-(void) redrawCalendar{
    [self.theCalendarView reloadData];
}

//This method ensures the calendar view is refreshed if the user returns to the calendar from another view.
- (void) viewWillAppear:(BOOL)animated{
    NSLog(@"WWF_FSCalViewController viewWillAppear called.");
    [super viewWillAppear:animated];
    [self redrawCalendar];
    
    //Ask calendar to deselect the date corresponding to the current moon date array index stored within this object.
    //Ensures moon date is deselected in the calendar when we return from another view, e.g. the journal view.
    [self.theCalendarView deselectDate:[self.sharedMoonDatesManager.moonDatesArray [self.journalIndex] objectForKey:@"MoonDate"]];
}

//Give calendar its start date.
- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar{
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:kCalendarStartDate];
    return startDate;
}

//Give calendar its end date.
- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar{
    NSDate *endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:kCalendarEndDate];
    return endDate;
}

//This method is called when the calendar wants to know if the user should be permitted to select a specific date.
- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition{
    //Get dictionary from sharedMoonDatesManager, use this to determine if the date is a moon date and its index in the moon dates array.
    //If selected date is a moon date allow the user to select the date.
    //Index of the moon date is stored in the journal index property and passed to the journal view controller in the prepareForSegue:segue sender:sender method.
    if (([[self.moonDateInfo objectForKey:@"date"] isEqualToDate:date]) == NO) {
        self.moonDateInfo = [self.sharedMoonDatesManager moonDateInfo:date];
    }
    
    //Find out if date passed in by the calendar is a moon date.
    BOOL isMoonDate = [[self.moonDateInfo objectForKey:@"isMoonDate"] boolValue];
    
    //If date is a moon date, find out the index of the date in the moon dates array and store the index value.
    if (isMoonDate == YES){
        self.journalIndex = [[self.moonDateInfo objectForKey:@"index"] integerValue];
    }
    return isMoonDate;
}

//If a date was selected on the calender, perform a segue to the journal view controller to display the journal entry.
-(void) calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    //Reference to the appropriate journal entry is passed to the journal view controller in - (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender .
    [self performSegueWithIdentifier:@"journalsegue" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Get a reference to the journal view controller via the segue which is passed to this method.
    WWFjournalViewController *journalViewController = (WWFjournalViewController *) [segue destinationViewController];
    //Pass the index for the journal entry to the journal view controller.
    journalViewController.indexForMoonDatesArray = self.journalIndex;
}

-(nullable UIImage *) calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date {
    //If the date is a new moon or full moon, return an appropriate image to use as an icon, otherwise return nil.
    //Check moon date info currently stored in calendar view controller relates to the date passed in by the calendar.
    //If not, ask the moon dates manager for info for the correct date. This ensures each FSCalendar delegate method that requires this information only asks for it if it is needed.
    if (([[self.moonDateInfo objectForKey:@"date"] isEqualToDate:date]) == NO) {
        self.moonDateInfo = [self.sharedMoonDatesManager moonDateInfo:date];
    }
    
    //If date is a moon date get the type, if not then the value will be 0.
    NSUInteger type = [[self.moonDateInfo objectForKey:@"type"] integerValue];
    //Find out whether the date is within the Let It Go range witin which the ritual can be performed.
    BOOL canLetItGo = [[self.moonDateInfo objectForKey:@"canLetItGo"] boolValue];
    //Find out whether the journal entry for this date has been performed.
    BOOL released = [[self.moonDateInfo objectForKey:@"released"] boolValue];
    
    //If moon date is a full moon and the date is not within the Let It Go range, return the standard full moon icon to display on the calendar.
    if ((type == kFullMoon) && (!canLetItGo)) {
        UIImage *image = [UIImage imageNamed:@"FullMoonIcon"];
        return image;
    } else if ((type ==kFullMoon) && (canLetItGo)) {
        //If moon date is a full moon and date is within the Let It Go range, find out whether the ritual has been performed for the corresponding journal entry.
        if (!released) {
            //If journal entry for this date hasn't been released yet, then the cell will be highlighted and we need to return the inverse icon image.
            UIImage *image = [UIImage imageNamed: @"FullMoonInverseIcon"];
            return image;
        } else {
            //Otherwise the journal entry has been been released, so return the standard full moon icon image.
            UIImage *image = [UIImage imageNamed: @"FullMoonIcon"];
            return image;
        }
    } else if ((type == kNewMoon) && (!canLetItGo)) {
        //If moon date is a new moon and date is not within the Let It Go range, then return the standard new moon icon to display on the calendar.
        UIImage *image = [UIImage imageNamed:@"NewMoonIcon"];
        return image;
    } else if ((type == kNewMoon) && (canLetItGo)) {
        //If moon date is a new moon and the date is within the Let It Go range, we need to find out whether the ritual has been performed for the corresponding journal entry.
        if (!released) {
            //If journal entry for this date hasn't been released yet, then the cell will be highlighted and we return the inverse icon image.
            UIImage *image = [UIImage imageNamed:@"NewMoonInverseIcon"];
            return image;
        } else {
            //Otherwise return the standard icon.
            UIImage *image = [UIImage imageNamed:@"NewMoonIcon"];
            return image;
        }
    }  else
    {
        return nil;
    }
    
}

//This method is called when the today button on the calendar is pressed.
- (IBAction)goToToday:(id)sender {
    //Select and scroll to the current date, and ensure it appears deselected.
    NSDate *today = [NSDate date]; //Get today's date
    [self.theCalendarView selectDate:today scrollToDate:YES];
    [self.theCalendarView deselectDate:today];
}

- (nullable UIColor*) calendar: (FSCalendar *) calendar appearance:(nonnull FSCalendarAppearance *)appearance fillDefaultColorForDate:(nonnull NSDate *)date{
    //Return default colour for date cells.
    if (([[self.moonDateInfo objectForKey:@"date"] isEqualToDate:date]) == NO) {
        //Check moon date info currently stored in the calendar view controller matches date passed in by the calendar,
        //or ask the moon dates manager for the info for the correct date.
        //Ensures each FSCalendar delegate method that requires this information only asks for it if it is needed, and improves performance.
        self.moonDateInfo = [self.sharedMoonDatesManager moonDateInfo:date];
    }
    
    //Find out if date is within the 'Let It Go' range within which the ritual can be performed.
    BOOL canLetItGo = [[self.moonDateInfo objectForKey:@"canLetItGo"] boolValue];
    //Extract information on whether the ritual has been performed for this journal entry.
    BOOL released = [[self.moonDateInfo objectForKey:@"released"] boolValue];
    
    //If within the Let It Go range and the journal entry as not been released, return highlighted colour to indicate that the ritual can be performed
    if ((canLetItGo) && (!released)) {
        return self.sharedColoursManager.highlightColour;
    } else {
        //If the date is not within the Let It Go range, then return the standard background colour.
        return self.sharedColoursManager.backgroundColour;
    }
}

//Method returns default border colour for date cells.
- (nullable UIColor*) calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date {
    //Get todays date, components of date without time, reconstitite date without time.
    //Then do the same for the date passed in by the  calendar.
    //NOTE - this code to get the date without the time should be pulled into its own method, as it's repeated a few times.
    NSDate *today = [NSDate date];
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:today];
    NSDate *todayWithoutTime = [[NSCalendar currentCalendar] dateFromComponents:todayComponents];
    NSDateComponents *calendarDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    NSDate *calendarDateWithoutTime = [[NSCalendar currentCalendar] dateFromComponents:calendarDateComponents];
    
    //If date passed in by calendar is today's date, return standard header colour from the shared colours manager.
    if ([todayWithoutTime isEqualToDate:calendarDateWithoutTime]) {
        return self.sharedColoursManager.headerColour;
    } else {
        //Otherwise return standard background colour from shared colours manager so that the date cell appears with no border.
        return self.sharedColoursManager.backgroundColour;
    }
}

- (nullable UIColor*) calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(nonnull NSDate *)date {
    //Return default text colour for dates. If date is within the Let It Go range and the journal entry for this date has not been released
    //return the background colour so that the text stands out against the highlighted cell. Otherwise we return standard text colour.
    
    //Check moon date info currently stored in the calendar view controller relates to the date passed in by the calendar.
    if (([[self.moonDateInfo objectForKey:@"date"] isEqualToDate:date]) == NO) {
        //If not ask moon dates manager for the info for the correct date. Ensures each FSCalendar delegate method that requires this information only asks for it if it is needed, improves performance.
        self.moonDateInfo = [self.sharedMoonDatesManager moonDateInfo:date];
    }
    
    //Extract information on whether the date is within the 'Let It Go' range within which the ritual can be performed and find out whether the moon date ritual has already been performed for this date.
    BOOL canLetItGo = [[self.moonDateInfo objectForKey:@"canLetItGo"] boolValue];
    BOOL released = [[self.moonDateInfo objectForKey:@"released"] boolValue];
    
    //If within the Let It Go range and journal entry for this date has not been released, return standard background colour.
    if ((canLetItGo) && (!released)) {
        return self.sharedColoursManager.backgroundColour;
    }
    
    //Get todays date, components of date without time, reconstitite date without time.
    //Then do the same for the date passed in by the  calendar.
    NSDate *today = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateComponents *todaysDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth| NSCalendarUnitYear fromDate:today];
    NSDate *todayWithoutTime = [[NSCalendar currentCalendar] dateFromComponents:todaysDateComponents];
    NSDateComponents *datePassedInComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth| NSCalendarUnitYear fromDate:date];
    NSDate *datePassedInWithoutTime = [[NSCalendar currentCalendar] dateFromComponents:datePassedInComponents];
    
    if ([datePassedInWithoutTime isEqualToDate: todayWithoutTime]) {
    //If date passed in by the calendar is todays date then return the highlight colour.
        return self.sharedColoursManager.highlightColour;
     } else {
        return self.sharedColoursManager.textColour; //Otherwise return the standard text colour
     }
}

- (nullable UIColor*) calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date {
    //Return background colour as the border colour for selected date cells.
    return self.sharedColoursManager.backgroundColour;
}

- (nullable UIColor*) calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillSelectionColorForDate:(NSDate *)date {
    //If date is not within the Let It Go range return standard selectable item colour for cell border, if within the Let It Go range return highlight colour.
    if (([[self.moonDateInfo objectForKey:@"date"] isEqualToDate:date]) == NO) {
        self.moonDateInfo = [self.sharedMoonDatesManager moonDateInfo:date];
    }
    
    //Find out whether the date is within the range within which the ritual can be performed and return highlighted colour if it is.
    BOOL canLetItGo = [[self.moonDateInfo objectForKey:@"canLetItGo"] boolValue];
    if (canLetItGo)  {
        return self.sharedColoursManager.highlightColour;
    } else {
        return self.sharedColoursManager.selectableColour;
    }
}

- (nullable UIColor*) calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleSelectionColorForDate:(NSDate *)date {
    //Return standard background colour if date is within 'Let It Go' range, the highlighted colour if the date is today, otherwise return standard text colour.
    //Check moon date info currently stored in the calendar view controller relates to the date passed in by the calendar.
    if (([[self.moonDateInfo objectForKey:@"date"] isEqualToDate:date]) == NO) {
        //If not ask moon dates manager for the info for the correct date. Ensures each FSCalendar delegate method that requires this information only asks for it if it is needed, improves performance.
        self.moonDateInfo = [self.sharedMoonDatesManager moonDateInfo:date];
    }
    
    //Find out whether the date is within the range within which the ritual can be performed and return stanard background colour if it is
    BOOL canLetItGo = [[self.moonDateInfo objectForKey:@"canLetItGo"] boolValue];
    if (canLetItGo) {
        return self.sharedColoursManager.backgroundColour;
    }
    
    //Get todays date, components of date without time, reconstitite date without time.
    //Then do the same for the date passed in by the  calendar.
    NSDate *today = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateComponents *todaysDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth| NSCalendarUnitYear fromDate:today];
    NSDate *todayWithoutTime = [[NSCalendar currentCalendar] dateFromComponents:todaysDateComponents];
    NSDateComponents *datePassedInComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth| NSCalendarUnitYear fromDate:date];
    NSDate *datePassedInWithoutTime = [[NSCalendar currentCalendar] dateFromComponents:datePassedInComponents];
    
    if ([datePassedInWithoutTime isEqualToDate: todayWithoutTime]) {
        //If date passed in by the calendar is todays date then return the highlight colour, otherwise return standard text colour
        return self.sharedColoursManager.highlightColour;
    } else {
    return self.sharedColoursManager.textColour;
    }
}


- (CGPoint) calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance imageOffsetForDate:(NSDate *)date {
    //Return image offset for date cell.
    //Get the frame for our date cell
    CGRect theFrame = [self.theCalendarView frameForDate:date];
    
    //Calculate a negative offset for the image, to position it within the selectable date area.
    CGPoint offsetForImage = CGPointMake(0, (theFrame.size.height /3.3) * -1);
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
