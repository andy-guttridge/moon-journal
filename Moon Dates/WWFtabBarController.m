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

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //The shared manager objects are 'owned' by this view controller, as it is the root view controller and both manager objects are required all of the time the app is running,
    //so instantiate with strong references.
    
    self.sharedMoonDatesManager = [WWFmoonDatesManager sharedMoonDatesManager];
    self.sharedUserDataManager = [WWFuserDataManager sharedUserDataManager];
    self.sharedColoursManager = [WWFcoloursManager sharedColoursManager];
    
    self.tabBar.tintColor = self.sharedColoursManager.selectableColour;
    self.tabBar.barTintColor = self.sharedColoursManager.backgroundColour;
    
    //Create dictionary containting string attributes for UITabBar items in the selected state;
    NSDictionary *barItemSelectedAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize: 20.0f], NSForegroundColorAttributeName : self.sharedColoursManager.highlightColour};
    
    //Assign the font attributes to the tab bar items, for both the selected state.
    [[UITabBarItem appearance] setTitleTextAttributes:barItemSelectedAttributes forState:UIControlStateSelected];
    NSDictionary *barItemUnselectedAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize: 20.0f], NSForegroundColorAttributeName : self.sharedColoursManager.selectableColour};
    //Assign the font attributes to the tab bar items, for both normal unselected states.
    [[UITabBarItem appearance] setTitleTextAttributes:barItemUnselectedAttributes forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options)) completionHandler{
    //Method implemented as part of the UNNotificationCenter protocol.
    //Handles notifications that are received while the app is running.
    //Run completion handler provided by the system, specifying that we only want the system to provide an alert sound
    //We display our own alert instead of the system's we have our own custom response instead.
    completionHandler(UNNotificationPresentationOptionSound);
    
    //Grab a reference to the UINavigationController that displays our calendar and journal views.
    UINavigationController *calendarViewNavigationController = self.viewControllers [0];
    
    //Make calendar view visible and scroll the table view to ensure that the appropriate moon date is visible.
    NSDate *notificationMoonDate;
    //Get moon date from the local notification object.
    if ((notificationMoonDate = [notification.request.content.userInfo objectForKey:@"MoonDate"])){
        //Ensure the calendar view is selected.
        self.selectedIndex = 0;
        //Make sure calendar view is displayed (rather than the journal view), then get a reference to the view controller currently at the top of the UINavigationController stack.
        [calendarViewNavigationController popToRootViewControllerAnimated:YES];
        UIViewController *theCurrentViewController = calendarViewNavigationController.topViewController;
        
        NSString *classOfViewController = NSStringFromClass([theCurrentViewController class]);
        if ([classOfViewController  isEqual: @"WWF_FSCalViewController"]){
            WWF_FSCalViewController *theCalendarViewController = (WWF_FSCalViewController *) theCurrentViewController;
            //Ask the calendar to select and scroll to the moon date we have received a notification for.
            [theCalendarViewController.theCalendarView selectDate:notificationMoonDate scrollToDate:YES];
            NSLog(@"Calendar scrolled to notification moon date");
        }
    }
    
    //Show alert to indicate that a notification has been received.
    NSString *title = notification.request.content.title;
    NSString *message = notification.request.content.body;
    
    UIAlertController *notificationAlertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler: nil];
    [notificationAlertController addAction:OKAction];
    
    //Need to make sure we are not already presenting an alert.
    if (self.presentedViewController == nil){
        [self presentViewController:notificationAlertController animated:YES completion:nil];
    }
}

-(void) userNotificationCenter:(UNUserNotificationCenter *)notificationCenter didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    //Method implemented as part of the UNNotificationCenter protocol.
    //If user has selected a notification from outside the app, then we ask the calendar to select and scroll to the date for which the notification was received.
    completionHandler (); //Call the completion handler supplied by UNUserNotificationCenter
    
    if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]){
        //Handle notification if user selected it
        //Retrieve delivered notifications that are still displayed in the notification centre. The most recent one will be the one we are interested in. Provide a completion handler block to the getDeliveredNotificationsWithCompletionHandler method.
        
        [notificationCenter getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications){
            UNNotification *theNotification = [notifications lastObject];
            NSDate *notificationMoonDate = [theNotification.request.content.userInfo objectForKey:@"MoonDate"];
            
            //Get reference to the UINavigationController that displays our calendar and journal views, ensure the calendar view is selected and display it.
            UINavigationController *calendarViewNavigationController = self.viewControllers [0];
            self.selectedIndex = 0;
            [calendarViewNavigationController popToRootViewControllerAnimated:YES];
            
            //Get reference to the view controller currently at the top of the UINavigationController stack and determine its class.
            UIViewController *theCurrentViewController = calendarViewNavigationController.topViewController;
            NSString *classOfViewController = NSStringFromClass([theCurrentViewController class]);
            
            if ([classOfViewController  isEqual: @"WWF_FSCalViewController"]){
                WWF_FSCalViewController *theCalendarViewController = (WWF_FSCalViewController *) theCurrentViewController;
                //Ask the calendar to select and scroll to the moon date associated with the notification, and to reload its data (this prevents some occasional bugs)
                [theCalendarViewController.theCalendarView selectDate:notificationMoonDate scrollToDate:YES];
                [theCalendarViewController.theCalendarView reloadData];
            }
        }];
    }
}

@end
