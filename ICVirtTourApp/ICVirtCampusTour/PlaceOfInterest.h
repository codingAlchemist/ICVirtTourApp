/**
 @author Jason Debottis, Adeesha Ekanayake
 @brief describes a place of interest
 */

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface PlaceOfInterest : NSObject

@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) CLLocation *location;

+ (PlaceOfInterest *)placeOfInterestWithView:(UIView *)view at:(CLLocation *)location;

@end
