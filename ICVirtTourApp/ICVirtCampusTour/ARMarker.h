
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "VirtTourViewController.h"
@class ARCoordinate;
@class ARDetailedViewController;
@class VirtTourViewController;

@protocol detailViewControllerDelegate <NSObject>

-(void)setCellDataWithName:(NSString*)name andImageName:(NSString*)imageName andText:(NSString*)text;

@end

@protocol detailViewController;

@interface ARMarker : UIView<MKMapViewDelegate> {

}
@property (nonatomic, strong) UIWebView *infoView;
@property (nonatomic, strong) UIButton *expandViewButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *labelButton;
@property (nonatomic, strong) UIImageView *markerImage;
@property (nonatomic, strong) MKUserLocation *userLocation;
@property (nonatomic) BOOL expanded;
@property (nonatomic, strong) VirtTourViewController* parent;
@property (nonatomic) NSInteger rowId;
@property (nonatomic, strong) NSString* name;

- (id)initWithImage:(NSString *)image
           andTitle:(NSString*)title;

- (id)initWithImage:(NSString *)image
           andTitle:(NSString*)title
       showDistance:(NSString*)distance;

- (void)expandInfoView;

@end

