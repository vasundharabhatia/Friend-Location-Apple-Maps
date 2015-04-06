//
//  LocationController.m
//  CurrentLocation
//
//  Created by vasundhara bhatia  on 26/04/14.
//  Copyright (c) 2014 Vasundhara. All rights reserved.
//

#import "LocationController.h"
#import "MyAnnotation.h"
#import <Parse/Parse.h>
#import "stepsUITableViewController.h"
#pragma mark - 
#pragma mark CLLocationManagerDelegate

@interface LocationController ()
- (IBAction)stepButton:(id)sender;

@end

@implementation LocationController

@synthesize mapView,theCoordinate1,theCoordinate2,currentLocation,friendLocation,steps;


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    stepsUITableViewController *st=[segue destinationViewController];
    st.steps=steps;
    
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    NSLog(@"Could not locate location: %@",error);
}
- (void) receiveTestNotification:(NSNotification *) notification
{
    MyAnnotation *myAnnotation1=[[MyAnnotation alloc] init];
    NSMutableArray* annotations=[[NSMutableArray alloc] init];

    
	myAnnotation1.coordinate=theCoordinate1;
	myAnnotation1.title=@"ME";
    

    
	MyAnnotation *myAnnotation2=[[MyAnnotation alloc] init];
	
	myAnnotation2.coordinate=theCoordinate2;
    NSString *str2=[NSString stringWithFormat:@"%@: %@,%@,%@,%@",_talkingto,_address,_city,_state,_zip];
    myAnnotation2.title=str2;
    
    
	myAnnotation2.address=str2;
    
	
    
	
	[mapView addAnnotation:myAnnotation1];
	
	[mapView addAnnotation:myAnnotation2];
	
	
	[annotations addObject:myAnnotation1];
	
	[annotations addObject:myAnnotation2];
	
    MKMapRect test = MKMapRectNull;
    
	for (MyAnnotation  *annotation in annotations) {
		
        MKMapPoint annotationPoint =MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(test)) {
            test = pointRect;
        } else {
            test = MKMapRectUnion(test, pointRect);
        }
    }
    
    // Position the map so that all overlays and annotations are visible on screen.
    mapView.visibleMapRect = test;
    

    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    
    PFQuery *pq=[PFQuery queryWithClassName:@"userinfo"];
    [pq whereKey:@"name" containsString:_talkingto];
    NSArray *ob2=[pq findObjects];
    PFGeoPoint *geo=[[ob2 objectAtIndex:0] objectForKey:@"location"];
    theCoordinate2.latitude = geo.latitude;
    theCoordinate2.longitude = geo.longitude;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"DBNotification"
                                               object:nil];
    
   
    _locationManager=[[CLLocationManager alloc]init];
    _locationManager.delegate=self;
    mapView.delegate=self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
    [_locationManager setDistanceFilter:30];
    }

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    currentLocation=newLocation;
    //save database
    PFQuery *pf=[PFQuery queryWithClassName:@"userinfo"];
    [pf whereKey:@"name" containsString:_currentUser];
    NSArray *ob=[pf findObjects];
    if([ob count]>=1){
     
           [pf findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
               PFGeoPoint *geo=[PFGeoPoint geoPointWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];

               [objects[0] setObject:geo forKey:@"location"];
               [objects[0]save];
           }];
        
    }else{
    PFObject *ob=[PFObject objectWithClassName:@"userinfo"];
    [ob setObject:_currentUser forKey:@"name"];
    PFGeoPoint *geo=[PFGeoPoint geoPointWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    [ob setObject:geo forKey:@"location"];
    [ob saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
    }];}
    
    //
    
    //getlocation od talking to
    
    PFQuery *pq=[PFQuery queryWithClassName:@"userinfo"];
    [pq whereKey:@"name" containsString:_talkingto];
    NSArray *ob2=[pq findObjects];
    PFGeoPoint *geo=[[ob2 objectAtIndex:0] objectForKey:@"location"];
    theCoordinate2.latitude = geo.latitude;
    theCoordinate2.longitude = geo.longitude;
    CLLocation *cl=[[CLLocation alloc]initWithLatitude:theCoordinate2.latitude longitude:theCoordinate2.longitude];
    friendLocation=cl;
    //
    
    
     theCoordinate1.latitude = newLocation.coordinate.latitude;
     theCoordinate1.longitude = newLocation.coordinate.longitude;


    
    
    ////
    MKPlacemark *place = [[MKPlacemark alloc] initWithCoordinate:theCoordinate1
                                               addressDictionary:nil];
    MKMapItem *mapItem =
    [[MKMapItem alloc]initWithPlacemark:place];
    MKMapItem *mapItem2=[[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:theCoordinate2 addressDictionary:nil]];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    [request setSource:mapItem];
    [request setDestination:mapItem2];
    
    
    
    
    
    [request setTransportType:MKDirectionsTransportTypeAutomobile];
    MKDirections *directions= [[MKDirections alloc]initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (!error) {
            steps=[[NSMutableArray alloc]init];
            for (MKRoute *route in [response routes]) {
                for (MKRouteStep *step in route.steps)
                {
                    [steps addObject:step.instructions];
                }
                [mapView addOverlay:[route polyline] level:MKOverlayLevelAboveRoads];             }
         
        }
        
    }];
    
    
    ////
    
   //get Location Name
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLLocation *thecoordi2 = [[CLLocation alloc] initWithLatitude:theCoordinate2.latitude
                                                         longitude:theCoordinate2.longitude];
    
    [geocoder reverseGeocodeLocation:thecoordi2 completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         
         if (error) {
             NSLog(@"Geocode failed with error: %@", error); return;
         }
         if (placemarks && placemarks.count > 0)
         {
             CLPlacemark *placemark = placemarks[0];
             NSDictionary *addressDictionary =
             placemark.addressDictionary;
             NSString* address = [addressDictionary
                                  objectForKey:
                                  (NSString *)kABPersonAddressStreetKey];
             NSString* city = [addressDictionary objectForKey:(NSString *)kABPersonAddressCityKey];
             NSString *state = [addressDictionary objectForKey:
                                (NSString *)kABPersonAddressStateKey];
             NSString *zip = [addressDictionary objectForKey:
                              (NSString *)kABPersonAddressZIPKey];
             
             


             
             _address=address;
             _city=city;
             _state=state;
             _zip=zip;
             
             [[NSNotificationCenter defaultCenter]postNotificationName:@"DBNotification" object:self];
             
         }
     }];



}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        [renderer setStrokeColor:[UIColor blueColor]];
        [renderer setLineWidth:5.0];
        return renderer;
    }
    return nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
   
    
	// Do any additional setup after loading the view, typically from a nib.

    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





-(void)getDirec{
    
    MKDirectionsRequest *request =
    [[MKDirectionsRequest alloc] init];
    request.source = currentLocation;
    request.destination = friendLocation;
    request.requestsAlternateRoutes = NO; MKDirections *directions =
    [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler: ^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            // Handle error
        } else {
            [self showRoute:response];
        }
    }]; }
    


-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [mapView
         addOverlay:route.polyline
         level:MKOverlayLevelAboveRoads];
        for (MKRouteStep *step in route.steps)
        {
        }
    } }

- (IBAction)stepButton:(id)sender {
    
    
}




@end
