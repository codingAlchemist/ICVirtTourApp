
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

#define MAXSIZE 100 //must be greater than number of all the markers

@interface ARView : UIView  <CLLocationManagerDelegate> {
}

@property (nonatomic, retain) NSArray *placesOfInterest;
/**
 *	@brief	used to figure out when labels overlap. Is a simple 2d array for speed
 */
@property int** placesArray;

- (void)start;
- (void)stop;
@end
