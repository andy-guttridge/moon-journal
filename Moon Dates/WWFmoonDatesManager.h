//
//  WWFmoonDatesManager.h
//  Moon Dates
//
//  Created by Andy Guttridge on 29/05/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Constants.h"
#import "WWFuserDataManager.h"

@interface WWFmoonDatesManager : NSObject

@property (strong, nonatomic, readonly) NSMutableArray *moonDatesArray;

+(instancetype)sharedMoonDatesManager;

-(void) generateTestData;
-(void) scheduleNotifications;
-(void) saveMoonDatesData;

@end
