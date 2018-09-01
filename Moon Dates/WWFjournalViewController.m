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

@property NSString *textForMoonTypeLabel; //A string to hold the text for the moonTypeLabel.

@end

@implementation WWFjournalViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    //Get a reference to the shared Moon Dates Manager.
    self.sharedMoonDatesManager = [WWFmoonDatesManager sharedMoonDatesManager];
    
    //Get a reference to the shared colours manager.
    self.sharedColoursManager = [WWFcoloursManager sharedColoursManager];
    
    //Set colours of various UI elements using colours from our shared colours manager
    self.moonTypeLabel.textColor = self.sharedColoursManager.headerColour;
    self.moonTypeLabel.backgroundColor = self.sharedColoursManager.backgroundColour;
    self.journalTextView.textColor = self.sharedColoursManager.textColour;
    self.journalTextView.backgroundColor = self.sharedColoursManager.backgroundColour;
    self.view.backgroundColor = self.sharedColoursManager.backgroundColour;
    self.navigationController.navigationBar.tintColor = self.sharedColoursManager.selectableColour;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:self.sharedColoursManager.headerColour forKey:NSForegroundColorAttributeName];
    
    //Ensure text is displayed at the very top of the UITextView
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.sharedUserDataManager = [WWFuserDataManager sharedUserDataManager];  //Get a reference to the sharedUserDataManager
    
    //Add a UITapGestureRecognizer to the view, so that we can dismiss the keyboard if the user taps within the view outside of the editing area. In the event this happens, the endEditing: method on the UITextView is called
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tap];
    
    //Register to receive notifications when the keyboard is shown and ask for our keyboardWasShown: method to be called.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    //Register to receive notifications when the keyboard is hidden and ask for our keyboardWasHidden: method to be called.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //Make text uneditable if the relevant moon event date has passed and we are outside of the 'allowed Let It Go interval', or if the journal text has already been released (even if we are within the 'allowed Let It Go interval'.
    
    NSDate *theMoonDate = [self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] objectForKey:@"MoonDate"]; //Get the moon date this journal entry relates to.
    NSNumber *intervalUntilDate = [NSNumber numberWithDouble: (double)[theMoonDate timeIntervalSinceNow]]; //The amount of time until or after the moon date.
    NSNumber *letItGoAllowedInterval = [NSNumber numberWithInt:kAllowedLetItGoInterval]; //Turn the pre-defined constant into an NSNumber.
    BOOL hasBeenReleased = [[self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] objectForKey:@"Released"] boolValue]; //This BOOL in the moondates dictionary is used to record whether the journal entry has already been released with the letItGoButton.
    
    if ((([intervalUntilDate compare:letItGoAllowedInterval] == NSOrderedAscending) && [intervalUntilDate intValue] < 0) || hasBeenReleased == YES)
    {
        self.journalTextView.editable = NO;
    }
    
    //Retrieve any journal text already entered for the current date and display it in the journalTextView
    
    self.journalTextView.text = [self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] objectForKey:@"JournalText"];
    if (self.journalTextView.editable == NO) //Colour the text usin the global unselectable colour if we have made the textview uneditable (because the moon date has already passed).
    {
        self.journalTextView.textColor = self.sharedColoursManager.nonSelectableColour;
    }
    
    else //Otherwise, colour the text using the standard text colour
    {
        self.journalTextView.textColor = self.sharedColoursManager.textColour;
    }
    
    self.journalTextView.tag = 1; //We set the journalTextView tag to 1, to indicate that the textview holds text entered by the user. This is for the benefit of the textViewShouldBeginEditing: method, which sets up the colour of the text depending on whether it is placeholder or user entered text.
    
    //Check to see if the journal text is empty (or already holds the placeholder text), because if it is we want to retain the default text for the text view, which is a placeholder to show where to enter text. If the text view is locked (i.e. uneditable) then the moon date has already passed and text cannot be edited, so we show a different placeholder message. 
    
    if ([self.journalTextView.text isEqual:@""] || [self.journalTextView.text isEqual:@"Enter journal text here"])
    {
        if (self.journalTextView.editable == NO)
        {
            self.journalTextView.text = @"Journal text locked. Please move to currently open journal entry.";
        }
        
        else
        {
            self.journalTextView.text = @"Enter journal text here";
        }
        self.journalTextView.textColor = self.sharedColoursManager.nonSelectableColour;
        self.journalTextView.tag = 0;
        NSLog(@"Set journal text to default");
    }
    
    //Display text to prompt the user in the moonTypeLabel, to indicate the type of moon event and provide a brief description of the properties associated with whichever type of moon event, along with the deadline by which the ritual must be performed.
    
    //moonTypeSpecificLabelText is the for the moonTypeLabel which is dependent on the type of moon event.
    
    
    /* Creat two NSDateFormatters, one will be used to extract the date from an NSDate in the form of a string, while the other will be used to extract the time from the NSDate. */
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
    
    NSLog (@"%@", dateFormatterForDate.timeZone);
    NSDictionary *moonDatesInfo = [self.sharedMoonDatesManager moonDateInfo:theMoonDate]; //Get information on the moon date from the sharedMoonDatesManager, which we will use to display the moon date in the text label in the journal view, and later to determine whether the ritual can be performed for the current moon date.
    
    NSString *moonDateDayString = [dateFormatterForDate stringFromDate:theMoonDate]; //Get a date string from the moon date.
    NSString *moonDateTimeString = [dateFormatterForTime stringFromDate:theMoonDate]; //Get a time string from the moon date.
    
    NSString *moonTypeSpecificLabelText = [[NSString alloc]init];
    switch ([[self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] objectForKey:@"Type"]intValue])
    {
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
    
    NSDate *ritualDeadline = [[NSDate alloc] initWithTimeInterval: labs (kAllowedLetItGoInterval) sinceDate:theMoonDate]; //Get the date by which the ritual must be performed. This is used to populate the information provided in the journal view to inform the user by when the ritual must be completed. We use the C labs function to convert the letItGoAllowedInterval to an unsigned double.
    
    NSDate *canDoRitualDate = [[NSDate alloc] initWithTimeInterval:(kpreMoonDateLetItGoInterval * -1) sinceDate:theMoonDate]; //Get the date from which the moon date can be performedd, again used to populate the information provided in the journal view. We multiply the kpreMoonDateLetItGoInterval constant by -1 to convert to a negative value.
    
    NSString *ritualDeadlineDateString = [dateFormatterForDate stringFromDate:ritualDeadline]; //Get a date string from the ritual deadline date.
    NSString *ritualDeadlineTimeString = [dateFormatterForTime stringFromDate:ritualDeadline]; //Get a time string from the ritual deadline date.
    
    NSString *canDoRitualDateString = [dateFormatterForDate stringFromDate:canDoRitualDate]; //Get a date string from the canDoRitual date.
    NSString *canDoRitualTimeString = [dateFormatterForTime stringFromDate:canDoRitualDate]; //Get a time string from the canDoRitual date.
    
    NSString *ritualDeadlineText = [NSString stringWithFormat:@"You have until %@ on %@ to perform the ritual for this journal entry, and you will be able to perform the ritual from %@ on %@.", ritualDeadlineTimeString, ritualDeadlineDateString, canDoRitualTimeString, canDoRitualDateString]; //Put together a statement of when the moon ritual must be performed and when from using the time and date strings.

    self.textForMoonTypeLabel = [NSString stringWithFormat:@"%@ \n \n%@", moonTypeSpecificLabelText, ritualDeadlineText]; //Create the complete string to display in moonTypeLabel, using the Moon Date Type specific text and the ritual deadline text we have now created.
    
    self.moonTypeLabel.text = self.textForMoonTypeLabel;
    
    //Enable letItGoButton if the relevant moon event date has passed if we are within kAllowedLetItGoInterval of the moon event having passed, or if we are within the kpreMoonLetItGo interval before the moon event date, and if the journal entry has not already been released.
    
    NSLog(@"The moon date in journal view is %@", theMoonDate);
    NSLog(@"%@", moonDatesInfo);
    NSLog(@"%@ The actual moon date is ", theMoonDate);
    if (([[moonDatesInfo objectForKey:@"canLetItGo"] boolValue] == YES) && hasBeenReleased == NO)
    {
        self.letItGoButton.enabled = YES;
        NSLog (@"Enable Let It Go button");
    }
    
    else{
        NSLog (@"Did not enable Let It Go button");
    }
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    //When the user has finished editing the text view, update the JournalText entry in the moon date dictionary within the moon dates array, and save the moon dates array to ensure the data is kept.
    NSLog(@"Journal text view did end editing");
    NSString *newJournalText = self.journalTextView.text;
    [self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] setObject:newJournalText forKey:@"JournalText"];
    [self.sharedMoonDatesManager saveMoonDatesData];
    
    self.moonTypeLabel.text = self.textForMoonTypeLabel; //Reinstate the moonTypeLabel text, now that editing has ended.
}

