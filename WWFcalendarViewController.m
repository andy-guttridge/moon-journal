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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Create a 20px vertical gap at the top of the table view so that there is a gap between it and the status bar.
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
  
    
    //Get the sharedMoonDatesManager, the sharedUserDataManager and create an instance of and do the set up for an NSDateFormatter. The locale for the NSDateFormatter is retrieved from the sharedUserPrefsManager.
    self.sharedMoonDatesManager = [WWFmoonDatesManager sharedMoonDatesManager];
    self.sharedUserDataManager = [WWFuserDataManager sharedUserDataManager];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
    self.dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:[self.sharedUserDataManager.userDataDictionary objectForKey:@"DateFormat"]];
    
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
    
    //Next, retrieving the NSInteger that represents the type of moon event (as per the Moontype enumerated values in Constants.h). This is embedded in a case...swith statement that assigns the appropriate text to an NSString, which is then used to populate the cell.detailTextLabel.text property.
    
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
    
    cell.detailTextLabel.text = detailText;   
    
    return cell;
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
