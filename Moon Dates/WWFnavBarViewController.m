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
    
    NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObject:self.sharedColoursManager.headerColour forKey:NSForegroundColorAttributeName]; //Create a dictionary with text attributes for the navigation bar title.
    self.navigationBar.titleTextAttributes = titleTextAttributes; //Assign the text attributes to the navigation bar title.
    
    
    NSDictionary *barItemSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16.0f], NSFontAttributeName, self.sharedColoursManager.highlightColour,NSForegroundColorAttributeName,nil]; //Create a dictionary containting string attributes for our UITabBar items in the slected state;
    [[UITabBarItem appearance] setTitleTextAttributes:barItemSelectedAttributes forState:UIControlStateSelected]; //Assign the font and colour attributes to the tab bar items, for the selected state.
    
    NSDictionary *barItemUnselectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16.0f], NSFontAttributeName, self.sharedColoursManager.selectableColour,NSForegroundColorAttributeName,nil]; //Create a dictionary containting string attributes for our UITabBar items in the slected state;
    [[UITabBarItem appearance] setTitleTextAttributes:barItemUnselectedAttributes forState:UIControlStateNormal]; //Assign the font and colour attributes to the tab bar items, for the selected state.
   
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
