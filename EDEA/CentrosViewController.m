//
//  CentrosViewController.m
//  EDEA
//
//  Created by Vincent Villalta on 9/14/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import "CentrosViewController.h"
#import "SWRevealViewController.h"

@interface CentrosViewController () <CLLocationManagerDelegate>{
    NSArray *centros;
}
@property(nonatomic, retain) CLLocationManager *locationManager;
@end

@implementation CentrosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    #ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        // Use one or the other, not both. Depending on what you put in info.plist
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    #endif
    [self.locationManager startUpdatingLocation];
    
    self.mapView.showsUserLocation = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMenu:(id)sender {
    SWRevealViewController *revealController = self.revealViewController;
    [revealController revealToggleAnimated:true];
}

-(void)viewDidAppear:(BOOL)animated{
    [SVProgressHUD show];
    SOAPEngine *soap = [[SOAPEngine alloc] init];
    soap.licenseKey = @"kuSpmvqJEogw93H4ryqyhV9v7e9QZbN2qCI1dBCqd2kPUZhRTcezoeNyY9rw82+fCZHGJnM+UGgfDSmz3lkxdg==";
    soap.userAgent = @"SOAPEngine";
    soap.delegate = self;
    soap.authorizationMethod = SOAP_AUTH_BASIC;
    soap.username = @"app";
    soap.password = @"apptest";
    [soap requestURL:kWs soapAction:appConsultaCentrosAtencion];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = self.locationManager.location.coordinate.latitude;
    region.center.longitude = self.locationManager.location.coordinate.longitude;
    region.span.longitudeDelta = 0.005f;
    region.span.longitudeDelta = 0.005f;
    [self.mapView setRegion:region animated:YES];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}
- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
}
- (NSString *)deviceLat {
    return [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.latitude];
}
- (NSString *)deviceLon {
    return [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.longitude];
}
- (NSString *)deviceAlt {
    return [NSString stringWithFormat:@"%f", self.locationManager.location.altitude];
}

- (void)soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML {
    NSDictionary *result = [soapEngine dictionaryValue];
    NSLog(@"%@", result);
    [SVProgressHUD dismiss];
    centros = [[result objectForKey:@"TConsultaCentroAtencionList"] objectForKey:@"TCentro_Atencion"];
    NSLog(@"%lu", (unsigned long)centros.count);
    [self populateMapView];
    
}

-(void)populateMapView{
    for (int i = 0; i < centros.count; i++) {
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = CLLocationCoordinate2DMake([[[centros objectAtIndex:i] objectForKey:@"coord_x"] floatValue], [[[centros objectAtIndex:i] objectForKey:@"coord_y"] floatValue]);
        point.title = [[centros objectAtIndex:i] objectForKey:@"ciudad"];
        point.subtitle = [NSString stringWithFormat:@"%@ %@", [[centros objectAtIndex:i] objectForKey:@"direccion"], [[centros objectAtIndex:i] objectForKey:@"horario"]];
        [self.mapView addAnnotation:point];
    }
    
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in self.mapView.annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.2, 0.2);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    [self.mapView setVisibleMapRect:zoomRect animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
