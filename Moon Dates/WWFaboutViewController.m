//
//  WWFaboutViewController.m
//  Moon Journal
//
//  Created by Andy Guttridge on 16/08/2018.
//  Copyright © 2018 Andy Guttridge. All rights reserved.
//

#import "WWFaboutViewController.h"
#import "WWFcoloursManager.h"

@interface WWFaboutViewController ()

@property (weak, nonatomic) WWFcoloursManager *sharedColoursManager;

@end

@implementation WWFaboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sharedColoursManager = [WWFcoloursManager sharedColoursManager]; //Get a reference to our shared colours manager.
    
    self.doneButton.tintColor = self.sharedColoursManager.selectableColour; //Set colour of the done button.
    
    //Get a URL for the RTF file containing the about text within the app bundle, and create an NSData object from the file.
    NSURL *aboutTextFilename = [[NSBundle mainBundle] URLForResource:@"about_text" withExtension:@".rtf"];
    NSData *aboutFileData = [NSData dataWithContentsOfURL:aboutTextFilename];
    
    NSDictionary *aboutTextOptionsValues = @{NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType}; //Create a dictionary containing attributes for use in creating an NSAttributedString. This attribute tells NSAttributedString that we wish to create a string and attributes from a RTF file.
    
    self.aboutTextView.editable = NO; //Ensure the about text is not editable.
    
    NSMutableAttributedString *aboutText = [[NSMutableAttributedString alloc] initWithData:aboutFileData options:aboutTextOptionsValues documentAttributes:NULL error:nil]; //Create an attributed string from the about text RTF file.
    
    [aboutText addAttribute:NSForegroundColorAttributeName value:self.sharedColoursManager.textColour range:NSMakeRange(0, aboutText.length)]; //Set the colour of the about text attributed string to our standard text colour.
    [self.aboutTextView setAttributedText:aboutText]; //Use our about text attributed string to populate the text view.
        
    self.view.backgroundColor = self.sharedColoursManager.backgroundColour; //Set the background colour of the view to our standard background colour.
    self.aboutTextView.backgroundColor = self.sharedColoursManager.backgroundColour; //Set the background colour of the text view to our standard background colour.
    
    
    self.aboutTextView.scrollEnabled = YES; //Ensure the text view is scrollable.
    [self.aboutTextView scrollRangeToVisible:NSMakeRange(0, 0)]; //This is supposed to scroll the text view to the top, but it isn't currently working.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)doneButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"Done action called");
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
