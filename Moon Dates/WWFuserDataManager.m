//
//  WWFuserPrefsManager.m
//  Moon Dates
//
//  Created by Andy Guttridge on 29/05/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#import "WWFuserDataManager.h"

@implementation WWFuserDataManager

+(instancetype)sharedUserPrefsManager
//Create a single instance of WWFuserPrefsManager and return this if it has not been created already. If it has, do not create again and return the single instance already created.
{
    static WWFuserDataManager *userPrefsManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once (&onceToken, ^{userPrefsManager = [[self alloc]init];});
    
    return userPrefsManager;
}

-(instancetype)init
{
    self = [super init];
    
    if (self)
    {
        //Load the user prefs from the plist file called UserPrefs.plist which is stored in the app bundle.
        NSString *path = [[NSBundle mainBundle] pathForResource:@"UserPrefs" ofType:@"plist"];
        self.userPrefsDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    
    return self;
}

@end
