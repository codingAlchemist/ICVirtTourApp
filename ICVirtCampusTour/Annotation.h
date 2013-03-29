//
//  Annotation.h
//  MapViewTest
//
//  Created by jason debottis on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapkit/Mapkit.h>
#import <CoreLocation/CoreLocation.h>

@interface Annotation : NSObject <MKAnnotation>
{
}
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) CLLocation *myLocation;

- (id) initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates 
                     title:(NSString *)paramTitle
                  subTitle:(NSString *)paramSubTitle;

- (id) initWithCurrentLocation:(CLLocation *)paramCoordinates 
                     title:(NSString *)paramTitle
                  subTitle:(NSString *)paramSubTitle;

@end
