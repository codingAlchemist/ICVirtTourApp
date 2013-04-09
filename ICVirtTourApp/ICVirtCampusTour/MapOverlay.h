//
//  MapOverlay.h
//  ARViewTestProject
//
//  Created by jason debottis on 3/25/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapOverlay : NSObject<MKOverlay>{
    
}

-(MKMapRect)boundingMapRect;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end
