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
@property (weak, nonatomic) WWFmoonDatesManager *sharedMoonDatesManager;

@end

@implementation WWFjournalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Get a reference to the shared Moon Dates Manager.
    self.sharedMoonDatesManager = [WWFmoonDatesManager sharedMoonDatesManager];
    
    //Retrieve any journal text already entered for the current date and display it in the journalTextView
    
    self.journalTextView.text = [self.sharedMoonDatesManager.moonDatesArray [self.indexForMoonDatesArray] objectForKey:@"JournalText"];
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
    //This is where we will handle the 'Let it go' button being pressed.
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
