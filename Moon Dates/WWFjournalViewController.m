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
    
    //Retrieve any journal text already entered for the current date and display it in the journalTextView
    self.journalTextView.text = [self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] objectForKey:@"JournalText"];
    
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
    
    //Make text uneditable if the relevant moon event date has passed and we are outside of the 'allowed Let It Go interval', and colour the text grey.
    
    NSDate *theMoonDate = [self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] objectForKey:@"MoonDate"]; //Get the moon date this journal entry relates to.
    NSNumber *intervalUntilDate = [NSNumber numberWithDouble: (double)[theMoonDate timeIntervalSinceNow]]; //The amount of time until or after the moon date.
    NSNumber *letItGoAllowedInterval = [NSNumber numberWithInt:kAllowedLetItGoInterval]; //Turn the pre-defined constant into an NSNumber.
    
    if (([intervalUntilDate compare:letItGoAllowedInterval] == NSOrderedAscending) && [intervalUntilDate intValue] < 0)
    {
        self.journalTextView.editable = NO;
        self.journalTextView.textColor = [UIColor lightGrayColor];
    }
    
    //Enable letItGoButton if the relevant moon event date has passed, but we are within 12 hours of the moon event having passed.
    
    NSTimeInterval intervalSinceMoonDate = [[self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] objectForKey:@"MoonDate"] timeIntervalSinceNow]; //Get the amount of time since the relevant moon event.
    
    NSLog(@"Interval since moon date in the journal view is: %f", intervalSinceMoonDate);
    
    if (intervalSinceMoonDate >= kAllowedLetItGoInterval && intervalSinceMoonDate < 0)
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
    
    self.journalTextView.text = nil; //Get rid of the text in the journal text view.
    [self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] setObject:@"" forKey:@"JournalText"]; //Get rid of journal text entry in the Moon Dates dictionary.
    
    //Next, configure and show an alert message with an OK button.
    
    NSString *letItGoMessage = @"The thoughts and feelings you recorded in your journal have now been released into the ether.";
    
    UIAlertController *letItGoAlertController = [UIAlertController alertControllerWithTitle:@"Let It Go!" message:letItGoMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [letItGoAlertController addAction:OKAction];
    [self presentViewController:letItGoAlertController animated:YES completion:nil];
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
