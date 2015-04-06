//
//  ViewController.h
//  CurrentLocation
//
//  Created by vasundhara bhatia  on 26/04/14.
//  Copyright (c) 2014 Vasundhara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>


@interface LocationController : UIViewController< MKMapViewDelegate,CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;

- (IBAction)getDirection:(id)sender;
@property NSString *currentUser;
@property NSString *talkingto;
@property CLLocationCoordinate2D theCoordinate1;
@property CLLocationCoordinate2D theCoordinate2;
@property NSString* address;
@property NSString* city;
@property NSString* state;
@property NSString* zip;
@property CLLocation *currentLocation;
@property CLLocation *friendLocation;
@property NSMutableArray *steps;
@end
