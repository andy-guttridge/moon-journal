//
//  WWFinfoViewController.m
//  Moon Dates
//
//  Created by Andy Guttridge on 29/05/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#import "WWFinfoViewController.h"

@interface WWFinfoViewController ()

@property IBOutlet UITextView *infoView; //The UITextView used to display instructions for the app
@property NSMutableAttributedString *infoText; //The text for the instructions for the app

@end

@implementation WWFinfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"mj_app_instructions" ofType:@"rtf"]; //Find the path to the RTF file containing the instructions for the app
    NSData *instructionsRTF = [NSData dataWithContentsOfFile:path]; //Load the RTF file into an NSData object
    NSDictionary *attributesForInitialisingNSAttributedString = @{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType}; //Create a NSDictionary containing an atributes dictionary for use when creating an NSAttributedString. The attribute within this NSDictionary tells NSAttributedString that we are creating an attributed string from a RTF document.
    
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]; //Extract version number of the app from info.plist
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]; //Extract build number of the app from info.plist
    
    NSString * appVersionAndBuildStringWithHeadings = [NSString stringWithFormat:@"\n \n Version: %@ \n \n Build Number: %@", appVersionString, appBuildString];
    
    self.infoText = [[NSMutableAttributedString alloc] initWithData: instructionsRTF options:attributesForInitialisingNSAttributedString documentAttributes:NULL error:NULL]; //Create an NSMutableAttributedString from the RTF.
    
    NSAttributedString *appVersionandBuildNumbers = [[NSAttributedString alloc]initWithString:appVersionAndBuildStringWithHeadings];
    
    [self.infoText appendAttributedString:appVersionandBuildNumbers];
     
    self.infoView.attributedText = self.infoText; //Set our UITextViews attributedText property to our NSAttributedString containing the text from our RTF.
    
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
