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

+(instancetype)sharedColoursManager;

//The main background colour for the app
@property UIColor *backgroundColour;
//The main text colour for the app
@property UIColor *textColour;
//Colour for use in the calendar for dates that are not in the current month.
@property UIColor *placeholderDateColour;
//The colour for selectable UI items
@property UIColor *selectableColour;
//The colour for non-selectable UI items
@property UIColor *nonSelectableColour;
//The colour for highlighted items, e.g. moon dates in the calendar that are open for the ritual to be performed
@property UIColor *highlightColour;
//The colour to highlight the current day in the calendar
@property UIColor *todayColour;
//The colour for the months and weekdays in the calendar
@property UIColor *headerColour;

@end
