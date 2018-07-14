//
//  WWFinfoViewController.m
//  Moon Dates
//
//  Created by Andy Guttridge on 29/05/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#import "WWFinfoViewController.h"
#import "WWFcoloursManager.h"

@interface WWFinfoViewController ()

@property (weak,nonatomic) WWFcoloursManager *sharedColoursManager; //The shared colours manager

@end

@implementation WWFinfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Here we load and display the instructions, which are saved as an HTML file within the app bundle.
    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init]; //Create a configuration object for our web view.
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:theConfiguration]; //Create a new webview, using the frame of our UIView to do so.
    webView.navigationDelegate = self; //Set this view controller as the navigation delegate for the web view (though none of the delegate methods are implemented as they are unnecessary for this use case).
    NSURL *instructionsURL = [[NSBundle mainBundle] URLForResource:@"mj_instructions_html" withExtension:@"html"];//Find the file path for the HTML file in the app bundle.
    NSURLRequest *request = [NSURLRequest requestWithURL:instructionsURL]; //Create a URL request using the file path to the HTML file.
    [webView loadRequest:request]; //Ask the web view to load the HTML file.
    webView.scrollView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0); //Ensure the top of the web view is inset so as not to overlap with the status bar.
    [self.view addSubview:webView]; //Display the HTML file by adding the web view to our UIView.

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