- (IBAction)releaseJournalEntryButtonPressed: (id)sender
{
    //This is where we handle the 'Let it go' button being pressed.
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"Are you sure you want to perform the ritual for this journal entry now?" preferredStyle:UIAlertControllerStyleActionSheet]; //This UIAlertContoller will be used to ask the user if they are sure they wish to perform the ritual at this time.
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // Cancel action to add to the UIAlertController. Specifies a nil handler as no action is required if the user chooses this option.
    [controller addAction:cancelAction]; //Add our cancel action to the controller.
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) //OK action to add to the UIAlertController. The handler code deals with performing the moon ritual for this journal entry, as the user has stated that they wish to perform the action. We specify UIActionAlertStyleDestructive, as this action deletes the journal entry and is non-reversible.
    {
        [self performSegueWithIdentifier:@"avplayerviewsegue" sender:self];
        self.journalTextView.text = @"The sacred ritual has been completed."; //Update the text in the journal text view.
        [self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] setObject:@"The sacred ritual has been completed." forKey:@"JournalText"]; //Update the text in the Moon Dates dictionary.
        [self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] setObject:[NSNumber numberWithBool:YES] forKey: @"Released"]; //Set the Released flag in the moonDatesArray to YES so that we know this journal entry has now been releasd, and the LetItGoButton will now not be enabled.
        [self.sharedMoonDatesManager saveMoonDatesData]; //Save the updated journal entry.
        self.journalTextView.editable = NO; //Now make the journal view uneditable.
        
        self.letItGoButton.enabled = NO; //Disable the letItGoButton, now that the journal entry has been released.
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0; //Here we set the application badge icon number to zero, as the ritual has been performed and therefore there will now be no pending rituals to notify the user of, until the next moon date occurs.
    }];
    [controller addAction:okAction]; //Add the OK action to the controller.
    
    UIPopoverPresentationController *ppc = controller.popoverPresentationController; //Get a reference to our UIAlertController's popoverPresentationController, if there is one. This is in case we are running on an iPad.
    if (ppc != nil)
    {
        ppc.barButtonItem = sender; //Set the barButtonItem property of our UIPopoverPresentationController to the button that called this method, i.e. the LetItGo button. This ensures that if we are running on an iPad, the action sheet is presented as a popover pointing at the button.
 	}
    
    [self presentViewController:controller animated:YES completion:nil]; //Show our UIAlertController
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
//If the textview's tag = 0, we know it didn't contain user text. Now the user has started editing, we clear the text view (to get rid of the placeholder text), colour the text with our standard text colour and change the tag to 1 so that we know it contains the user's text.
{
    if(textView.tag == 0)
    {
        textView.text=@"";
        textView.textColor = self.sharedColoursManager.textColour;
        
        textView.tag = 1;
    }
    
    self.moonTypeLabel.text = @""; //Change the text of the moonTypeLabel to an empty string, so that the journal text view resizes itself to start at the top of the screen. This ensures that the journal text isn't hidden under the keyboard on iPhones with small screens.
    
    return YES;
}

