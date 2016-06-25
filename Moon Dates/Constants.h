//
//  Constants.h
//  Date Notification Testing
//
//  Created by Andy Guttridge on 08/03/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define kDefaultNotificationOffset -259200 //The number of seconds in three 24 hour days
typedef enum {kNoMoonEvent, kFullMoon, kNewMoon} moonType;

//#define kAllowedLetItGoInterval -43200 //The amount of time after a moon event within which the relevant journal entry can be released in seconds. Currently 12 hours.
#define kAllowedLetItGoInterval -60


#endif /* Constants_h */
