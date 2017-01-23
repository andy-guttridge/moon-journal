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

//#define kAllowedLetItGoInterval -28800 //The amount of time after a moon event within which the relevant journal entry can be released in seconds. Use this for 8 hours.
//#define kAllowedLetItGoInterval -43200 //The amount of time after a moon event within which the relevant journal entry can be released in seconds. Use this for 12 hours.
//#define kAllowedLetItGoInterval -172800 //The amount of time after a moon event within which the relevant journal entry can be released in seconds. Use this for 2 days.
#define kAllowedLetItGoInterval -60 //The amount of time after a moon event within which the relevant journal entry can be released in seconds. Use this for one minute.

#define kTestDataDateString "2016-08-20 13:00:00" //A string to use with an NSDateFormatter to generate an NSDate from a string, when generating test data.

#endif /* Constants_h */
