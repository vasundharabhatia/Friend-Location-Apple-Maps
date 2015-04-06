//
//  MyAnnotation.h
//  CurrentLocation
//
//  Created by vasundhara bhatia  on 27/04/14.
//  Copyright (c) 2014 Vasundhara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject <MKAnnotation>{
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *address;
    
}
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *address;

@end
