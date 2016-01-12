//
//  AppDelegate.m
//  EDEA
//
//  Created by Vincent Villalta on 9/7/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "AFSQLManager.h"
#import <FMDB/FMDB.h>
#import "SWRevealViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize databaseName,databasePath;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeNewsstandContentAvailability| UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    NSLog(@"Begin");
   

    
    self.databaseName = [[NSBundle mainBundle] pathForResource:@"edea" ofType:@"sqlite"];
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    self.databasePath = [documentDir stringByAppendingPathComponent:self.databaseName];
        
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"edea" ofType:@"sqlite"];

    FMDatabase *db = [self openDatabase];
    [db open];
    
    FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM `user`"];
    if ([s next]) {
        int totalCount = [s intForColumnIndex:0];
        NSLog(@"%i", totalCount);
        if (totalCount > 0) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            SWRevealViewController *controller = (SWRevealViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"main"];
            self.window.rootViewController = controller;
        }
    }
    
    [db close];

    return YES;
}

- (FMDatabase *)openDatabase
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *documents_dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *db_path = [documents_dir stringByAppendingPathComponent:[NSString stringWithFormat:@"edea.sqlite"]];
    NSString *template_path = [[NSBundle mainBundle] pathForResource:@"edea" ofType:@"sqlite"];
    
    if (![fm fileExistsAtPath:db_path])
        [fm copyItemAtPath:template_path toPath:db_path error:nil];
    FMDatabase *db = [FMDatabase databaseWithPath:db_path];
    if (![db open])
        NSLog(@"Failed to open database!");
    return db;
}


-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings // available in iOS8
{
    [application registerForRemoteNotifications];
}
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString * token = [NSString stringWithFormat:@"%@", deviceToken];
    //Format token as you need:
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    NSLog(@"%@",token);
    if(![UserDefaults objectForKey:@"token"]){
        [UserDefaults setObject:token forKey:@"token"];
    }
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // Handle your remote RemoteNotification
    UIAlertView * remoteAlert = [[UIAlertView alloc] initWithTitle:@"Notificación recibida" message:[NSString stringWithFormat:@"%@", [userInfo description]] delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
    [remoteAlert show];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Error:%@",error);
    if(![UserDefaults objectForKey:@"token"]){
        [UserDefaults setObject:[[NSUUID UUID] UUIDString] forKey:@"token"];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
