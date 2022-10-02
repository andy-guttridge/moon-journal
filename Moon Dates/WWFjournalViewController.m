//
//  WWFjournalViewController.m
//  Moon Dates
//
//  Created by Andy Guttridge on 18/06/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#import "WWFjournalViewController.h"

@interface WWFjournalViewController ()

@property (weak,nonatomic) IBOutlet UILabel *moonTypeLabel;
@property (weak, nonatomic) IBOutlet UITextView *journalTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *letItGoButton;

@property (weak, nonatomic) WWFmoonDatesManager *sharedMoonDatesManager;
@property (weak, nonatomic) WWFuserDataManager *sharedUserDataManager;
@property (weak, nonatomic) WWFcoloursManager *sharedColoursManager;

//A string to hold the text for the moonTypeLabel.
@property NSString *textForMoonTypeLabel;

@end

@implementation WWFjournalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Get reference to the shared Moon Dates Manager and shared colours manager.
    self.sharedMoonDatesManager = [WWFmoonDatesManager sharedMoonDatesManager];
    self.sharedColoursManager = [WWFcoloursManager sharedColoursManager];
    
    //Set colours of various UI elements using colours from shared colours manager.
    self.moonTypeLabel.textColor = self.sharedColoursManager.headerColour;
    self.moonTypeLabel.backgroundColor = self.sharedColoursManager.backgroundColour;
    self.journalTextView.textColor = self.sharedColoursManager.textColour;
    self.journalTextView.backgroundColor = self.sharedColoursManager.backgroundColour;
    self.view.backgroundColor = self.sharedColoursManager.backgroundColour;
    self.navigationController.navigationBar.tintColor = self.sharedColoursManager.selectableColour;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:self.sharedColoursManager.headerColour forKey:NSForegroundColorAttributeName];
    
    //Ensure text is displayed at the very top of the UITextView
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //Get a reference to the sharedUserDataManager
    self.sharedUserDataManager = [WWFuserDataManager sharedUserDataManager];
    
    //Add a UITapGestureRecognizer to the view. This is used to dismiss the keyboard if the user taps within the view outside of the editing area.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tap];
    
    //Register to receive notifications when the keyboard is shown and when it is hidden, and call handling methods.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //Make text uneditable if the relevant moon event date has passed and we are outside of the 'allowed Let It Go interval',
    //or if the journal text has already been released (even if we are within the 'allowed Let It Go interval'.
    //Get the moon date this journal entry relates to, amount of time until or since the moon date and convert the preset time interval to NSNumber.
    NSDate *theMoonDate = [self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] objectForKey:@"MoonDate"];
    NSNumber *intervalUntilDate = [NSNumber numberWithDouble: (double)[theMoonDate timeIntervalSinceNow]];
    NSNumber *letItGoAllowedInterval = [NSNumber numberWithInt:kAllowedLetItGoInterval];
    
    //Find out if the moon ritual for this date has already been done.
    BOOL hasBeenReleased = [[self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] objectForKey:@"Released"] boolValue];
    if ((([intervalUntilDate compare:letItGoAllowedInterval] == NSOrderedAscending) && [intervalUntilDate intValue] < 0) || hasBeenReleased == YES) {
        self.journalTextView.editable = NO;
    }
    
    //Retrieve any journal text already entered for the current date and display it in the journalTextView. Colour the text appropriately depending if the view is editable.
    self.journalTextView.text = [self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] objectForKey:@"JournalText"];
    if (self.journalTextView.editable == NO) {
        self.journalTextView.textColor = self.sharedColoursManager.nonSelectableColour;
    } else {
        self.journalTextView.textColor = self.sharedColoursManager.textColour;
    }
    
    //Setting journalTextView tag to 1 indicates the text has been editied by the user. Used elsewhere to determine the colour of the text.
    self.journalTextView.tag = 1;
    
    //Check to see if the journal text is empty (or already holds the placeholder text), because if it is we want to retain the default text for the text view.
    //If the text view is locked (i.e. uneditable) then the moon date has already passed and text cannot be edited, so we show a different placeholder message.
    if ([self.journalTextView.text isEqual:@""] || [self.journalTextView.text isEqual:@"Enter journal text here"]) {
        if (self.journalTextView.editable == NO) {
            self.journalTextView.text = @"Journal text locked. Please move to currently open journal entry.";
        } else {
            self.journalTextView.text = @"Enter journal text here";
        }
        self.journalTextView.textColor = self.sharedColoursManager.nonSelectableColour;
        self.journalTextView.tag = 0;
        NSLog(@"Set journal text to default");
    }
    
    //Display text to prompt the user and provide the deadline for the ritual in the moonTypeLabel.
    //moonTypeSpecificLabelText is for the moonTypeLabel and is dependent on the type of moon event.
    
    //Create two NSDateFormatters, one to extract the date from an NSDate in the form of a string, the other to extract the time from the NSDate.
    NSDateFormatter *dateFormatterForDate = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatterForTime = [[NSDateFormatter alloc] init];
    dateFormatterForDate.locale = [[NSLocale alloc] initWithLocaleIdentifier:[self.sharedUserDataManager.userDataDictionary objectForKey:@"DateFormat"]];
    dateFormatterForTime.locale = dateFormatterForDate.locale;
    
    //Set up the NSDateFormatters so that one formats the NSDate as only a date without a time, and the other formats it as only a time without a date.
    dateFormatterForDate.dateStyle = NSDateFormatterMediumStyle;
    dateFormatterForDate.timeStyle = NSDateFormatterNoStyle;
    dateFormatterForTime.dateStyle = NSDateFormatterNoStyle;
    dateFormatterForTime.timeStyle = NSDateFormatterShortStyle;
    
    [dateFormatterForTime setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatterForDate setTimeZone:[NSTimeZone localTimeZone]];
    
    //Get information on the moon date from the sharedMoonDatesManager. Used to display the moon date in the text label in the journal view, and to determine whether the ritual can be performed for the current moon date.
    NSLog (@"%@", dateFormatterForDate.timeZone);
    NSDictionary *moonDatesInfo = [self.sharedMoonDatesManager moonDateInfo:theMoonDate];
    
    //Get date and time strings.
    NSString *moonDateDayString = [dateFormatterForDate stringFromDate:theMoonDate];
    NSString *moonDateTimeString = [dateFormatterForTime stringFromDate:theMoonDate];
    
    NSString *moonTypeSpecificLabelText = [[NSString alloc]init];
    switch ([[self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] objectForKey:@"Type"]intValue]) {
        case kNoMoonEvent:
            moonTypeSpecificLabelText = @"No moon event";
            self.letItGoButton.title =@"No event";
            break;
            
        case kNewMoon:
            moonTypeSpecificLabelText = [NSString stringWithFormat: @"New Moon at %@ on %@. \n\nThe time leading up to the new moon is the time to focus on hopes and dreams that you would like to manifest in your life. Use the journal to note your clear intentions.", moonDateTimeString, moonDateDayString];
            self.letItGoButton.title =@"Set intention";
            break;
            
        case kFullMoon:
            moonTypeSpecificLabelText = [NSString stringWithFormat: @"Full Moon at %@ on %@. \n\nThe time leading up to the full moon is the time to release and let go of the things that are no longer serving you. Use the journal to note these.", moonDateTimeString, moonDateDayString];
            self.letItGoButton.title =@"Release";
            break;
            
        default:
            moonTypeSpecificLabelText = @"Invalid moon event type";
            self.letItGoButton.title =@"Error";
            break;
    }
    
    //Get date by which the ritual must be performed and convert to unsigned double. Used to inform the user by when the ritual must be completed.
    NSDate *ritualDeadline = [[NSDate alloc] initWithTimeInterval: labs (kAllowedLetItGoInterval) sinceDate:theMoonDate];
    //Get date from which the moon date can be performed to inform the user and convert to negative value.
    NSDate *canDoRitualDate = [[NSDate alloc] initWithTimeInterval:(kpreMoonDateLetItGoInterval * -1) sinceDate:theMoonDate];
    
    //Get date and time strings for the two dates.
    NSString *ritualDeadlineDateString = [dateFormatterForDate stringFromDate:ritualDeadline];
    NSString *ritualDeadlineTimeString = [dateFormatterForTime stringFromDate:ritualDeadline];
    NSString *canDoRitualDateString = [dateFormatterForDate stringFromDate:canDoRitualDate];
    NSString *canDoRitualTimeString = [dateFormatterForTime stringFromDate:canDoRitualDate];
    
    //Use time and date strings to create info message and display to the user.
    NSString *ritualDeadlineText = [NSString stringWithFormat:@"You have until %@ on %@ to perform the ritual for this journal entry, and you will be able to perform the ritual from %@ on %@.", ritualDeadlineTimeString, ritualDeadlineDateString, canDoRitualTimeString, canDoRitualDateString];
    self.textForMoonTypeLabel = [NSString stringWithFormat:@"%@ \n \n%@", moonTypeSpecificLabelText, ritualDeadlineText];
    self.moonTypeLabel.text = self.textForMoonTypeLabel;
    
    //Enable letItGoButton if the relevant moon event date has passed and if within kAllowedLetItGoInterval or if within the kpreMoonLetItGo interval before the moon event date
    //and if the journal entry has not already been released.
    NSLog(@"The moon date in journal view is %@", theMoonDate);
    NSLog(@"%@", moonDatesInfo);
    NSLog(@"%@ The actual moon date is ", theMoonDate);
    if (([[moonDatesInfo objectForKey:@"canLetItGo"] boolValue] == YES) && hasBeenReleased == NO) {
        self.letItGoButton.enabled = YES;
        NSLog (@"Enable Let It Go button");
    } else {
        NSLog (@"Did not enable Let It Go button");
    }
}

