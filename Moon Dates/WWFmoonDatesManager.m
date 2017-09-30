//
//  WWFmoonDatesManager.m
//  Moon Dates
//
//  Created by Andy Guttridge on 29/05/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#import "WWFmoonDatesManager.h"

@interface WWFmoonDatesManager ()

@property (strong, nonatomic) NSMutableArray *moonDatesArray;
@property (weak, nonatomic) WWFuserDataManager *sharedUserDataManager;

@end

@implementation WWFmoonDatesManager

+(instancetype)sharedMoonDatesManager

//Create a single instance of WWFmoonDatesManager and return this if it has not been created already. If it has, do not create again and return the single instance already created.
{
    static WWFmoonDatesManager *moonDatesManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once (&onceToken, ^{moonDatesManager = [[self alloc]init];});
    
    return moonDatesManager;
}

-(instancetype)init
{
    self = [super init];
    
    if (self)
    {
        //We need to load the moon dates data from the plist file called MoonDatesData.plist which is stored in the documents folder. If the file doesn't exist, then we
        //first make a copy of the file with the same name that is stored within the app bundle (this is likely to be the case when the app is run for the first time).
        //The necessary moon dates data is initially provided within the plist file in the app bundle, but we need to be able to write to this file as the user adds
        //journal data, which is why we copy it to the documents folder.
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *pathsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentDirectoryPath = [pathsArray objectAtIndex:0];
        NSString *moonDatesPath = [documentDirectoryPath stringByAppendingString:@"/MoonDatesData.plist"];
        
        if (![fileManager fileExistsAtPath:moonDatesPath])
        {
            NSLog(@"MoonDatesData.plist did not exist in documents folder. Attempting to copy from app bundle");
            NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"MoonDatesData" ofType:@"plist"];
            [fileManager copyItemAtPath:sourcePath toPath:moonDatesPath error:nil]; //We may want to think about retrieving the error data here in future.
        }
        else
        {
            NSLog(@"MoonDatesData.plist exists in documents folder.");
        }
        
        if (!(self.moonDatesArray = [NSMutableArray arrayWithContentsOfFile:moonDatesPath]))
        {
            NSLog(@"Failed to open MoonDatesData.plist in [WWFMoonDatesManager init]");
        }
        
        //Check the "WWF Generate Test Data" key in the info plist file to see whether we need to generate some test data for testing notifications. If so then call the generateTestData method.
        NSNumber *generateTestData = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"WWF Generate Test Data"];
        if ([generateTestData boolValue])
        {
            [self generateTestData];
        }
        
        //Use the sharedUserDataManager to retrieve the time offset for user notification of moon events. Then iterate through the array of moonDatesArray of dictionaries, and create a new NSDate for the notification time for each of them based on the time offset. Insert each of these NSDate objects into the moonDatesArray with the key "NotificationDate". This method also replaces all of the NSDictionaries within the array with mutable copies, otherwise we would not be able to add the notification times to them.
        
        //Even if we move the code to offset the notifications and stop storing them in the dictionary, we will still need to load the notification offset from the plist file, as it is used elsewhere.
        self.sharedUserDataManager = [WWFuserDataManager sharedUserDataManager];
        self.notificationOffset = [[self.sharedUserDataManager.userDataDictionary objectForKey:@"NotificationInterval"] integerValue];
        if (self.notificationOffset == 0)
        {
            NSLog(@"Could not retrieve objectForKey NotificationInterval from userDataDictionary");
        }
        
        NSMutableArray *copyOfMoonDatesArray = [[NSMutableArray alloc]initWithArray:self.moonDatesArray copyItems:YES]; //Create a mutable copy of the moonDatesArray, as we cannot make changes to a NSMutableArray while using fast enumeration.
        
        //Next we iterate through moonDatesArray, pulling out each moonDatesDictionary, creating a mutable copy, and replacing the original dictionary in the array with the mutable copy.
        
        for (NSDictionary *moonDatesDictionary in self.moonDatesArray)
        {
            //Make a mutable copy of each moonDatesDictionary and replace the original in the array with the mutable copy.
            NSMutableDictionary *mutableMoonDatesDictionary = [[NSMutableDictionary alloc] initWithDictionary:moonDatesDictionary copyItems:YES];
            NSUInteger i = [copyOfMoonDatesArray indexOfObject:moonDatesDictionary];
            [copyOfMoonDatesArray replaceObjectAtIndex:i withObject:mutableMoonDatesDictionary];
        }
        self.moonDatesArray = [copyOfMoonDatesArray mutableCopy]; //Copy the contents of copyOfMoonDates array back into the proper version of the array.
        
        //Schedule notifications
        
        //If this version of the app is running for the first time, then we want to schedule all of the notifications (the scheduleNotifications method also deletes existing notifications).
        //Updates to the list of moon events will be included in updates, and at those times the notifications will need to be rescheduled as there will be new dates further into the future included.
        //We hard code a version number and store this using NSUserDefaults, so that we can then do a comparison and see if the hard coded and the stored version numbers match. If they don't then we know our app has been updated and we need to schedule the notifications.
        
        NSInteger currentVersion = 0; //This needs to be incremented with each new version of the app. A value of zero will always cause notifications to be scheduled and is to be used for testing purposes.
        
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"HasLaunchedForVersion"] < currentVersion || currentVersion == 0)
        {
            [[NSUserDefaults standardUserDefaults] setInteger:currentVersion forKey:@"HasLaunchedForVersion"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self scheduleNotifications];
            NSLog(@"This version of the app has run for the first time. Notifications scheduled.");
        }
        
        else
        {
            NSLog(@"This version of the app has run before. Notifications not scheduled");
        }
           
        //Next we register to receive an OS notification when the Home button is pressed, so that we can save our data at that point. When we receive this notification,
        //the applicationWillResignActive: method within this class is called.
        
        UIApplication *app = [UIApplication sharedApplication];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:app];
        
    }
    
    return self;
}