- (void)keyboardWasShown:(NSNotification*)notification
//This method is called when the keyboard is displayed in our UITextView. We scroll the text view to ensure that no text is obscured by the keyboard and adjust the dimensions of the scroll bars to align with the inset.
{
    NSDictionary *info = [notification userInfo]; //Get the dictionary passed in by the notification we have received.
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size; //Get the size of the keyboard.
    
    self.journalTextView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0); //Use the height of our keyboard to create a UIEdgeInset, which we use to set the contentInset property of our UITextView. This adds some padding to the bottom of the text view equal to the height of our keyboard, and ensures that the user's text is not obscured by the keyboard.
    self.journalTextView.scrollIndicatorInsets = self.journalTextView.contentInset; //Insets the scroll bars by the same amount as the content.
}

- (void)keyboardWillHide:(NSNotification*)notification
//This method is called when the keyboard is about to be hidden in our UITextView. We get rid of any padding at the bottom of the UITextView which would have been added when the keyboard was shown, and adjust the dimensions of the scroll bars back to their full height.
{
    self.journalTextView.contentInset = UIEdgeInsetsZero; //Set the contentInset property of our UITextView to zero to get rid of the padding.
    self.journalTextView.scrollIndicatorInsets = UIEdgeInsetsZero; //Set the contentInset property of our UITextView to zero to align them with the full height of the UITextView content.
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
