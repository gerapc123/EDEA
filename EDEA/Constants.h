//
//  Constants.h
//  Wisetrack
//
//  Created by Vincent Villalta on 4/27/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import <Foundation/Foundation.h>



#pragma mark -
#pragma mark WiseTack Variables
#define kWs @"http://webservice.edeaweb.com.ar/services_prod/edea_service.php"
#define appRegistro @"http://webservice.edeaweb.com.ar/services_prod/edea_service.php/appRegistro"
#define appConsultaCentrosAtencion @"http://webservice.edeaweb.com.ar/services_prod/edea_service.php/appConsultaCentrosAtencion"
#define getNoticiasWeb @"http://webservice.edeaweb.com.ar/services_prod/edea_service.php/getNoticiasWeb"
#define appGeneraReclamoTecnico @"http://webservice.edeaweb.com.ar/services_prod/edea_service.php/appGeneraReclamoTecnico"
#define appConsultaReclamoTecnico @"http://webservice.edeaweb.com.ar/services_prod/edea_service.php/appConsultaReclamoTecnico"
#define getConsumoHistorico @"http://webservice.edeaweb.com.ar/services_prod/edea_service.php/getConsumoHistorico"
#define consultaFacturas @"http://webservice.edeaweb.com.ar/services_prod/edea_service.php/consultaFacturas"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#pragma mark -
#pragma mark iOS Version
#define IOS_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define IOS_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IOS_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define IOS_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)



#pragma mark -
#pragma mark User Variables
#define UserDefaults [NSUserDefaults standardUserDefaults]
#define NotificationCenter NSNotificationCenter defaultCenter]
#define ShowNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO
#define NavBar                              self.navigationController.navigationBar
#define TabBar                              self.tabBarController.tabBar
#define DATE_COMPONENTS                     NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
#define TIME_COMPONENTS                     NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
#define HEXCOLOR(c)                         [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:1.0];
#define HEXWithAlpha(c, a) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:a];



#pragma mark -
#pragma mark Frame Geometry
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
#define CENTER_VERTICALLY(parent,child) floor((parent.frame.size.height - child.frame.size.height) / 2)
#define CENTER_HORIZONTALLY(parent,child) floor((parent.frame.size.width - child.frame.size.width) / 2)
// example: [[UIView alloc] initWithFrame:(CGRect){CENTER_IN_PARENT(parentView,500,500),CGSizeMake(500,500)}];
#define CENTER_IN_PARENT(parent,childWidth,childHeight) CGPointMake(floor((parent.frame.size.width - childWidth) / 2),floor((parent.frame.size.height - childHeight) / 2))
#define CENTER_IN_PARENT_X(parent,childWidth) floor((parent.frame.size.width - childWidth) / 2)
#define CENTER_IN_PARENT_Y(parent,childHeight) floor((parent.frame.size.height - childHeight) / 2)



#pragma mark -
#pragma mark LOG
#define UA_log( s, ... ) NSLog( @"<%@:%d> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,  [NSString stringWithFormat:(s), ##__VA_ARGS__] )


@interface Constants : NSObject
@property (nonatomic, strong) NSMutableArray *array;


- (id)performQuery: (NSString *)query;
- (BOOL) perfomrQueryWithoutReturnType: (NSString *)query;
@end
