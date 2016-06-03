//
//  WWFuserPrefsManager.h
//  Moon Dates
//
//  Created by Andy Guttridge on 29/05/2016.
//  Copyright © 2016 Andy Guttridge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WWFuserDataManager : NSObject

@property (strong, nonatomic) NSDictionary *userPrefsDictionary;

+(instancetype)sharedUserPrefsManager;

@end
