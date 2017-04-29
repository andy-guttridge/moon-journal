//
//  ViewController.m
//  Moon Dates
//
//  Created by Andy Guttridge on 29/05/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#import "WWFtabBarController.h"

@interface WWFtabBarController ()

@property (weak, nonatomic) WWFmoonDatesManager *sharedMoonDatesManager;
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

-(void) didReceiveNotificationWhileAppRunning:(UILocalNotification *)theNotification
{
    UINavigationController *calendarViewNavigationController = self.viewControllers [0]; //Grab a reference to the UINavigationController that displays our calendar and journal views.
    
    if (self.selectedIndex == 0) //Ensure the calendar view redraws itself if a notification is received and it is already displayed. This ensures the cells change colour appropriately.
    {
        UIViewController *theCurrentViewController = calendarViewNavigationController.topViewController; //Grab a reference to the view controller currently at the top of the UINavigationController stack.
        NSString *classOfViewController = NSStringFromClass([theCurrentViewController class]); //Determine the class of the currently visible view controller.
        if ([classOfViewController  isEqual: @"WWFcalendarViewController"])
            {
                WWFcalendarViewController *theCalendarViewController = (WWFcalendarViewController *) theCurrentViewController; //Cast theCurrentViewController to WWFcalednarViewController, as we have have now already positively identified that it is of this class.
                [theCalendarViewController.tableView reloadData]; //Get the calendar view controller to reload its data.
                
                NSLog(@"Called tableview reload from WWFtabBarController");
            }
        
       
        }
    
    //Next we make the calendar view visible and scroll the table view to ensure that the appropriate moon date is visible. The above chunk of code to redraw the table could have been combined with the below, but decided only to ask the table to refresh its data if it is already displayed, as a small optimisation.
    
    NSDate *notificationMoonDate; //To hold the Moon Date associated with this notification.
    NSUInteger i = 0; //Counter, matching the index of the moon date array for each moon date, which we can use to tell the table view which view to scroll to.
    
    if ((notificationMoonDate = [theNotification.userInfo objectForKey:@"MoonDate"])) //Get the moon date from the local notification object.
    {
        for (NSDictionary *aMoonDatesDictionary in self.sharedMoonDatesManager.moonDatesArray) //Iterate through the moonDatesDictionaries in the moon dates array.
        {
            NSDate *aMoonDate = [aMoonDatesDictionary objectForKey:@"MoonDate"]; //Get the next moon date from the dictionary.
            if ([aMoonDate isEqual:notificationMoonDate]) //Compare the next moon date with the moon date from the notification.
            {
                self.selectedIndex = 0; //Ensure the calendar view is selected.
                [calendarViewNavigationController popToRootViewControllerAnimated:YES]; //Make sure the calendar view is displayed (rather than the journal view).
                UIViewController *theCurrentViewController = calendarViewNavigationController.topViewController; //Grab a reference to the view controller currently at the top of the UINavigationController stack. Doing this again for safety, as the current view controller could have changed since the beginning of the method.
                NSString *classOfViewController = NSStringFromClass([theCurrentViewController class]); //Determine the class of the currently visible view controller.
                if ([classOfViewController  isEqual: @"WWFcalendarViewController"]) //We have just asked the calendar view to be displayed, so shouldn't need to do this check, but just in case...
                {
                    WWFcalendarViewController *theCalendarViewController = (WWFcalendarViewController *) theCurrentViewController; //Cast theCurrentViewController to WWFcalednarViewController, as we have have now already positively identified that it is of this class.
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0]; //Create an NSIndexPath using our index counter as the value for the row.
                    [theCalendarViewController.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES]; //Ask the calendar view controller's table view to scroll to the correct row.
                    
                    NSLog(@"Scrolled to row %ld", (long) indexPath.row);
                }
                
            }
            
            i++;
        }

    }
    
    //Show an alert to indicate that a notification has been received.
    
    NSString *title = theNotification.alertTitle;
    NSString *message = theNotification.alertBody;
    
    UIAlertController *notificationAlertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler: nil];
    
    [notificationAlertController addAction:OKAction];
    
    if (self.presentedViewController == nil) //We need to make sure we are not already presenting an alert as we can only present one at a time.
    {
       [self presentViewController:notificationAlertController animated:YES completion:nil];
    }
    
}

-(void) didReceiveNotificationOnAppLaunch:(UILocalNotification *)theNotification
{
    //In this method, we iterate through each of the moon dates in the moon dates array, and compare them with the moon date associated with the notification we have received.
    //If we find a match, we switch to the calendar view controller and ask its table view to scroll to the row in the table associated with the matching moon date.
    
    NSDate *notificationMoonDate; //To hold the Moon Date associated with this notification.
    NSUInteger i = 0; //Counter, matching the index of the moon date array for each moon date, which we can use to tell the table view which view to scroll to.
    
    if ((notificationMoonDate = [theNotification.userInfo objectForKey:@"MoonDate"])) //Get the moon date from the local notification object.
    {
        for (NSDictionary *aMoonDatesDictionary in self.sharedMoonDatesManager.moonDatesArray) //Iterate through the moonDatesDictionaries in the moon dates array.
        {
            NSDate *aMoonDate = [aMoonDatesDictionary objectForKey:@"MoonDate"]; //Get the next moon date from the dictionary.
            if ([aMoonDate isEqual:notificationMoonDate]) //Compare the next moon date with the moon date from the notification.
            {
                UINavigationController *calendarViewNavigationController = self.viewControllers [0]; //Grab a reference to the UINavigationController that displays our calendar and journal views.
                self.selectedIndex = 0; //Ensure the calendar view is selected.
                [calendarViewNavigationController popToRootViewControllerAnimated:YES]; //Make sure the calendar view is displayed (rather than the journal view).
                
                UIViewController *theCurrentViewController = calendarViewNavigationController.topViewController; //Grab a reference to the view controller currently at the top of the UINavigationController stack.
                
                NSString *classOfViewController = NSStringFromClass([theCurrentViewController class]); //Determine the class of the currently visible view controller.
                if ([classOfViewController  isEqual: @"WWFcalendarViewController"])
                {
                    WWFcalendarViewController *theCalendarViewController = (WWFcalendarViewController *) theCurrentViewController; //Cast theCurrentViewController to WWFcalednarViewController, as we have have now already positively identified that it is of this class.
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0]; //Create an NSIndexPath using our index counter as the value for the row.
                    [theCalendarViewController.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES]; //Ask the calendar view controller's table view to scroll to the correct row.
                }
                
            }
            
            i++;
        }
    }
    
}

@end
