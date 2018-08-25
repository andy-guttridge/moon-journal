//
//  WWFsettingsViewController.m
//  Moon Dates
//
//  Created by Andy Guttridge on 29/05/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#import "WWFsettingsViewController.h"
#import "WWFcoloursManager.h"
#import "WWFmoonDatesManager.h"

@interface WWFsettingsViewController ()

@property (weak, nonatomic) WWFcoloursManager *sharedColoursManager;
@property (weak, nonatomic) WWFmoonDatesManager *sharedMoonDatesManager;

@end

@implementation WWFsettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    
    self.sharedColoursManager = [WWFcoloursManager sharedColoursManager]; //Get a reference to our shared colours manager.
    self.sharedMoonDatesManager = [WWFmoonDatesManager sharedMoonDatesManager]; //Get a reference to our shared moon dates manager.
    
    self.view.backgroundColor = self.sharedColoursManager.backgroundColour; //Set the background colour of our view to the standard background colour.
    [self.clearJournalButton setTitleColor:self.sharedColoursManager.selectableColour forState:UIControlStateNormal]; //Set the text colour for the clear journal entries button in the normal state.
    [self.aboutButton setTitleColor:self.sharedColoursManager.selectableColour forState:UIControlStateNormal]; //Set the text colour for the clear journal entries button in the normal state.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clearJournalButtonPressed:(id)sender
//This method is triggered when the user presses the button to clear all journal entries.
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"Are you sure you want to clear all journal entries?" preferredStyle:UIAlertControllerStyleActionSheet]; //This UIAlertContoller will be used to ask the user if they are sure they wish to clear all journal entries.
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]; // Cancel action to add to the UIAlertController. Specifies a nil handler as no action is required if the user chooses this option.
    [controller addAction:cancelAction]; //Add our cancel action to the controller.
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) //OK action to add to the UIAlertController. The handler code deals with clearing the journal entries. We specify UIActionAlertStyleDestructive, as this action deletes all journal entries and is non-reversible.
                               {
                                  [self.sharedMoonDatesManager clearAllJournalEntries]; //Ask the shared moon dates manager to clear all journal entries.
                               }];
    [controller addAction:okAction]; //Add the OK action to the controller.

    [self presentViewController:controller animated:YES completion:nil]; //Show our UIAlertController
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
