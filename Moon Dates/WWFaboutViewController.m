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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sharedColoursManager = [WWFcoloursManager sharedColoursManager]; //Get a reference to our shared colours manager.
    self.doneButton.tintColor = self.sharedColoursManager.selectableColour; //Set colour of the done button.
    
    //Get URL for the RTF file containing the about text within the app bundle, and create an NSData object from the file.
    NSURL *aboutTextFilename = [[NSBundle mainBundle] URLForResource:@"about_text" withExtension:@".rtf"];
    NSData *aboutFileData = [NSData dataWithContentsOfURL:aboutTextFilename];
    
    //Create dictionary containing attributes for use in creating an NSAttributedString. This attribute tells NSAttributedString that we wish to create a string and attributes from a RTF file.
    NSDictionary *aboutTextOptionsValues = @{NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType};
    
    //Ensure the about text is not editable, create attributed string from about text RTF file, and set text colour.
    self.aboutTextView.editable = NO;
    NSMutableAttributedString *aboutText = [[NSMutableAttributedString alloc] initWithData:aboutFileData options:aboutTextOptionsValues documentAttributes:NULL error:nil];
    [aboutText addAttribute:NSForegroundColorAttributeName value:self.sharedColoursManager.textColour range:NSMakeRange(0, aboutText.length)];
    
    //Populate the text view, set background colours of the containing view and the text view.
    [self.aboutTextView setAttributedText:aboutText];
    self.view.backgroundColor = self.sharedColoursManager.backgroundColour;
    self.aboutTextView.backgroundColor = self.sharedColoursManager.backgroundColour;
    
    //Ensure text view is scrollable and ensure the start of the text is visible.
    self.aboutTextView.scrollEnabled = YES;
    [self.aboutTextView scrollRangeToVisible:NSMakeRange(0, 0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonAction:(id)sender {
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
