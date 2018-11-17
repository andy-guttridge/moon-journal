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
@property (strong, nonatomic) WWFcoloursManager *sharedColoursManager;


@end

@implementation WWFtabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //The shared manager objects are 'owned' by this view controller, as it is the root view controller and both manager objects are required all of the time the app is running, therefore it makes sense to instantiate them here with strong references. 
    
    self.sharedMoonDatesManager = [WWFmoonDatesManager sharedMoonDatesManager];
    self.sharedUserDataManager = [WWFuserDataManager sharedUserDataManager];
    self.sharedColoursManager = [WWFcoloursManager sharedColoursManager];
    
    self.tabBar.tintColor = self.sharedColoursManager.selectableColour; //Set colour of the selected tab bar item using a colour from the sharedColoursManager.
    self.tabBar.barTintColor = self.sharedColoursManager.backgroundColour; //Set the background colour of the tab bar using the background colour from sharedColoursManager
    
    NSDictionary *barItemSelectedAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize: 20.0f], NSForegroundColorAttributeName : self.sharedColoursManager.highlightColour}; //Create a dictionary containting string attributes for our UITabBar items in the selected state;
    [[UITabBarItem appearance] setTitleTextAttributes:barItemSelectedAttributes forState:UIControlStateSelected]; //Assign the font attributes to the tab bar items, for both the selected state.
    
    NSDictionary *barItemUnselectedAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize: 20.0f], NSForegroundColorAttributeName : self.sharedColoursManager.selectableColour}; //Create a dictionary containting string attributes for our UITabBar items in the unselected state;
    [[UITabBarItem appearance] setTitleTextAttributes:barItemUnselectedAttributes forState:UIControlStateNormal]; //Assign the font attributes to the tab bar items, for both normal unselected states.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options)) completionHandler

//This method which is implemented as part of the UNNotificationCenter protocol handles notifications that are received while the app is running.

 
{
    
    completionHandler (UNNotificationPresentationOptionSound); //Run the completion handler provided by the system, specifying that we only want the system to provide an alert sound (not to display the alert - we have our own custom response instead).
    
    UINavigationController *calendarViewNavigationController = self.viewControllers [0]; //Grab a reference to the UINavigationController that displays our calendar and journal views.
    
    //Next we make the calendar view visible and scroll the table view to ensure that the appropriate moon date is visible. The below chunk of code to redraw the table could have been combined with this, but decided only to ask the table to refresh its data if it is already displayed, as a small optimisation.
    
    NSDate *notificationMoonDate; //To hold the Moon Date associated with this notification.
    
    if ((notificationMoonDate = [notification.request.content.userInfo objectForKey:@"MoonDate"])) //Get the moon date from the local notification object.
    {
                self.selectedIndex = 0; //Ensure the calendar view is selected.
                [calendarViewNavigationController popToRootViewControllerAnimated:YES]; //Make sure the calendar view is displayed (rather than the journal view).
                UIViewController *theCurrentViewController = calendarViewNavigationController.topViewController; //Grab a reference to the view controller currently at the top of the UINavigationController stack. Doing this again for safety, as the current view controller could have changed since the beginning of the method.
                NSString *classOfViewController = NSStringFromClass([theCurrentViewController class]); //Determine the class of the currently visible view controller.
                if ([classOfViewController  isEqual: @"WWF_FSCalViewController"]) //We have just asked the calendar view to be displayed, so shouldn't need to do this check, but just in case...
                {
                    WWF_FSCalViewController *theCalendarViewController = (WWF_FSCalViewController *) theCurrentViewController; //Cast theCurrentViewController to WWF_FSCalViewController, as we have have now already positively identified that it is of this class.
                    
                    [theCalendarViewController.theCalendarView selectDate:notificationMoonDate scrollToDate:YES]; //Ask the calendar to select and scroll to the moon date we have received a notification for.
                    
                    NSLog(@"Calendar scrolled to notification moon date");
                }
        
        }
    
        //Show an alert to indicate that a notification has been received.
        
    NSString *title = notification.request.content.title;
    NSString *message = notification.request.content.body;
    
    UIAlertController *notificationAlertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler: nil];
    
    [notificationAlertController addAction:OKAction];
    
    if (self.presentedViewController == nil) //We need to make sure we are not already presenting an alert as we can only present one at a time.
    {
        [self presentViewController:notificationAlertController animated:YES completion:nil];
    }

 

}

-(void) userNotificationCenter:(UNUserNotificationCenter *)notificationCenter didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler

{
    //In this method, which is implemented as part of the UNNotificationCenter protocol, if the user has selected a notification from outside the app, then we ask the calendar to select and scroll to the date for which the notification was received.
    
    
    completionHandler (); //Call the completion handler supplied by UNUserNotificationCenter
    
    if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) //We execute the following code if the user selected the notification (as opposed to dismissing it)
    {
        
        
        //Next we retrieve an array of delivered notifications that are still displayed in the notification centre, the last (most recent) one should be the one we are interested in. We provide a completion handler block to the getDeliveredNotificationsWithCompletionHandler method, which is provided with the array of notifications and carries out the necessary actions.
        
        [notificationCenter getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications)
        {
            UNNotification *theNotification = [notifications lastObject];
            
            NSDate *notificationMoonDate = [theNotification.request.content.userInfo objectForKey:@"MoonDate"]; //Get the moon date from the local notification object.
            
            UINavigationController *calendarViewNavigationController = self.viewControllers [0]; //Grab a reference to the UINavigationController that displays our calendar and journal views.
            self.selectedIndex = 0; //Ensure the calendar view is selected.
            [calendarViewNavigationController popToRootViewControllerAnimated:YES]; //Make sure the calendar view is displayed (rather than the journal view).
            
            UIViewController *theCurrentViewController = calendarViewNavigationController.topViewController; //Grab a reference to the view controller currently at the top of the UINavigationController stack.
            
            NSString *classOfViewController = NSStringFromClass([theCurrentViewController class]); //Determine the class of the currently visible view controller.
            if ([classOfViewController  isEqual: @"WWF_FSCalViewController"])
                
            {
                
                WWF_FSCalViewController *theCalendarViewController = (WWF_FSCalViewController *) theCurrentViewController; //Cast theCurrentViewController to WWF_FSCalViewController, as we have have now already positively identified that it is of this class.
                
                [theCalendarViewController.theCalendarView selectDate:notificationMoonDate scrollToDate:YES]; //Ask the calendar to select and scroll to the moon date associated with the notification.
                [theCalendarViewController.theCalendarView reloadData]; //Ask the calendar to reload its data to prevent some occasional anomalies.x
            }
    }];
}
 
}


@end
