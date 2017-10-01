//
//  WWFcoloursManager.m
//  Moon Journal
//
//  Created by Andy Guttridge on 30/09/2017.
//  Copyright © 2017 Andy Guttridge. All rights reserved.
//

#import "WWFcoloursManager.h"

@implementation WWFcoloursManager

+(instancetype)sharedColoursManager

//Create a single instance of WWFmoonDatesManager and return this if it has not been created already. If it has, do not create again and return the single instance already created.
{
    static WWFcoloursManager *coloursManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once (&onceToken, ^{coloursManager = [[self alloc]init];});
    
    return coloursManager;
}

-(instancetype)init
{
    self = [super init];
    
    //Next we create our UIColor objects that can be accessed from other classes
       
    self.backgroundColour = [UIColor colorWithRed:0.14 green:0.14 blue:0.25 alpha:1];
    self.textColour = [UIColor colorWithRed:0.91 green:0.85 blue:1 alpha:1];
    self.selectableColour = [UIColor colorWithRed:0.49 green:0.58 blue:255 alpha:1];
    self.placeholderDateColour = [UIColor colorWithRed:0.78 green:0.65 blue:1 alpha:1];
    self.nonSelectableColour = [UIColor colorWithRed:0.65 green:0.60 blue:0.71 alpha:1];
    self.highlightColour = [UIColor colorWithRed:1 green:0.98 blue:0.55 alpha:1];
    self.todayColour = [UIColor colorWithRed:0.67 green:0.31 blue:0.7 alpha:1];
    self.headerColour = [UIColor colorWithRed:0.72 green:0.55 blue:1 alpha:1];
    
    return  self;
    
}


@end
