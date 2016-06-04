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
        //Load the moon dates data from the plist file called MoonDatesData.plist which is stored in the app bundle.
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MoonDatesData" ofType:@"plist"];
        if (!(self.moonDatesArray = [NSMutableArray arrayWithContentsOfFile:path]))
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
        
        self.sharedUserDataManager = [WWFuserDataManager sharedUserDataManager];
        NSInteger NotificationOffset = [[self.sharedUserDataManager.userDataDictionary objectForKey:@"NotificationInterval"] integerValue];
        if (NotificationOffset == 0)
        {
            NSLog(@"Could not retrieve objectForKey NotificationInterval from userDataDictionary");
        }
        
        NSMutableArray *copyOfMoonDatesArray = [[NSMutableArray alloc]initWithArray:self.moonDatesArray copyItems:YES]; //Create a mutable copy of the moonDatesArray, as we cannot make changes to a NSMutableArray while using fast enumeration.
        
        //Next we iterate through moonDatesArray, pulling out each moonDatesDictionary, creating a mutable copy, and replacing the original dictionary in the array with the mutable copy. Then we calculate the notification date and add this to the mutable moonDatesDictionary using "NotificationDate" as the key.
        
        for (NSDictionary *moonDatesDictionary in self.moonDatesArray)
        {
            NSMutableDictionary *mutableMoonDatesDictionary = [[NSMutableDictionary alloc] initWithDictionary:moonDatesDictionary copyItems:YES];
            NSUInteger i = [copyOfMoonDatesArray indexOfObject:moonDatesDictionary];
            [copyOfMoonDatesArray replaceObjectAtIndex:i withObject:mutableMoonDatesDictionary];
            
            NSDate *theMoonEventDate = [mutableMoonDatesDictionary objectForKey:@"MoonDate"];
            NSDate *theNotificationDate = [NSDate dateWithTimeInterval:NotificationOffset sinceDate:theMoonEventDate];
            [copyOfMoonDatesArray [i] setObject:theNotificationDate forKey:@"NotificationDate"];
        }
        self.moonDatesArray = [copyOfMoonDatesArray mutableCopy]; //Copy the contents of copyOfMoonDates array back into the proper version of the array.
    }
    
    //Register to receive notifications
    
    UIUserNotificationType notificationTypes = (UIUserNotificationType) (UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings: notificationSettings];
    
    [self scheduleNotifications];
    
    
    return self;    
}

-(void) generateTestData
//Get todays date plus three days, and use this to generate and add some test dates to some Dictionaries, set the "Type" key to new moon (just for the sake of having some test data), and then add the Dictionaries to our moonDatesArray. The notification dates will be generated in the init method, and if we have the notification interval set to the default three days, then we end up with some very convenient notification dates for testing purposes.
{
    NSDate *todaysDatePlusThreeDays = [NSDate dateWithTimeIntervalSinceNow: 120]; //259200 is the number of seconds in three 24 hour days.
    for (int i = 0; i < 5; i++)
    {
        NSDate *newMoonDate = [NSDate dateWithTimeInterval:i*60 sinceDate:todaysDatePlusThreeDays];
        NSNumber *newMoonDateType = [NSNumber numberWithInt:kNewMoon];
        NSDictionary *newMoonDateDictionary = [NSDictionary dictionaryWithObjectsAndKeys:newMoonDate, @"MoonDate", newMoonDateType, @"Type", nil];
        [self.moonDatesArray addObject:newMoonDateDictionary];
    }
    
}

-(void) scheduleNotifications
{
    //Not sure whether we will end up cancelling all local notifications in the final app. We may end up removing individual notifications after they have occurred.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    NSDateFormatter *dateFormatterForDate = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatterForTime = [[NSDateFormatter alloc] init];
    dateFormatterForDate.locale = [[NSLocale alloc] initWithLocaleIdentifier:[self.sharedUserDataManager.userDataDictionary objectForKey:@"DateFormat"]];
    dateFormatterForTime.locale = dateFormatterForDate.locale;
    
    dateFormatterForDate.dateStyle = NSDateFormatterMediumStyle;
    dateFormatterForDate.timeStyle = NSDateFormatterNoStyle;
    dateFormatterForTime.dateStyle = NSDateFormatterNoStyle;
    dateFormatterForTime.timeStyle = NSDateFormatterShortStyle;
    
    for (NSMutableDictionary *moonDatesDictionary in self.moonDatesArray)
    {
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
        
        UILocalNotification *moonDatePreNotification = [[UILocalNotification alloc] init];
        if (moonDatePreNotification == nil)
            return;
        UILocalNotification *moonDateActualNotification = [[UILocalNotification alloc] init];
        if (moonDatePreNotification == nil)
            return;
        
        NSString *moonDateString = [dateFormatterForDate stringFromDate:[moonDatesDictionary objectForKey:@"MoonDate"]];
        NSString *moonDateTimeString = [dateFormatterForTime stringFromDate:[moonDatesDictionary objectForKey:@"MoonDate"]];
        
        moonDatePreNotification.fireDate = [moonDatesDictionary objectForKey:@"NotificationDate"];
        moonDateActualNotification.fireDate = [moonDatesDictionary objectForKey:@"MoonDate"];
        
        moonDatePreNotification.alertBody = [NSString stringWithFormat:@"Advance notification of %@ at %@ on %@", moonEventTypeText, moonDateTimeString, moonDateString];
        moonDateActualNotification.alertBody = [NSString stringWithFormat:@"It's happened! %@ at %@ on %@", moonEventTypeText, moonDateTimeString, moonDateString];
        
        moonDatePreNotification.alertAction = @"Open Moon Dates app";
        moonDateActualNotification.alertAction = @"Open Moon Dates app";
        
        moonDatePreNotification.alertTitle = @"Upcoming moon event!";
        moonDateActualNotification.alertTitle = @"A moon event has occurred";
        
        moonDatePreNotification.soundName = UILocalNotificationDefaultSoundName;
        moonDateActualNotification.soundName = UILocalNotificationDefaultSoundName;
        
        NSDictionary *moonDatePreNotificationDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[moonDatesDictionary objectForKey:@"MoonDate"], @"MoonDate", @"PreNotification", @"NotificationType", nil];
        NSDictionary *moonDateActualNotificationDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[moonDatesDictionary objectForKey:@"MoonDate"], @"MoonDate", @"ActualNotification", @"NotificationType", nil];
        
        moonDatePreNotification.userInfo = moonDatePreNotificationDictionary;
        moonDateActualNotification.userInfo = moonDateActualNotificationDictionary;
        
        [[UIApplication sharedApplication] scheduleLocalNotification: moonDatePreNotification];
        [[UIApplication sharedApplication] scheduleLocalNotification: moonDateActualNotification];
   
    }
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

@end
