//
//  AppDelegate.h
//  EDEA
//
//  Created by Vincent Villalta on 9/7/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,strong) NSString *databaseName;
@property (nonatomic,strong) NSString *databasePath;

@end

