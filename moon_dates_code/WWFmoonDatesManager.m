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

//Create a single instance of WWFmoonDatesManager and return this if it has not been created already. If it has, do not create again and return the single instance already created.
+(instancetype)sharedMoonDatesManager {
    static WWFmoonDatesManager *moonDatesManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{moonDatesManager = [[self alloc]init];});
    return moonDatesManager;
}

-(instancetype)init {
    self = [super init];
    
    //Attempt to load moon dates data from the documents folder. If the plist file doesn't exist, the app is being run for the first time, so copy the file from the app bundle.
    if (self) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *pathsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectoryPath = [pathsArray objectAtIndex:0];
        NSString *moonDatesPath = [documentDirectoryPath stringByAppendingString:@"/MoonDatesData.plist"];
        
        if (![fileManager fileExistsAtPath:moonDatesPath]) {
            NSLog(@"MoonDatesData.plist did not exist in documents folder. Attempting to copy from app bundle");
            NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"MoonDatesData" ofType:@"plist"];
            [fileManager copyItemAtPath:sourcePath toPath:moonDatesPath error:nil]; //We may want to think about retrieving the error data here in future.
        } else {
            NSLog(@"MoonDatesData.plist exists in documents folder.");
        }
        
        if (!(self.moonDatesArray = [NSMutableArray arrayWithContentsOfFile:moonDatesPath])) {
            NSLog(@"Failed to open MoonDatesData.plist in [WWFMoonDatesManager init]");
        }
        
        //Check "WWF Generate Test Data" key in the info plist file to see whether we need to generate some test data for testing notifications.
        NSNumber *generateTestData = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"WWF Generate Test Data"];
        if ([generateTestData boolValue]) {
            [self generateTestData];
        }
        
        //Use sharedUserDataManager to retrieve the time offset for user notification of moon events. Then iterate through array of dictionaries, and create a new NSDate for
        //the notification time for each of them based on the time offset. Insert each of these NSDate objects into the moonDatesArray.
        self.sharedUserDataManager = [WWFuserDataManager sharedUserDataManager];
        self.notificationOffset = [[self.sharedUserDataManager.userDataDictionary objectForKey:@"NotificationInterval"] integerValue];
        if (self.notificationOffset == 0) {
            NSLog(@"Could not retrieve objectForKey NotificationInterval from userDataDictionary");
        }
        
        //Create a mutable copy of the moondates array. Then replace all of the NSDictionaries within the array with mutable copies so we can add the notification times to them.
        NSMutableArray *copyOfMoonDatesArray = [[NSMutableArray alloc]initWithArray:self.moonDatesArray copyItems:YES];
        for (NSDictionary *moonDatesDictionary in self.moonDatesArray) {
            NSMutableDictionary *mutableMoonDatesDictionary = [[NSMutableDictionary alloc] initWithDictionary:moonDatesDictionary copyItems:YES];
            NSUInteger i = [copyOfMoonDatesArray indexOfObject:moonDatesDictionary];
            [copyOfMoonDatesArray replaceObjectAtIndex:i withObject:mutableMoonDatesDictionary];
        }
        //Copy the contents of copyOfMoonDates array back into the proper version of the array.
        self.moonDatesArray = [copyOfMoonDatesArray mutableCopy];
        
        //Create a NSSortDescriptor, add use it to ensure the moonDatesArray is sorted in ascending order of moon dates within the MoonDatesDictionary.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"MoonDate" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [self.moonDatesArray sortUsingDescriptors:sortDescriptors];
        
        //Reschedule notifications every time the app is run. This ensures old notifications are not rescheduled, and that all 64 allowed notifications are in the future.
        [self scheduleNotifications];
           
        //Register to receive an OS notification when the Home button is pressed, and call applicationWillResignActive: method.
        UIApplication *app = [UIApplication sharedApplication];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:app];
    }
    return self;
}

