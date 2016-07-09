//
//  WWFjournalViewController.m
//  Moon Dates
//
//  Created by Andy Guttridge on 18/06/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#import "WWFjournalViewController.h"

@interface WWFjournalViewController ()

@property IBOutlet UILabel *moonTypeLabel;
@property IBOutlet UITextView *journalTextView;
@property IBOutlet UIBarButtonItem *letItGoButton;
@property (weak, nonatomic) WWFmoonDatesManager *sharedMoonDatesManager;

@end

@implementation WWFjournalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Get a reference to the shared Moon Dates Manager.
    self.sharedMoonDatesManager = [WWFmoonDatesManager sharedMoonDatesManager];
    
    //Ensure text is displayed at the very top of the UITextView
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //Add a UITapGestureRecognizer to the view, so that we can dismiss the keyboard if the user taps within the view outside of the editing area. In the event this happens, the endEditing: method on the UITextView is called
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tap];
    
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
    if (self.journalTextView.editable == NO) //Colour the text grey if we have made the textview uneditable (because the moon date has already passed).
    {
        self.journalTextView.textColor = [UIColor lightGrayColor];
    }
    
    else //Otherwise, colour the text black.
    {
        self.journalTextView.textColor = [UIColor blackColor];
    }
    
    self.journalTextView.tag = 1; //We set the journalTextView tag to 1, to indicate that the textview holds text entered by the user. This is for the benefit of the textViewShouldBeginEditing: and textViewDidChange: methods, which use this tag to determine whether to show some placeholder text.
    
    //Check to see if the journal text is empty (or already holds the placeholder text), because if it is we want to retain the default text for the text view, which is a placeholder to show where to enter text. If the text view is locked (i.e. uneditable) then the moon date has already passed and text cannot be edited, so we show a different placeholder message.
    
    if ([self.journalTextView.text isEqual:@""] || [self.journalTextView.text isEqual:@"Enter journal text here"])
    {
        if (self.journalTextView.editable == NO)
        {
            self.journalTextView.text = @"Journal text locked";
        }
        
        else
        {
            self.journalTextView.text = @"Enter journal text here";
        }
        self.journalTextView.textColor = [UIColor lightGrayColor];
        self.journalTextView.tag = 0;
        NSLog(@"Set journal text to default");
    }
    
    //Display text to prompt the user in the moonTypeLabel, to indicate the type of moon event and provide a brief description of the properties associated with whichever type of moon event.
    NSString *moonTypeLabelText = [[NSString alloc]init];
    switch ([[self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] objectForKey:@"Type"]intValue])
    {
        case kNoMoonEvent:
            moonTypeLabelText = @"No moon event";
            self.letItGoButton.title =@"No event";
            break;
            
        case kNewMoon:
            moonTypeLabelText = @"New Moon: new themes, ideas and concepts; a time to listen to your inner self.";
            self.letItGoButton.title =@"Set intention";
            break;
            
        case kFullMoon:
            moonTypeLabelText = @"Full Moon: heightened emotions. A time to envision dreams manifesting, meditate and send blessings to those in need.";
            self.letItGoButton.title =@"Release";
            break;
            
        default:
            moonTypeLabelText = @"Invalid moon event type";
            self.letItGoButton.title =@"Error";
            break;
    }
    
    self.moonTypeLabel.text = moonTypeLabelText;
    
    //Enable letItGoButton if the relevant moon event date has passed, if we are within kAllowedLetItGoInterval of the moon event having passed, and if the journal entry has not already been released.
    
    NSTimeInterval intervalSinceMoonDate = [[self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] objectForKey:@"MoonDate"] timeIntervalSinceNow]; //Get the amount of time since the relevant moon event.
    
    NSLog(@"Interval since moon date in the journal view is: %f", intervalSinceMoonDate);
    
    if (intervalSinceMoonDate >= kAllowedLetItGoInterval && intervalSinceMoonDate < 0 && hasBeenReleased == NO)
    {
        self.letItGoButton.enabled = YES;
    }
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    //When the user has finished editing the text view, update the JournalText entry in the moon date dictionary within the moon dates array, and save the moon dates array to ensure the data is kept.
    NSLog(@"Journal text view did end editing");
    NSString *newJournalText = self.journalTextView.text;
    [self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] setObject:newJournalText forKey:@"JournalText"];
    [self.sharedMoonDatesManager saveMoonDatesData];
}

- (IBAction)releaseJournalEntryButtonPressed: (id)sender
{
    //This is where we handle the 'Let it go' button being pressed.
    
    self.journalTextView.text = @"You have performed the moon ritual for this journal entry."; //Update the text in the journal text view.
    [self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] setObject:@"You have performed the moon ritual for this journal entry." forKey:@"JournalText"]; //Update the text in the Moon Dates dictionary.
    [self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] setObject:[NSNumber numberWithBool:YES] forKey: @"Released"]; //Set the Released flag in the moonDatesArray to YES so that we know this journal entry has now been releasd, and the LetItGoButton will now not be enabled.
    [self.sharedMoonDatesManager saveMoonDatesData]; //Save the updated journal entry.
    self.journalTextView.editable = NO; //Now make the journal view uneditable.
    
    //Next, configure and show an alert message with an OK button.
    
    NSString *letItGoMessage = @"The thoughts and feelings you recorded in your journal have now been released into the ether.";
    
    UIAlertController *letItGoAlertController = [UIAlertController alertControllerWithTitle:@"Let It Go!" message:letItGoMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [letItGoAlertController addAction:OKAction];
    [self presentViewController:letItGoAlertController animated:YES completion:nil];
    self.letItGoButton.enabled = NO; //Disavle the letItGoButton, now that the journal entry has been released.
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
//If the textview's tag = 0, we know it didn't contain user text. Now the user has started editing, we clear the text view (to get rid of the placeholder text), turn the text black and change the tag to 1 so that we know it contains the user's text.
{
    if(textView.tag == 0)
    {
        textView.text=@"";
        textView.textColor = [UIColor blackColor];
        textView.tag = 1;
    }
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
// If the textview's text has changed, and the length of the string is zero, we know it is empty, so we change the text to display the placeholder, make the text grey, and change the tag to zero, so that textViewShouldBeginEditing: knows that the textview does not contain any text entered by the user.
{
    if ([textView.text length] == 0)
    {
        textView.text = @"Enter journal text here";
        textView.textColor = [UIColor lightGrayColor];
        textView.tag = 0;
    }
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
