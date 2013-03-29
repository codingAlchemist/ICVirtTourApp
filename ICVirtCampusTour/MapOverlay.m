//
//  MapOverlay.m
//  ARViewTestProject
//
//  Created by jason debottis on 3/25/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import "MapOverlay.h"

@implementation MapOverlay
- (CLLocationCoordinate2D)coordinate{
    return CLLocationCoordinate2DMake(42.4227171, -76.4957257);
}

-(MKMapRect)boundingMapRect{
    
    MKMapPoint upperLeft = MKMapPointForCoordinate(CLLocationCoordinate2DMake(42.428842, -76.50527));
    MKMapPoint upperRight = MKMapPointForCoordinate(CLLocationCoordinate2DMake(42.42504, -76.488233));
   // MKMapPoint lowerLeft = MKMapPointForCoordinate(CLLocationCoordinate2DMake(42.411671, -76.490335));
    MKMapPoint lowerRight = MKMapPointForCoordinate(CLLocationCoordinate2DMake(42.411797, -76.495485));
    MKMapRect bounds = MKMapRectMake(upperLeft.x, upperLeft.y, fabs(upperLeft.x - upperRight.x),fabs(upperRight.y - lowerRight.y));
    
    return bounds;
    
}
@end
