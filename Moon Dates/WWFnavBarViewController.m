//
//  WWFtabBarViewController.m
//  Moon Journal
//
//  Created by Andy Guttridge on 09/10/2017.
//  Copyright © 2017 Andy Guttridge. All rights reserved.
//

#import "WWFnavBarViewController.h"
#import "WWFcoloursManager.h"

@interface WWFnavBarViewController ()

@property (weak, nonatomic) WWFcoloursManager *sharedColoursManager;

@end

@implementation WWFnavBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sharedColoursManager = [WWFcoloursManager sharedColoursManager]; //Get a reference to the shared colours manager
    self.navigationBar.barTintColor = self.sharedColoursManager.backgroundColour; //Colour the navigation bar with the standard background colour from the shared colours manager.
    
    NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObject:self.sharedColoursManager.headerColour forKey:NSForegroundColorAttributeName];
    self.navigationBar.titleTextAttributes = titleTextAttributes;    
    
    
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
