//
//  ViewController.m
//  Moon Dates
//
//  Created by Andy Guttridge on 29/05/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#import "WWFtabBarController.h"

@interface WWFtabBarController ()

@property (strong, nonatomic) WWFmoonDatesManager *sharedMoonDatesManager;
@property (strong, nonatomic) WWFuserDataManager *sharedUserDataManager;
@end

@implementation WWFtabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Both of the shared manager objects are 'owned' by this view controller, as it is the root view controller and both manager objects are required all of the time the app is running, therefore it makes sense to instantiate them here with strong references. 
    
    self.sharedMoonDatesManager = [WWFmoonDatesManager sharedMoonDatesManager];
    self.sharedUserDataManager = [WWFuserDataManager sharedUserDataManager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) didReceiveNotification:(UILocalNotification *)theNotification
{
    NSString *title = @"Moon Date Notification";
    NSString *message = theNotification.alertBody;
    
    UIAlertController *notificationAlertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler: nil];
    
    [notificationAlertController addAction:OKAction];
    
    if (self.presentedViewController == nil) //We need to make sure we are not already presenting an alert as we can only present one at a time.
    {
       [self presentViewController:notificationAlertController animated:YES completion:nil];
    }
    
}

@end
