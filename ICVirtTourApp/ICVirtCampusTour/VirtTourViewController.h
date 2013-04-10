//
//  VirtTourViewController.h
//  ICVirtCampusTour
//
//  Created by jason debottis on 3/27/13.
//  Copyright (c) 2013 IC. All rights reserved.
//test edit

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

#import "DBWrapper.h"


@class MapOverlay;
@class MapOverlayView;
@class VirtTourWebViewController;

@protocol detailViewControllerDelegate;
@protocol settingsViewControllerDelegate;

@interface VirtTourViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>

-(void)httpError;
-(void)showDetailedViewWithRowId:(NSInteger)rowId;
-(void)showCurrentlySelectedDetailedView;
-(void)showSettingsView;
-(float)MetersToMiles:(CGFloat)meters;

-(void)setMapType:(MKMapType)mapType;

@property (nonatomic, strong) MapOverlay *mapOverlay;
@property (nonatomic, strong) MapOverlayView *mapOverlayView;
@property (nonatomic, strong) VirtTourWebViewController *webView;

@property (nonatomic, strong) MKMapView *theMapView;
@property (nonatomic, strong) MKUserLocation *userLocation;
@property (nonatomic, strong) CMMotionManager *manager;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) DBWrapper* myDBWrapper;
@property (nonatomic, strong) NSArray* buildings;
@property (nonatomic, strong) NSMutableDictionary* nameToID;
@property (nonatomic, strong) NSMutableDictionary* buildingTypesDisplay;

@property (nonatomic, strong) NSMutableArray *buildingNames;
@property (nonatomic) BOOL ARViewDisplayed;
@end

@protocol detailViewControllerDelegate <NSObject>

-(void)setCellDataWithName:(NSString *)name andImageName:(NSString *)imageName andText:(NSString *)text;

@end

@protocol settingsViewControllerDelegate <NSObject>

-(void)setMapType:(MKMapType) mapType;

@end