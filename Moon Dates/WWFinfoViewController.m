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

//Load and display the instructions, which are saved as an HTML file within the app bundle.
- (void)viewDidLoad {
    [super viewDidLoad];
    //Create configuration object for web view, create new webview and set this view controller as the navigation delegate for the web view.
    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:theConfiguration];
    webView.navigationDelegate = self;
    
    //Get file path for HTML file, create URL request and ask web view to load the HTML.
    NSURL *instructionsURL = [[NSBundle mainBundle] URLForResource:@"mj_instructions_html" withExtension:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:instructionsURL];
    [webView loadRequest:request];
    
    //Ensure top of web view is inset so it doesn't overlap with the status bar, and display the webview.
    webView.scrollView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    [self.view addSubview:webView];
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
