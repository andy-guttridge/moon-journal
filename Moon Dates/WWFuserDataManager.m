//
//  WWFuserPrefsManager.m
//  Moon Dates
//
//  Created by Andy Guttridge on 29/05/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#import "WWFuserDataManager.h"

@implementation WWFuserDataManager

//Create a single instance of WWFuserPrefsManager and return this if it has not been created already. If it has, do not create again and return the single instance already created.
+(instancetype)sharedUserDataManager {
    static WWFuserDataManager *userPrefsManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once (&onceToken, ^{userPrefsManager = [[self alloc]init];});
    
    return userPrefsManager;
}

-(instancetype)init {
    self = [super init];
    
    if (self) {
        //Load the user prefs from plist file in the app bundle.
        NSString *path = [[NSBundle mainBundle] pathForResource:@"UserData" ofType:@"plist"];
        if (!(self.userDataDictionary = [NSDictionary dictionaryWithContentsOfFile:path]))
        {
            NSLog(@"Failed to open UserData.plist in [WWFuserDatesManager init]");
        }
    }
    return self;
}

@end
