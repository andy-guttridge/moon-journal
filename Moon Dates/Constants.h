//
//  Constants.h
//  Date Notification Testing
//
//  Created by Andy Guttridge on 08/03/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define kNumberOfSecondsInADay 86400

typedef enum {kNoMoonEvent, kFullMoon, kNewMoon} moonType;

//Use a value of -259,200 for NotificationOffset in the UserData.plist file for a default of three days in advance of the moon date for the calendar view to highlight in blue.

#define kAllowedLetItGoInterval -345600 //The amount of time after a moon event within which the relevant journal entry can be released in seconds. Use this for 4 days.

//#define kAllowedLetItGoInterval -28800 //The amount of time after a moon event within which the relevant journal entry can be released in seconds. Use this for 8 hours.
//#define kAllowedLetItGoInterval -43200 //The amount of time after a moon event within which the relevant journal entry can be released in seconds. Use this for 12 hours.
//#define kAllowedLetItGoInterval -172800 //The amount of time after a moon event within which the relevant journal entry can be released in seconds. Use this for 2 days.
//#define kAllowedLetItGoInterval -900 //The amount of time after a moon event within which the relevant journal entry can be released in seconds. Use this for 15 minutes.
//#define kAllowedLetItGoInterval -60 //The amount of time after a moon event within which the relevant journal entry can be released in seconds. Use this for one minute.
//#define kAllowedLetItGoInterval -30 //The amount of time after a moon event within which the relevant journal entry can be released in seconds. Use this for 30 seconds.



#define kpreMoonDateLetItGoInterval 86400 //The amount of time before the moon date within which the relevant journal entry can be released in seconds. Use this for 24 hours.
//#define kpreMoonDateLetItGoInterval 60 //The amount of time before the moon date within which the relevant journal entry can be released in seconds. Use this for 60 seconds for testing.
//#define kpreMoonDateLetItGoInterval 900 //The amount of time before the moon date within which the relevant journal entry can be released in seconds. Use this for 15 minutes for testing.

#define kTestDataDateString "2016-08-20 13:00:00" //A string to use with an NSDateFormatter to generate an NSDate from a string, when generating test data.

#endif /* Constants_h */
