
#import "PlaceOfInterest.h"
//#import "ARMarker.h"

@implementation PlaceOfInterest

@synthesize view;
@synthesize location;

- (id)init
{
    self = [super init];
    if (self) {
			view = nil;
			location = nil;
    }    
    return self;
}


+ (PlaceOfInterest *)placeOfInterestWithView:(UIView *)view at:(CLLocation *)location
{
    //add Marker Details here
	PlaceOfInterest *poi = [[PlaceOfInterest alloc] init];
   // ARMarker *theMarker = [[ARMarker alloc]initWithImage:@"Pointer.PNG" andTitle:nil];

	poi.view = view;
	poi.location = location;
	return poi;
}

@end
