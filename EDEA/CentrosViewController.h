//
//  CentrosViewController.h
//  EDEA
//
//  Created by Vincent Villalta on 9/14/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "Constants.h"
#import <SOAPEngine64/SOAPEngine.h>
#import "AFSQLManager.h"
#import <FMDB/FMDB.h>
#import <MapKit/MapKit.h>
@interface CentrosViewController : UIViewController<NSURLConnectionDataDelegate, NSXMLParserDelegate, SOAPEngineDelegate, MKMapViewDelegate>{
    
}
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end
