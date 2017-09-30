//
//  WWFcoloursManager.h
//  Moon Journal
//
//  Created by Andy Guttridge on 30/09/2017.
//  Copyright © 2017 Andy Guttridge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WWFcoloursManager : NSObject

+(instancetype)sharedColoursManager; //This method is used to create a singleton instance of this class.

@property UIColor *backgroundColour; //The main background colour for the app
@property UIColor *textColour; //The main text colour for the app
@property UIColor *placeholderDateColour; //A colour for use in the calendar for dates that are not in the current month.
@property UIColor *selectableColour; //The colour for selectable UI items
@property UIColor *nonSelectableColour; //The colour for non-selectable UI items
@property UIColor *highlightColour; //The colour for highlighted items, e.g. moon dates in the calendar that are open for the ritual to be performed
@property UIColor *todayColour; //The colour to highlight the current day in the calendar
@property UIColor *headerColour; //The colour for the months and weekdays in the calendar

@end