-(void) removeOldNotificationBadge {
    //Flag to record if a moon date is within the range that the ritual could be performed but where it hasn't been yet.
    BOOL foundMoonDateInRange = NO;
    int i = 0;
    
    //Iterate through moon dates to see if the current date is within the range of time before or after each moon date that the journal entry can be released.
    //If it is and the ritual has not yet been performed for that date then take no action. If not in range or if it is but the ritual hasn't been performed,
    //clear any notification badges that are still showing.
    for (NSDictionary *moonDatesDictionary in self.moonDatesArray) {
        NSDate *aMoonDate = [self.moonDatesArray [i] objectForKey:@"MoonDate"];
        
        //The amount of time until or after the moon date.
        NSNumber *intervalUntilDate = [NSNumber numberWithDouble: (double)[aMoonDate timeIntervalSinceNow]];
        
        //Get notification offset and convert to absolute (unsigned).
        //This is because the notification system needs a negative number for the pre-notifications, but we need a positive value here to use the intervalUntilDate
        //method of NSDate to compare the amount of time until the moon event with the notification offset.
        NSNumber *notificationOffset = [NSNumber numberWithInteger: labs (self.notificationOffset)];
        NSNumber *letItGoAllowedInterval = [NSNumber numberWithInt:kAllowedLetItGoInterval];
        
        //Set flag if the moon date has not yet passed but we are within range of the notification of the moon date having been issued and the ritual has not yet been performed.
        if ((([intervalUntilDate compare:notificationOffset] == NSOrderedAscending) && [intervalUntilDate floatValue] >= 0) && ([[self.moonDatesArray [i] objectForKey:@"Released"] boolValue] == NO)) {
            foundMoonDateInRange = YES;
        }
        
        //Set flag if moon date has passed, and we are within range that the ritual can still be performed but hasn't been yet.
        if ((([intervalUntilDate compare:letItGoAllowedInterval] == NSOrderedDescending) && [intervalUntilDate floatValue] <= 0) && ([[self.moonDatesArray [i] objectForKey:@"Released"] boolValue] == NO)) {
            foundMoonDateInRange = YES;
        }
        i++;
    }
    
    //If flag is NO then clear any notification badges, as it is not possible to perform a ritual at this time.
    if (foundMoonDateInRange == NO) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

//This method only runs if WWFGenerateTestData flag is set to YES in Info.plist file. Adds moon dates for testing.
-(void) generateTestData {
    NSDate *todaysDatePlus60seconds = [NSDate dateWithTimeIntervalSinceNow: 60];
    
    for (int i = 0; i < 30; i++) {
        NSDate *newMoonDate = [NSDate dateWithTimeInterval:i*180 sinceDate:todaysDatePlus60seconds];
        NSNumber *newMoonDateType = [NSNumber numberWithInt:kNewMoon];
        NSString *newMoonDateJournalString = @"";
        NSNumber *released = [NSNumber numberWithBool:NO];
        NSDictionary *newMoonDateDictionary = [NSDictionary dictionaryWithObjectsAndKeys:newMoonDate, @"MoonDate", newMoonDateType, @"Type", newMoonDateJournalString, @"JournalText", released, @"Released", nil];
        [self.moonDatesArray addObject:newMoonDateDictionary];
    }
}

-(void) scheduleNotifications {
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    [notificationCenter removeAllPendingNotificationRequests];
    
    // Create two NSDateFormatters, one to extract the date from an NSDate in the form of a string, one to extract the time from the NSDate.
    NSDateFormatter *dateFormatterForDate = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatterForTime = [[NSDateFormatter alloc] init];
    dateFormatterForDate.locale = [[NSLocale alloc] initWithLocaleIdentifier:[self.sharedUserDataManager.userDataDictionary objectForKey:@"DateFormat"]];
    dateFormatterForTime.locale = dateFormatterForDate.locale;
    
    //Set up the NSDateFormatters so that one formats the NSDate as only a date without a time, and the other formats it as only a time without a date.
    dateFormatterForDate.dateStyle = NSDateFormatterMediumStyle;
    dateFormatterForDate.timeStyle = NSDateFormatterNoStyle;
    dateFormatterForTime.dateStyle = NSDateFormatterNoStyle;
    dateFormatterForTime.timeStyle = NSDateFormatterShortStyle;
    
    //Gregorian calendar needed to convert moon dates into date components, used to schedule notifications.
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *todaysDate = [NSDate date];
    
    //Counter used to create unique notification identifiers and count when we reach the maximum allowed 64 registered notifications.
    NSUInteger i = 0;
    
    //Iterate through the array of NSDates in the moonDatesDictionary, and schedule a notification for each one, as long as the moon date is not in the past.
    for (NSMutableDictionary *moonDatesDictionary in self.moonDatesArray) {
        //Only register notifications if the moon event is in the future.
        NSComparisonResult dateComparison = [[moonDatesDictionary objectForKey:@"MoonDate"] compare:todaysDate];
        if (dateComparison != NSOrderedAscending) {
            //String to describe the type of moon event, for use in the notification text.
            NSString *moonEventTypeText = [[NSString alloc]init];
            switch ([[moonDatesDictionary objectForKey:@"Type"]intValue]) {
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
            
            //Create NSDictionary for pre-notification and actual notification, to be stored as the userInfo property of the content object for each notification.
            //These hold the date of the moon event, and a string to describe the type of notification (e.g. pre-notificaiton or actual notification).
            NSDictionary *moonDatePreNotificationDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[moonDatesDictionary objectForKey:@"MoonDate"], @"MoonDate", @"PreNotification", @"NotificationType", nil];
            NSDictionary *moonDateActualNotificationDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[moonDatesDictionary objectForKey:@"MoonDate"], @"MoonDate", @"ActualNotification", @"NotificationType", nil];
           
            //Use NSDateFormatters to create a strings representing the date and time of the moon event.
            NSString *moonDateString = [dateFormatterForDate stringFromDate:[moonDatesDictionary objectForKey:@"MoonDate"]];
            NSString *moonDateTimeString = [dateFormatterForTime stringFromDate:[moonDatesDictionary objectForKey:@"MoonDate"]];
            
            //UNMutableNotificationContent objects contain the content for pre and actual moondate notifications.
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
            
            //Set the trigger date of the pre-notification and the actual notification and calculate pre-notification date.
            NSDate *preNotificationDate = [NSDate dateWithTimeInterval:self.notificationOffset sinceDate:[moonDatesDictionary objectForKey:@"MoonDate"]];
            //Get the components of the date for the pre-notification and actual notification.
            NSDateComponents *preMoonDateComponents = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:preNotificationDate];
            NSDateComponents *actualMoonDateComponents = [gregorian components: (NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[moonDatesDictionary objectForKey:@"MoonDate"]];
            
            UNCalendarNotificationTrigger *preNotificationTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:preMoonDateComponents repeats:NO];
            UNCalendarNotificationTrigger *actualNotificationTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:actualMoonDateComponents repeats:NO];
            
            //Create notification request objects for the pre and actual moon date notifications.
            NSString *preNotification = @"preNotification";
            NSString *actualNotification = @"actualNotification";
            NSString *uniquePreIdentifier = [preNotification stringByAppendingString:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
            NSString *uniqueActualIdentifier = [actualNotification stringByAppendingString:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
            UNNotificationRequest *preNotificationRequest = [UNNotificationRequest requestWithIdentifier:uniquePreIdentifier content:preNotificationContent trigger:preNotificationTrigger];
            UNNotificationRequest *actualNotificationRequest = [UNNotificationRequest requestWithIdentifier:uniqueActualIdentifier content:actualNotificationContent trigger:actualNotificationTrigger];
            
            //Schedule notifications
            [notificationCenter addNotificationRequest:preNotificationRequest withCompletionHandler:^(NSError * _Nullable error) {
                if (error != nil)
                {
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
            [notificationCenter addNotificationRequest:actualNotificationRequest withCompletionHandler:^(NSError * _Nullable error) {
                 if (error != nil)
                 {
                     NSLog(@"%@", error.localizedDescription);
                 }
             }];
            
            i++;
            
            //Exit loop if maximum allowed number of notifications scheduled.
            if (i==31)
            {
                break;
            }
        }
    }
}

- (void) saveMoonDatesData {
    //Save the moon dates array in the MoonDatesData.plist file in the documents folder.
    NSArray *pathsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectoryPath = [pathsArray objectAtIndex:0];
    NSString *moonDatesPath = [documentDirectoryPath stringByAppendingString:@"/MoonDatesData.plist"];
    if ([self.moonDatesArray writeToFile:moonDatesPath atomically:YES]) {
        NSLog (@"Moon dates array saved.");
    } else {
        NSLog(@"Moon dates array did not save");
    }
}

- (void) applicationWillResignActive: (NSNotification *) notification {
    //Save the moon dates data if the app is about to become inactive.
    [self saveMoonDatesData];
}

-(NSString*) description {
    NSMutableString *description = [[NSMutableString alloc] init];
    for (NSDictionary *theDictionary in self.moonDatesArray) {
        NSString *theString = [theDictionary description];
        [description appendString:theString];
    }
    return description;
}

//This method accepts a NSDate and returns a NSDictionary containing info on whether the date is a moon date, and if so its index in the moon date array and the type of moon date.
- (NSDictionary *) moonDateInfo: (NSDate *) date {
    BOOL isMoonDate = NO;
    NSUInteger i = 0;
    NSUInteger type = 0;
    BOOL letItGo = NO;
    BOOL released = NO;
    
    //Create a reference to the user's current calendar to create dates, and convert extract just the date without the time.
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDateComponents *calendarDateComponents = [theCalendar components: NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay fromDate: date];
    NSDate *calendarDate = [theCalendar dateFromComponents:calendarDateComponents];
    
    //Iterate through moon dates and compare with the date passed in the calendar to work out if this is a moon date or not, and find the index and type.
    for (NSDictionary *moonDatesDictionary in self.moonDatesArray) {
        //Create a working copy of the moon date without the time included
        NSDateComponents *moonDateComponents = [theCalendar components: NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay fromDate: [moonDatesDictionary objectForKey:@"MoonDate"]];
        NSDate *theMoonDate = [theCalendar dateFromComponents:moonDateComponents];
        
        //Compare the date passed into the method with the moon date in the array. If it is moon date, we set the values we need to return
        if ([calendarDate isEqualToDate:theMoonDate]) {
            //Return a BOOL value of YES to show that this is a moon date.
            isMoonDate = YES;
            
            //Get the type of moon date from the moon dates dictionary and retrieve whether the ritual has been performed for this journal entry.
            type = [[moonDatesDictionary objectForKey:@"Type"] integerValue];
            released = [[moonDatesDictionary objectForKey:@"Released"] boolValue];
            
            //Get the amount of time since the relevant moon event.
            NSTimeInterval intervalSinceMoonDate = [[moonDatesDictionary objectForKey:@"MoonDate"] timeIntervalSinceNow];
            
            //Find out if the moon date is within the 'letItGo' range of the current date
            if ((intervalSinceMoonDate >= kAllowedLetItGoInterval && intervalSinceMoonDate < 0) || (intervalSinceMoonDate <= kpreMoonDateLetItGoInterval && intervalSinceMoonDate > 0)) {
                letItGo = YES;
            }
            //If the date is a moon date, then we break out of the for loop as we have found the moon date we are interested in.
            break;
        }
     i++;
    }
    
    //If we have found a moon date, package up values in NSNumber objects and return in a dictionary.
    if (isMoonDate == YES) {
        NSNumber *isAMoonDate = [NSNumber numberWithBool:isMoonDate];
        NSNumber *index = [NSNumber numberWithUnsignedInteger:i];
        NSNumber *moonDateType = [NSNumber numberWithUnsignedInteger:type];
        NSNumber *canLetItGo = [NSNumber numberWithBool:letItGo];
        NSNumber *hasBeenReleased = [NSNumber numberWithBool:released];
        NSArray *info = @[isAMoonDate, index, moonDateType, canLetItGo, date, hasBeenReleased];
        //Include the date that was passed in and used to retrieve the info, as other parts of the app need to perform a comparison to see whether the info on this date needs to be refreshed.
        NSArray *keys = @[@"isMoonDate", @"index", @"type", @"canLetItGo", @"date", @"released"];
        NSDictionary *moonDateInfoDictionary = [NSDictionary dictionaryWithObjects:info forKeys:keys];
        return moonDateInfoDictionary;
    } else {
        //If we did not find a moon date, package up values and return the dictionary with information appropriate to not having found one.
        NSNumber *isAMoonDate = [NSNumber numberWithBool:isMoonDate];
        NSNumber *index = [NSNumber numberWithUnsignedInteger:NSNotFound];
        NSNumber *moonDateType = [NSNumber numberWithInt:0];
        NSNumber *canLetItGo = [NSNumber numberWithBool:NO];
        NSNumber *hasBeenReleased = [NSNumber numberWithBool:released];
        NSArray *info = @[isAMoonDate, index, moonDateType, canLetItGo, date, hasBeenReleased];
        NSArray *keys = @[@"isMoonDate", @"index", @"type", @"canLetItGo", @"date", @"released"];
        NSDictionary *moonDateInfoDictionary = [NSDictionary dictionaryWithObjects:info forKeys:keys];
        return moonDateInfoDictionary;
    }
}

//Clear all journal entries in the moon dates dictionary
-(void) clearAllJournalEntries {
    for (NSMutableDictionary *moonDatesDictionary in self.moonDatesArray) {
        NSString *emptyString = @""; //Intialise an empty string.
        [moonDatesDictionary setObject:emptyString forKey:@"JournalText"];//Put the empty string into the journal entry.
    }
}

@end