//When the user has finished editing the text view, update the JournalText entry in the moon date dictionary within the moon dates array, and save the moon dates array to ensure the data is kept.
- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"Journal text view did end editing");
    NSString *newJournalText = self.journalTextView.text;
    [self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] setObject:newJournalText forKey:@"JournalText"];
    [self.sharedMoonDatesManager saveMoonDatesData];
    
    //Reinstate the moonTypeLabel text, now that editing has ended.
    self.moonTypeLabel.text = self.textForMoonTypeLabel;
}

//This is where we handle the 'Let it go' button being pressed.
- (IBAction)releaseJournalEntryButtonPressed: (id)sender {
    //This UIAlertContoller will be used to ask the user if they are sure they wish to perform the ritual at this time.
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"Are you sure you want to perform the ritual for this journal entry now?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    //Create cancel and ok actions and add to the UIAlertController.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [controller addAction:cancelAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"avplayerviewsegue" sender:self];
        
        //Update the text in the journal text view and in the Moon Dates dictionary, and set flag to confirm this journal entry has now been released.
        self.journalTextView.text = @"The sacred ritual has been completed.";
        [self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] setObject:@"The sacred ritual has been completed." forKey:@"JournalText"];
        [self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] setObject:[NSNumber numberWithBool:YES] forKey: @"Released"];
        
        //Save updated journal entry and make journal view uneditable.
        [self.sharedMoonDatesManager saveMoonDatesData];
        self.journalTextView.editable = NO;
        
        //Disable the letItGoButton and set app icon badge to zero.
        self.letItGoButton.enabled = NO;
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }];
    [controller addAction:okAction];
    
    //Get a reference to UIAlertController's popoverPresentationController if it exists, in case running on iPad.
    //If we are running on iPad, set barButtonItem so that action sheet is presented as a popover pointing at the button.
    UIPopoverPresentationController *ppc = controller.popoverPresentationController;
    if (ppc != nil) {
        ppc.barButtonItem = sender;
 	}
    //Show our UIAlertController
    [self presentViewController:controller animated:YES completion:nil];
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    //If the textview's tag = 0, it didn't contain user text. Now the user has started editing, clear the text view, colour text change the tag to 1 so that we know it contains user text.
    if(textView.tag == 0) {
        textView.text=@"";
        textView.textColor = self.sharedColoursManager.textColour;
        textView.tag = 1;
    }
    
    //Change the text of the moonTypeLabel to an empty string, to ensure journal text isn't hidden under the keyboard on iPhones with small screens.
    self.moonTypeLabel.text = @"";
    return YES;
}

//This method is called when the keyboard is displayed in UITextView. Scroll text view to ensure no text is obscured by the keyboard and adjust dimensions of scroll bars to align with the inset.
- (void)keyboardWasShown:(NSNotification*)notification {
    //Get dictionary passed in by the notification and size of keyboard.
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    //Use height of keyboard to create a UIEdgeInset, and assign to contentInset property of UITextView. This adds padding to to ensure the user's text is not obscured by the keyboard.
    //Then inset the scroll bars by the same amount as the content.
    self.journalTextView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
    self.journalTextView.scrollIndicatorInsets = self.journalTextView.contentInset;
}

//This method is called when the keyboard is about to be hidden. Get rid of any padding at the bottom of UITextView which would have been added when the keyboard was shown, and adjust dimensions of the scroll bars back to their full height.
- (void)keyboardWillHide:(NSNotification*)notification {
    //Set contentInset property of UITextView to get rid of padding and set contentInset property to align with full height of UITextView content.
    self.journalTextView.contentInset = UIEdgeInsetsZero;
    self.journalTextView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
