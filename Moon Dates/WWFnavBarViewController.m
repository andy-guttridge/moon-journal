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

- (void)viewDidLoad{
    [super viewDidLoad];
    // Color the navigation bar
    self.sharedColoursManager = [WWFcoloursManager sharedColoursManager];
    self.navigationBar.barTintColor = self.sharedColoursManager.backgroundColour;
    
    //Create a dictionary with text attributes for the navigation bar title and assign text attributes to the nav bar title.
    NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObject:self.sharedColoursManager.headerColour forKey:NSForegroundColorAttributeName];
    self.navigationBar.titleTextAttributes = titleTextAttributes;
    
    //Create attributes for UITabBar items in the selected state and assign to the tab bar items for the selected state
    NSDictionary *barItemSelectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16.0f], NSFontAttributeName, self.sharedColoursManager.highlightColour,NSForegroundColorAttributeName,nil];
    [[UITabBarItem appearance] setTitleTextAttributes:barItemSelectedAttributes forState:UIControlStateSelected];
    
    //Create attributes and assign to the tab bar items for the unselected state.
    NSDictionary *barItemUnselectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16.0f], NSFontAttributeName, self.sharedColoursManager.selectableColour,NSForegroundColorAttributeName,nil];
    [[UITabBarItem appearance] setTitleTextAttributes:barItemUnselectedAttributes forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
