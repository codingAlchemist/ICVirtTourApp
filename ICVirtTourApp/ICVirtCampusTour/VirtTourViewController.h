//
//  VirtTourViewController.h
//  ICVirtCampusTour
//
//  Created by jason debottis on 3/27/13.
//  Copyright (c) 2013 IC. All rights reserved.
//

/**
 @author Jason Debottis, Adeesha Ekanayake
 @brief view controller for the root view
 */

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

#import "DBWrapper.h"


@class MapOverlay;
@class MapOverlayView;
@class VirtTourWebViewController;

/**
 *	@brief	this view controller can set the contents of the detail view
 */
@protocol detailViewControllerDelegate;
/**
 *	@brief	lets this view controller set contents of the settings view and vice versa
 */
@protocol settingsViewControllerDelegate;

@interface VirtTourViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>

/**
 *	@brief	called when DBWrapper throws a connection error
 */
-(void)httpError;
/**
 *	@brief	shows a detailed view
 *
 *	@param 	rowId 	id of the row in the database
 */
-(void)showDetailedViewWithRowId:(NSInteger)rowId;
/**
 *	@brief	shows currently sellected detailed view
 */
-(void)showCurrentlySelectedDetailedView;
/**
 *	@brief	shows settings view
 */
-(void)showSettingsView;
/**
 *	@brief	meters to miles
 *
 *	@param 	meters 	value in meters
 *
 *	@return	value in miles
 */
-(float)MetersToMiles:(CGFloat)meters;

/**
 *	@brief	lets settings view change map type
 *
 *	@param 	mapType 	type of the map (Hybrid, standard, satmap)
 */
-(void)setMapType:(MKMapType)mapType;
/**
 *	@brief	lets settings view reset the data displayed 
 *  @detailed the settings view changes the contents of the buildingTypes, which affects the types of buildings shown. This method resets the data displayed in the ARView and the mapView so that only the new types selected will be displayed.
 
    @attention this messes up the pin colors: fix 
 */
-(void)resetData;

@property (nonatomic, strong) MapOverlay *mapOverlay;
@property (nonatomic, strong) MapOverlayView *mapOverlayView;
@property (nonatomic, strong) VirtTourWebViewController *webView;

@property (nonatomic, strong) MKMapView *theMapView;
@property (nonatomic, strong) MKUserLocation *userLocation;
@property (nonatomic, strong) CMMotionManager *manager;
@property (nonatomic, strong) CLLocationManager *locationManager;

/**
 *	@brief	instance of DBWrapper class. Allows convenient connection to database
 */
@property (nonatomic, strong) DBWrapper* myDBWrapper;
/**
 *	@brief	each line corresponds to a building in the database
 */
@property (nonatomic, strong) NSArray* buildings;
/**
 *	@brief	lets you convert a name id to a row id. Useful since dicts don't work backwards
 */
@property (nonatomic, strong) NSMutableDictionary* nameToID;
/**
 *	@brief	a dict with the types of buildings mapped to a boolean
 *  @detailed the types are all from the database, and the booleans are wrapped in NSNumbers to allow them to be inserted in the dict
 */
@property (nonatomic, strong) NSMutableDictionary* buildingTypesDisplay;

/**
 *	@brief	an array of the building names. Deprecate?
 */
@property (nonatomic, strong) NSMutableArray *buildingNames;
@property (nonatomic) BOOL ARViewDisplayed;
@end

@protocol detailViewControllerDelegate <NSObject>

-(void)setCellDataWithName:(NSString *)name andImageName:(NSString *)imageName andText:(NSString *)text;

@end

@protocol settingsViewControllerDelegate <NSObject>

-(void)setMapType:(MKMapType) mapType;
-(void)resetData;

@end
