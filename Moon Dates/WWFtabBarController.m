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
    if (self.selectedIndex == 0) //Ensure the calendar view redraws itself if a notification is received while it is displayed. This ensures the cells change colour appropriately.
    {
        UINavigationController *calendarViewNavigationController = self.viewControllers [0]; //Grab a reference to the UINavigationController that displays our calendar and journal views.
        UIViewController *theCurrentViewController = calendarViewNavigationController.topViewController; //Grab a reference to the view controller currently at the top of the UINavigationController stack.
        
        NSString *classOfViewController = NSStringFromClass([theCurrentViewController class]); //Determine the class of the currently visible view controller.
        if ([classOfViewController  isEqual: @"WWFcalendarViewController"])
            {
                WWFcalendarViewController *theCalendarViewController = (WWFcalendarViewController *) theCurrentViewController; //Cast theCurrentViewController to WWFcalednarViewController, as we have have now already positively identified that it is of this class.
                [theCalendarViewController.tableView reloadData]; //Get the calendar view controller to reload its data.
                
                NSLog(@"Called tableview reload from WWFtabBarController");
            }
    }
    
    //Show an alert to indicate that a notification has been received.
    
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
