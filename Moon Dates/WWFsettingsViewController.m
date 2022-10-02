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
    //Do any additional setup after loading the view.
    
    //Get reference to shared colours manager and moon dates manager.
    self.sharedColoursManager = [WWFcoloursManager sharedColoursManager];
    self.sharedMoonDatesManager = [WWFmoonDatesManager sharedMoonDatesManager];
    
    //Set background colour of view and text colour for buttons in their normal state.
    self.view.backgroundColor = self.sharedColoursManager.backgroundColour;
    [self.clearJournalButton setTitleColor:self.sharedColoursManager.selectableColour forState:UIControlStateNormal];
    [self.aboutButton setTitleColor:self.sharedColoursManager.selectableColour forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//This method is triggered when the user presses the button to clear all journal entries.
- (IBAction)clearJournalButtonPressed:(id)sender {
    
    //Create UIAlertContoller to ask user if they are sure about the delete action, create cancel and OK actions, and add them to hte UIAlertController.
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"Are you sure you want to clear all journal entries?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [controller addAction:cancelAction];
    
    //The OK action asks the moon dates manager to clear all journal entries.
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        [self.sharedMoonDatesManager clearAllJournalEntries];
    }];
    [controller addAction:okAction];
    
    //Display the UIAlertController.
    [self presentViewController:controller animated:YES completion:nil];
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