-(void) removeOldNotificationBadge
{
//Iterate through the moon dates to see if the current date is within the range of time before or after each moon date that the journal entry can be released. If it is and the ritual has not yet been performed for that date, then we take no action, but if not or if it is but the ritual hasn't been performed, we clear any notification badges that are still showing. This is because in the event of the user not releasing their journal entry in time or the ritual having already been performed, we would end up with a notification badge showing that is no longer relevant.

    BOOL foundMoonDateInRange = NO; //We set this flag if we find a moon date within the range that the ritual could be performed AND for which the ritual has not yet been performed.
    int i = 0;
    for (NSDictionary *moonDatesDictionary in self.moonDatesArray)
    {
        //Check if current moon date is within range that it could be released, and check whether it has been released, and set a flagif we find a date within range for which the ritual has not yet been performed.
        NSDate *aMoonDate = [self.moonDatesArray [i] objectForKey:@"MoonDate"];
        NSNumber *intervalUntilDate = [NSNumber numberWithDouble: (double)[aMoonDate timeIntervalSinceNow]]; //The amount of time until or after the moon date.
        NSNumber *notificationOffset = [NSNumber numberWithInteger: labs (self.notificationOffset)]; //Get the notification offset, and use the C labs function to convert it to an absolute (unsigned) value. This is because the notification system needs a negative number for the pre-notifications, but we need a positive value here to use the intervalUntilDate method of NSDate to compare the amount of time until the moon event with the notification offset.
        NSNumber *letItGoAllowedInterval = [NSNumber numberWithInt:kAllowedLetItGoInterval]; //Turn the pre-defined constant into an NSNumber.
        
        //Here we set the flag if the moon date has not yet passed but we are within range of the notification of the moon date having been issued and the ritual not yet having been performed.
        if ((([intervalUntilDate compare:notificationOffset] == NSOrderedAscending) && [intervalUntilDate floatValue] >= 0) && ([[self.moonDatesArray [i] objectForKey:@"Released"] boolValue] == NO))
        {
            foundMoonDateInRange = YES;
        }
        
        //Here we set the flag if the moon date has passed but we are within range that the ritual can still be performed but hasn't yet.
        if ((([intervalUntilDate compare:letItGoAllowedInterval] == NSOrderedDescending) && [intervalUntilDate floatValue] <= 0) && ([[self.moonDatesArray [i] objectForKey:@"Released"] boolValue] == NO))
        {
            foundMoonDateInRange = YES;
        }
        i++;
    }
    
    if (foundMoonDateInRange == NO) //If we set our flag to NO then we clear any notification badges that are lingering, as we have determined that it is not possible to perform a moon ritual at this time.
    {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

-(void) generateTestData
{
    


// Use the following chunk of code to generate some test events that are only minutes apart for quick and immediate testing
 
// ________________________________________________________________________________________________________________________________________________________________
 
//Get todays date plus 60 seconds, and use this to generate and add some test dates to some Dictionaries, set the "Type" key to new moon (just for the sake of having some test data), add a BOOL with the key 'Released' (this is used to keep a record of whether the journal entry has been 'released') and then add the Dictionaries to our moonDatesArray. The notification dates will be generated in the init method, and if we have the notification interval set to the default three days, then we end up with some very convenient notification dates for testing purposes.
/*
{
    NSDate *todaysDatePlus60seconds = [NSDate dateWithTimeIntervalSinceNow: 60]; //259200 is the number of seconds in three 24 hour days.
    
    for (int i = 0; i < 30; i++)
    {
        NSDate *newMoonDate = [NSDate dateWithTimeInterval:i*180 sinceDate:todaysDatePlus60seconds];
        NSNumber *newMoonDateType = [NSNumber numberWithInt:kNewMoon];
        NSString *newMoonDateJournalString = @"";
        NSNumber *released = [NSNumber numberWithBool:NO];
        NSDictionary *newMoonDateDictionary = [NSDictionary dictionaryWithObjectsAndKeys:newMoonDate, @"MoonDate", newMoonDateType, @"Type", newMoonDateJournalString, @"JournalText", released, @"Released", nil];
        [self.moonDatesArray addObject:newMoonDateDictionary];
    }
    
}
*/
    
//__________________________________________________________________________________________________________________________________________________________________

//Use the following chunk of code to generate some test events that are one hour apart for more realistic testing. The first event will be 15 minutes from the current time.
    
    {
        NSDate *todaysDatePlus15minutes = [NSDate dateWithTimeIntervalSinceNow: 900]; //900 is the number of seconds in 15 minutes.
        
        for (int i = 0; i < 30; i++)
        {
            NSDate *newMoonDate = [NSDate dateWithTimeInterval:i*3600 sinceDate:todaysDatePlus15minutes];
            NSNumber *newMoonDateType = [NSNumber numberWithInt:kNewMoon];
            NSString *newMoonDateJournalString = @"";
            NSNumber *released = [NSNumber numberWithBool:NO];
            NSDictionary *newMoonDateDictionary = [NSDictionary dictionaryWithObjectsAndKeys:newMoonDate, @"MoonDate", newMoonDateType, @"Type", newMoonDateJournalString, @"JournalText", released, @"Released", nil];
            [self.moonDatesArray addObject:newMoonDateDictionary];
        }
        
    }
 
//  ________________________________________________________________________________________________________________________________________________________________
 


// Use the following chunk of code to generate alternating new moon and full moon test dates from a fixed base date. Full moons will be three days after a new moon, with the next new moon four days after a full moon.

//  ________________________________________________________________________________________________________________________________________________________________
/*
    
    //Set up a date formatter which we use to create a date from a string.
    NSDateFormatter *aDateFormatter = [[NSDateFormatter alloc] init];
    aDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:[self.sharedUserDataManager.userDataDictionary objectForKey:@"DateFormat"]];
    aDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    aDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *baseTestDateString = @kTestDataDateString; //A string to use to create an NSDate which will be the base date used to calculate the test dates.
    NSDate *baseTestDate = [aDateFormatter dateFromString:baseTestDateString]; //Use the NSDateFormatter to create a base date from a string.
    
    NSNumber *released = [NSNumber numberWithBool:NO]; //Create an NSNumber containing a Bool set to No, for adding to our moon date dictionaries that will hold the test dates.
    NSNumber *newMoonDateType = [NSNumber numberWithInt:kNewMoon]; //Create an NSNumber containing an integer denoting a new moon, for adding to our moon date dictionaries that will hold the test dates.
    NSNumber *fullMoonDateType = [NSNumber numberWithInt:kFullMoon]; ///Create an NSNumber containing an integer denoting a full moon, for adding to our moon date dictionaries that will hold the test dates.
    NSString *moonDateJournalString = @""; //Create an empty journal string for adding to our moon date dictionaries that will hold the test dates.
    
    NSUInteger secondsFromBaseDate = 0; //This integer will be incremented after each test date is created and used to calculate the next date.
    
    for (NSUInteger i = 0; i < 11; i++)
    {
        
        //Create the next new moon test date using the baseTestDate and adding secondsFromBaseDate. Create a new moon dates dictionary and add it to our array of moon dates.
        NSDate *nextNewMoonTestDate = [baseTestDate dateByAddingTimeInterval:secondsFromBaseDate];
        NSDictionary *nextNewMoonTestDateDictionary = [NSDictionary dictionaryWithObjectsAndKeys:nextNewMoonTestDate, @"MoonDate", newMoonDateType, @"Type", moonDateJournalString, @"JournalText", released, @"Released", nil];
        [self.moonDatesArray addObject:nextNewMoonTestDateDictionary];
        
        secondsFromBaseDate = secondsFromBaseDate + (kNumberOfSecondsInADay * 3); //Increment secondsFromBaseDate ready for calculating the next full moon.
        
        //Create the next full moon test date using the baseTestDate and adding secondsFromBaseDate. Create a new moon dates dictionary and add it to our array of moon dates.
        NSDate *nextFullMoonTestDate = [baseTestDate dateByAddingTimeInterval:secondsFromBaseDate];
        NSDictionary *nextFullMoonTestDateDictionary = [NSDictionary dictionaryWithObjectsAndKeys:nextFullMoonTestDate, @"MoonDate", fullMoonDateType, @"Type", moonDateJournalString, @"JournalText", released, @"Released", nil];
        [self.moonDatesArray addObject:nextFullMoonTestDateDictionary];
        
        secondsFromBaseDate = secondsFromBaseDate + (kNumberOfSecondsInADay * 4); //Increment secondsFromBaseDate ready for calculating the next new moon.
        
    }
 */
    

//  ________________________________________________________________________________________________________________________________________________________________
    
    
// Use the following chunk of code to generate alternating new moon and full moon test dates from a fixed base date. Full moons and new moons will be at a fixed time on alternating days.
/*
    
    //Set up a date formatter which we use to create a date from a string.
    NSDateFormatter *aDateFormatter = [[NSDateFormatter alloc] init];
    aDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:[self.sharedUserDataManager.userDataDictionary objectForKey:@"DateFormat"]];
    aDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    aDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *baseTestDateString = @kTestDataDateString; //A string to use to create an NSDate which will be the base date used to calculate the test dates.
    NSDate *baseTestDate = [aDateFormatter dateFromString:baseTestDateString]; //Use the NSDateFormatter to create a base date from a string.
    
    NSNumber *released = [NSNumber numberWithBool:NO]; //Create an NSNumber containing a Bool set to No, for adding to our moon date dictionaries that will hold the test dates.
    NSNumber *newMoonDateType = [NSNumber numberWithInt:kNewMoon]; //Create an NSNumber containing an integer denoting a new moon, for adding to our moon date dictionaries that will hold the test dates.
    NSNumber *fullMoonDateType = [NSNumber numberWithInt:kFullMoon]; ///Create an NSNumber containing an integer denoting a full moon, for adding to our moon date dictionaries that will hold the test dates.
    NSString *moonDateJournalString = @""; //Create an empty journal string for adding to our moon date dictionaries that will hold the test dates.
    
    NSUInteger secondsFromBaseDate = 0; //This integer will be incremented after each test date is created and used to calculate the next date.
    
    for (NSUInteger i = 0; i < 4; i++)
    {
        
        //Create the next new moon test date using the baseTestDate and adding secondsFromBaseDate. Create a new moon dates dictionary and add it to our array of moon dates.
        NSDate *nextNewMoonTestDate = [baseTestDate dateByAddingTimeInterval:secondsFromBaseDate];
        NSDictionary *nextNewMoonTestDateDictionary = [NSDictionary dictionaryWithObjectsAndKeys:nextNewMoonTestDate, @"MoonDate", newMoonDateType, @"Type", moonDateJournalString, @"JournalText", released, @"Released", nil];
        [self.moonDatesArray addObject:nextNewMoonTestDateDictionary];
        
        secondsFromBaseDate = secondsFromBaseDate + (kNumberOfSecondsInADay); //Increment secondsFromBaseDate ready for calculating the next full moon.
        
        //Create the next full moon test date using the baseTestDate and adding secondsFromBaseDate. Create a new moon dates dictionary and add it to our array of moon dates.
        NSDate *nextFullMoonTestDate = [baseTestDate dateByAddingTimeInterval:secondsFromBaseDate];
        NSDictionary *nextFullMoonTestDateDictionary = [NSDictionary dictionaryWithObjectsAndKeys:nextFullMoonTestDate, @"MoonDate", fullMoonDateType, @"Type", moonDateJournalString, @"JournalText", released, @"Released", nil];
        [self.moonDatesArray addObject:nextFullMoonTestDateDictionary];
        
        secondsFromBaseDate = secondsFromBaseDate + (kNumberOfSecondsInADay); //Increment secondsFromBaseDate ready for calculating the next new moon.
        
    }

//  ________________________________________________________________________________________________________________________________________________________________
*/

}


-(void) scheduleNotifications
{
    NSLog (@"scheduleNotifications called");
    
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter]; //Get a reference to the global notification center
    
    //Not sure whether we will end up cancelling all local notifications in the final app. We may end up removing individual notifications after they have occurred.
    [notificationCenter removeAllPendingNotificationRequests];
    
    /* Creat two NSDateFormatters, one will be used to extract the date from an NSDate in the form of a string, while the other will be used to extract the time from the NSDate. */
    NSDateFormatter *dateFormatterForDate = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatterForTime = [[NSDateFormatter alloc] init];
    dateFormatterForDate.locale = [[NSLocale alloc] initWithLocaleIdentifier:[self.sharedUserDataManager.userDataDictionary objectForKey:@"DateFormat"]];
    dateFormatterForTime.locale = dateFormatterForDate.locale;
    
    //Set up the NSDateFormatters so that one formats the NSDate as only a date without a time, and the other formats it as only a time without a date.
    dateFormatterForDate.dateStyle = NSDateFormatterMediumStyle;
    dateFormatterForDate.timeStyle = NSDateFormatterNoStyle;
    dateFormatterForTime.dateStyle = NSDateFormatterNoStyle;
    dateFormatterForTime.timeStyle = NSDateFormatterShortStyle;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; //Create a gregorian calendar which we need to convert our moon dates into date components, which are required to schedule notifications.
    
    NSDate *todaysDate = [NSDate date]; //Create an NSDate using the current date and time for use in a comparison below.
    
    //Iterate through the array of NSDates in the moonDatesDictionary, and schedule a notification for each one.
    NSUInteger i = 0; //An integer we increment with each iteration, and use to create unique notification identifiers.
    
    for (NSMutableDictionary *moonDatesDictionary in self.moonDatesArray)
        
        {
        
        //Compare the moon event date with today's date, and only execute the code to register notifications if the moon event has not already occurred.
        //Registering notifications for moon dates that have already occurred would end up cluttering the user's notificaitons screen with notifications for events that have alread passed.
        
        NSComparisonResult dateComparison = [[moonDatesDictionary objectForKey:@"MoonDate"] compare:todaysDate];
        if (dateComparison != NSOrderedAscending)
        {
            //Create a string to describe the type of moon event, for use in the notification text.
            
            NSString *moonEventTypeText = [[NSString alloc]init];
            switch ([[moonDatesDictionary objectForKey:@"Type"]intValue])
            {
                case kNoMoonEvent:
                    moonEventTypeText = @"No moon event";
                    break;
                    
                case kNewMoon:
                    moonEventTypeText = @"New Moon";
                    break;
                    
                case kFullMoon:
                    moonEventTypeText = @"Full Moon";
                    break;
                    
                default:
                    moonEventTypeText = @"Invalid moon event type";
                    break;
            }
            
            //Create an NSDictionary for the pre-notification and the actual notification, to be stored as the userInfo property of the content object for each notification.
            //These hold the date of the moon event, and a string to describe the type of notification (e.g. pre-notificaiton or actual notification).
            //We can use this data later when the notifications trigger.
            
            NSDictionary *moonDatePreNotificationDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[moonDatesDictionary objectForKey:@"MoonDate"], @"MoonDate", @"PreNotification", @"NotificationType", nil];
            NSDictionary *moonDateActualNotificationDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[moonDatesDictionary objectForKey:@"MoonDate"], @"MoonDate", @"ActualNotification", @"NotificationType", nil];
           
            //Create two notifications for each moon event in the array. One is a pre-notification to notify that a moon event is coming up (timing to be determined by user preferences), and the second is to notify when the actual moon event occurs.
           
            //The first step is to set up the content for each of the notifications.
                        
            //Use the two NSDateFormatters to create a string representing the date of the moon event and another representing the time of the moon event.
            NSString *moonDateString = [dateFormatterForDate stringFromDate:[moonDatesDictionary objectForKey:@"MoonDate"]];
            NSString *moonDateTimeString = [dateFormatterForTime stringFromDate:[moonDatesDictionary objectForKey:@"MoonDate"]];
            
            //Create the UNMutableNotificationContent objects which contain the content for our pre and actual moondate notifications and set title and body text, a notification badge number, the custom dictionaries containing the moon date info and a sound for each notification.
            
            UNMutableNotificationContent *preNotificationContent = [[UNMutableNotificationContent alloc]init];
            UNMutableNotificationContent *actualNotificationContent = [[UNMutableNotificationContent alloc]init];
            
            preNotificationContent.title = [NSString stringWithFormat:@"%@ Notification", moonEventTypeText];
            preNotificationContent.body = [NSString stringWithFormat:@"Advance notification of %@ at %@ on %@", moonEventTypeText, moonDateTimeString, moonDateString];
            preNotificationContent.badge = [NSNumber numberWithInt:1];
            preNotificationContent.userInfo = moonDatePreNotificationDictionary;
            preNotificationContent.sound = [UNNotificationSound defaultSound];
            
            actualNotificationContent.title = [NSString stringWithFormat:@"%@ Notification", moonEventTypeText];
            actualNotificationContent.body = [NSString stringWithFormat:@"%@ at %@", moonEventTypeText, moonDateTimeString];
            actualNotificationContent.badge = [NSNumber numberWithInt:1];
            actualNotificationContent.userInfo = moonDateActualNotificationDictionary;
            actualNotificationContent.sound = [UNNotificationSound defaultSound];
            
            //Set the trigger date of the pre-notification and the actual notification. We also calculate the pre-notification date here, using the notificationOffset.
            
            NSDate *preNotificationDate = [NSDate dateWithTimeInterval:self.notificationOffset sinceDate:[moonDatesDictionary objectForKey:@"MoonDate"]]; //Calculate the pre-notification date.
            
            NSDateComponents *preMoonDateComponents = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:preNotificationDate];//Get the components of the date for the pre-notification of the moon date.
            NSDateComponents *actualMoonDateComponents = [gregorian components: (NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[moonDatesDictionary objectForKey:@"MoonDate"]];//Get the components for the actual moon date notification.
            
            UNCalendarNotificationTrigger *preNotificationTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:preMoonDateComponents repeats:NO];
            UNCalendarNotificationTrigger *actualNotificationTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:actualMoonDateComponents repeats:NO];
            
            //Create notification request objects for the pre and actual moon date notifications.
            
            NSString *preNotification = @"preNotification";
            NSString *actualNotification = @"actualNotification";
            
            NSString *uniquePreIdentifier = [preNotification stringByAppendingString:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
            NSString *uniqueActualIdentifier = [actualNotification stringByAppendingString:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
            
            UNNotificationRequest *preNotificationRequest = [UNNotificationRequest requestWithIdentifier:uniquePreIdentifier content:preNotificationContent trigger:preNotificationTrigger];
            UNNotificationRequest *actualNotificationRequest = [UNNotificationRequest requestWithIdentifier:uniqueActualIdentifier content:actualNotificationContent trigger:actualNotificationTrigger];
            
            //Next we schedule the notifications
            
            [notificationCenter addNotificationRequest:preNotificationRequest withCompletionHandler:^(NSError * _Nullable error)
            {
                if (error != nil)
                {
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
            
            [notificationCenter addNotificationRequest:actualNotificationRequest withCompletionHandler:^(NSError * _Nullable error)
             {
                 if (error != nil)
                 {
                     NSLog(@"%@", error.localizedDescription);
                 }
             }];
            
            i++;
            
        }
   
    }
}

- (void) saveMoonDatesData
{
    //Save the moon dates array in the MoonDatesData.plist file in the documents folder.
    
    NSArray *pathsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectoryPath = [pathsArray objectAtIndex:0];
    NSString *moonDatesPath = [documentDirectoryPath stringByAppendingString:@"/MoonDatesData.plist"];
    
    if ([self.moonDatesArray writeToFile:moonDatesPath atomically:YES])
    {
        NSLog (@"Moon dates array saved.");
    }
    
    else
    {
        NSLog(@"Moon dates array did not save");
    }
}

- (void) applicationWillResignActive: (NSNotification *) notification
{
    //At the moment, all we do is save the moon dates data. It may be necessary to do more work in this method eventually. 
    [self saveMoonDatesData];
}

-(NSString*) description
{
    NSMutableString *description = [[NSMutableString alloc] init];
    
    for (NSDictionary *theDictionary in self.moonDatesArray)
    {
        NSString *theString = [theDictionary description];
        [description appendString:theString];
    }
    
    return description;
}

- (NSDictionary *) moonDateInfo: (NSDate *) date
{
    //This method accepts an NSDate and returns an NSDictionary containing info on whether the date is a moon date, and if so its index in the moon date array and the type of moon date.
    
    BOOL isMoonDate = NO; //This BOOL will state whether the date is a moon date or not.
    NSUInteger i = 0; //If the date is a moon date, we will use this integer to find and return the index of the moon date in the moon dates dictionary.
    NSUInteger type = 0; //If the date is a moon date, we will use this integer to return the type of moon date, i.e. full moon or new moon.
    
    //Next we iterate through the moon dates and compare with the date given to us by the calendar to work out if this is a moon date or not, and find the index and type.
    
    for (NSDictionary *moonDatesDictionary in self.moonDatesArray)
    {
        NSDateComponents *moonDateComponents = [[NSCalendar currentCalendar] components: NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay fromDate: [moonDatesDictionary objectForKey:@"MoonDate"]]; //Get the components of the moon date so that we can create a new version without the time included
        
        NSDate *theMoonDate = [[NSCalendar currentCalendar] dateFromComponents:moonDateComponents]; //Create a working copy of the moon date without the time included
        
        if ([date isEqualToDate:theMoonDate]) //Compare the date passed into the method with the moon date in the array. If it is moon date, we set the values we need to return
        {
            isMoonDate = YES; //Return a BOOL value of YES to show that this is a moon date.
            type = [[moonDatesDictionary objectForKey:@"Type"] integerValue]; //Get the type of moon date from the moon dates dictionary.
            break; // If the date is a moon date, then we break out of the for loop as we have found the moon date we are interested in.
        }
        
     i++; // increment the index integer.
    }
    
    if (isMoonDate == YES) //If we have found a moon date, we package up our values in NSNumber objects and return them in a dictionary with appropriate keys.
    {
        NSNumber *isAMoonDate = [NSNumber numberWithBool:isMoonDate];
        NSNumber *index = [NSNumber numberWithUnsignedInteger:i];
        NSNumber *moonDateType = [NSNumber numberWithUnsignedInteger:type];
        
        NSArray *info = @[isAMoonDate, index, moonDateType];
        NSArray *keys = @[@"isMoonDate", @"index", @"type"];
        NSDictionary *moonDateInfoDictionary = [NSDictionary dictionaryWithObjects:info forKeys:keys];
        
        return moonDateInfoDictionary;
    }
        
    else //If we did not find a moon date, then we package up our values in NSNumber objects and return the dictionary with information appropriate to not having found one.
    {
        NSNumber *isAMoonDate = [NSNumber numberWithBool:isMoonDate];
        NSNumber *index = [NSNumber numberWithUnsignedInteger:NSNotFound];
        NSNumber *moonDateType = [NSNumber numberWithInt:0];
        
        NSArray *info = @[isAMoonDate, index, moonDateType];
        NSArray *keys = @[@"isMoonDate", @"index", @"type"];
        NSDictionary *moonDateInfoDictionary = [NSDictionary dictionaryWithObjects:info forKeys:keys];
        
        return moonDateInfoDictionary;
    }
}


@end
