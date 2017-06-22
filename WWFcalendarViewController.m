//
//  WWFcalendarViewControllerTableViewController.m
//  Moon Dates
//
//  Created by Andy Guttridge on 29/05/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#import "WWFcalendarViewController.h"
#import "WWFuserDataManager.h"

@interface WWFcalendarViewController ()

@property NSDateFormatter *dateFormatter;
@property (weak, nonatomic) WWFuserDataManager *sharedUserDataManager;
@property (weak, nonatomic) WWFmoonDatesManager *sharedMoonDatesManager;

@end

@implementation WWFcalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    

    //Get the sharedMoonDatesManager, the sharedUserDataManager and create an instance of and do the set up for an NSDateFormatter. The locale for the NSDateFormatter is retrieved from the sharedUserPrefsManager.
    self.sharedMoonDatesManager = [WWFmoonDatesManager sharedMoonDatesManager];
    self.sharedUserDataManager = [WWFuserDataManager sharedUserDataManager];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
    self.dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:[self.sharedUserDataManager.userDataDictionary objectForKey:@"DateFormat"]];
    
    //Here we register to received UIApplicationWillEnterForegroundNotification and call the [self redrawTableView:] method, to ensure that the tableview cells are updated if the user switches back to our app having been using a different app, locked their device etc.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (redrawTableView:) name:UIApplicationWillEnterForegroundNotification object:nil];

}

- (void) viewWillAppear:(BOOL)animated
//This method is implemented to ensure that tableview cells are highlighted correctly if anything has changed after switching back from another view.
{
    NSLog(@"WWFcalendarViewController viewWillAppear called.");
    [super viewWillAppear:animated];
    [self redrawTableView: self];
}

- (void) redrawTableView:(id) sender
{
    //Here we redraw the tableview cells. This method is called either from viewWillAppear:, which takes account of changes of view while the app is active, or as a result of a UIApplicationWillEnterForegroundNotification, which ensures the view is updated when the user returns to the app having used a different app, locked their device etc.
    NSLog(@"WWFcalendarViewController redrawTableView: called");
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //Only one section in this table view.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //We need one row for each item in the moonDatesArray, i.e. one for each moon date in the data set.
    return [self.sharedMoonDatesManager.moonDatesArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MoonDateCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell. We use the sharedMoonDatesManager to retreive the moon event date corresponding to the row of the cell, and to retrieve the type of moon event. We then use these to populate the cell.
    
    //Firstly, retrieving the NSDate from the moonDatesArray and using the dateFormatter to produce a string from the NSDate to populate the cell.textLabel.text property.
    
    NSDate *aMoonDate = [self.sharedMoonDatesManager.moonDatesArray [indexPath.row] objectForKey:@"MoonDate"];
    NSString *cellText = [self.dateFormatter stringFromDate:aMoonDate];
    cell.textLabel.text = cellText;
    
    //Next, retrieving the NSInteger that represents the type of moon event (as per the Moontype enumerated values in Constants.h). This is embedded in a case...switch statement that assigns the appropriate text to an NSString, which will later be used to populate the cell.detailTextLabel.text property.
    
    NSString *detailText = [[NSString alloc]init];
    switch ([[self.sharedMoonDatesManager.moonDatesArray [indexPath.row] objectForKey:@"Type"]intValue])
    {
        case kNoMoonEvent:
            detailText = @"No moon event";
            break;
        
        case kNewMoon:
            detailText = @"New Moon";
            break;
            
        case kFullMoon:
            detailText = @"Full Moon";
            break;
            
        default:
            detailText = @"Invalid moon event type";
            break;
    }
    
    
     cell.detailTextLabel.text = detailText; //Set the detailTextLabel property of the cell to display the moon event type.
    
    //Change the colour of the cell to blue with white text if the current time is within and before the 'notification window',  to orange with white text if the current time is within a specified time after the moon event (kLetItGoAllowedInterval), or to white but with grey text if the moon date has already passed.
    
    NSNumber *intervalUntilDate = [NSNumber numberWithDouble: (double)[aMoonDate timeIntervalSinceNow]]; //The amount of time until or after the moon date.
    NSNumber *notificationOffset = [NSNumber numberWithInteger: labs (self.sharedMoonDatesManager.notificationOffset)]; //Get the notification offset from the sharedMoonDatesManager, and use the C labs function to convert it to an absolute (unsigned) value. This is because the notification system needs a negative number for the pre-notifications, but we need a positive value here to use the intervalUntilDate method of NSDate to compare the amount of time until the moon event with the notification offset.
    NSNumber *letItGoAllowedInterval = [NSNumber numberWithInt:kAllowedLetItGoInterval]; //Turn the pre-defined constant into an NSNumber.
    
    if (([intervalUntilDate compare:notificationOffset] == NSOrderedAscending) && [intervalUntilDate floatValue] >= 0)
    {
        cell.backgroundColor = [UIColor blueColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
    }
    
    else if (([intervalUntilDate compare:letItGoAllowedInterval] == NSOrderedDescending) && [intervalUntilDate floatValue] <= 0)
    {
        cell.backgroundColor = [UIColor orangeColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
    }
    
    else if (([intervalUntilDate compare:letItGoAllowedInterval] == NSOrderedAscending) && [intervalUntilDate floatValue] < 0)
    {
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    
    else //Ensure that cells are set to normal colours if not within notification range, otherwise we can end up with incorrectly coloured cells when they are dequeued and reused.
    {
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

#pragma mark - Navigation

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //This is where we set the properties of the journal view controller, pass it any information it needs, etc.
    //For now, we simply pass the index row of the selected cell from the calendar view to the journalViewController, so that the journalViewController can use this as an index into the
    //Moon Dates array in the sharedMoonDatesManager. This system might have to change later if we change the approach to managed the moon dates or journal data.
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    WWFjournalViewController *journalViewController = segue.destinationViewController;
    journalViewController.indexForMoonDatesArray = indexPath.row;
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
