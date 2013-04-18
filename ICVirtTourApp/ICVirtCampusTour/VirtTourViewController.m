//
//  VirtTourViewController.m
//  ICVirtCampusTour
//
//  Created by jason debottis on 3/27/13.
//  Copyright (c) 2013 IC. All rights reserved.
//

#import "VirtTourViewController.h"

//header for settings view
#import "VirtTourSettingsViewController.h"

//Augmented Reality headers
#import "PlaceOfInterest.h"
#import "ARDetailedViewController.h"
#import "ARView.h"
#import "ARMarker.h"

//Map View headers
#import "Annotation.h"
#import "MapOverlay.h"
#import "MapOverlayView.h"

#define METERS_PER_MILE 1609.344
#define APP_TITLE @"Looking Glass"

@interface VirtTourViewController ()

@end

@implementation VirtTourViewController

-(NSMutableArray*)setupPlacesOfInterestWithBuildings:(NSArray*)buildings andLocation:(CLLocation*)mylocation andMapView:(MKMapView*)theMapView
{
    NSMutableArray* placesOfInterest = [NSMutableArray arrayWithCapacity:buildings.count];
    for (int i=0; i<buildings.count; i++)
    {
        NSDictionary* building = [buildings objectAtIndex:i];
        
        //hack to allow insertion of bool to dict
        NSNumber *boolNumber = [NSNumber numberWithBool:YES];
        
        //get the type
        NSString* buildingType = [building objectForKey:@"type"];
        
        //add the type of building to the dict
        [_buildingTypesDisplay setObject:boolNumber forKey:buildingType];
        
        double latitude = [[building objectForKey:@"x"] doubleValue];
        double longitude = [[building objectForKey:@"y"] doubleValue];
        
        CLLocation *theBuildingLocation = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
        CLLocationCoordinate2D theMapLocation = CLLocationCoordinate2DMake(latitude, longitude);
        
        CGFloat distance = [mylocation distanceFromLocation:theBuildingLocation];
        NSString *theDistance = [[NSString alloc]initWithFormat:@"%.2f",[self MetersToMiles:distance]];
        
        Annotation* mapMarker = [[Annotation alloc]initWithCoordinates:theMapLocation title:[building objectForKey:@"name"] subTitle:buildingType];
        
        //add item to dictionary
        [_nameToID setObject:[building objectForKey:@"id"] forKey:[building objectForKey:@"name"]];
        
        [theMapView addAnnotation:mapMarker];
        
        NSString* imageName;
        
        //check the type of marker then allocate the marker image
        if ([buildingType isEqualToString: @"Academic"])
        {
            imageName = @"Academic_Marker.png";
        }
        else if ([buildingType isEqualToString:@"Residential"])
        {
            imageName = @"Residential_Marker.png";
        }
        else if ([buildingType isEqualToString:@"Parking"])
        {
            imageName = @"ParkingLot_Marker.png";
        }
        else if ([buildingType isEqualToString:@"Dining"])
        {
            imageName = @"DiningHall_Marker.png";
        }
        else if ([buildingType isEqualToString:@"Bus"])
        {
            imageName = @"BusStop_Marker.png";
        }
        else{
            imageName = @"Pointer.png";
        }
        
        ARMarker* marker = [[ARMarker alloc] initWithImage:imageName andTitle:[building objectForKey:@"name"]showDistance:theDistance];
        
        marker.parent = self;
        marker.rowId = (i+1);
        
        PlaceOfInterest *poi = [PlaceOfInterest placeOfInterestWithView:marker at:[[CLLocation alloc] initWithLatitude:latitude longitude:longitude]];
		[placesOfInterest insertObject:poi atIndex:i];
    }
    
    return placesOfInterest;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    UIDevice *device = [UIDevice currentDevice];
    float heading = -1.0 * M_PI *newHeading.magneticHeading /180.0f;
    
    float trueHeading = [self heading:newHeading.trueHeading fromOrientation:device.orientation];
    _compassImage.transform = CGAffineTransformMakeRotation(heading);
}

-(float)heading:(float)heading fromOrientation:(UIDeviceOrientation)orientation{
    float correctedHeading = heading;
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            correctedHeading = heading + 180.0f;
            break;
        case UIDeviceOrientationLandscapeLeft:
            correctedHeading = heading + 90.0f;
            break;
        case UIDeviceOrientationLandscapeRight:
            correctedHeading = heading - 90.0f;
        default:
            break;
    }
    
    while (heading > 360.0f) {
        correctedHeading = heading - 360;
    }
    
    return correctedHeading;
}

-(void)resetData
{
    NSLog(@"Reseting data...");
    
    ARView *arView = (ARView *)self.view;
    
    //reset the ARView and mapview
    [arView setPlacesOfInterest:NULL];
    [_theMapView removeAnnotations:_theMapView.annotations];
    
    //reset nameToID
    _nameToID = NULL;
    
    NSArray* buildings = _buildings;
    CLLocation *mylocation = [_locationManager location];
    _userLocation = _theMapView.userLocation;
    
    NSMutableArray* placesOfInterest = [NSMutableArray arrayWithCapacity:buildings.count];
    for (int i=0; i<buildings.count; i++)
    {
        NSDictionary* building = [buildings objectAtIndex:i];
        
        NSString* buildingType = [building objectForKey:@"type"];
        //check the dict, and draw the marker only if told to
        BOOL drawThisBuilding = [[_buildingTypesDisplay objectForKey:buildingType] boolValue];
        
        double latitude = [[building objectForKey:@"x"] doubleValue];
        double longitude = [[building objectForKey:@"y"] doubleValue];
        
        CLLocation *theBuildingLocation = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
        CLLocationCoordinate2D theMapLocation = CLLocationCoordinate2DMake(latitude, longitude);
        
        CGFloat distance = [mylocation distanceFromLocation:theBuildingLocation];
        NSString *theDistance = [[NSString alloc]initWithFormat:@"%.2f",[self MetersToMiles:distance]];
        
        Annotation* mapMarker = [[Annotation alloc]initWithCoordinates:theMapLocation title:[building objectForKey:@"name"] subTitle:[building objectForKey:@"type"]];
        
        //add item to dictionary
        [_nameToID setObject:[building objectForKey:@"id"] forKey:[building objectForKey:@"name"]];
        
        NSString* imageName;
        
        //check the type of marker then allocate the marker image
        if ([buildingType isEqualToString: @"Academic"])
        {
            imageName = @"Academic_Marker.png";
        }
        else if ([buildingType isEqualToString:@"Residential"])
        {
            imageName = @"Residential_Marker.png";
        }
        else if ([buildingType isEqualToString:@"Parking"])
        {
            imageName = @"ParkingLot_Marker.png";
        }
        else if ([buildingType isEqualToString:@"Dining"])
        {
            imageName = @"DiningHall_Marker.png";
        }
        else if ([buildingType isEqualToString:@"Bus"])
        {
            imageName = @"BusStop_Marker.png";
        }
        else{
            imageName = @"Pointer.png";
        }
        
        ARMarker* marker = [[ARMarker alloc] initWithImage:imageName andTitle:[building objectForKey:@"name"]showDistance:theDistance];
        
        marker.parent = self;
        marker.rowId = (i+1);
        
        PlaceOfInterest *poi = [PlaceOfInterest placeOfInterestWithView:marker at:[[CLLocation alloc] initWithLatitude:latitude longitude:longitude]];
        
        if (drawThisBuilding)
        {
            [placesOfInterest insertObject:poi atIndex:[placesOfInterest count]];
            [_theMapView addAnnotation:mapMarker];
        }
    }
    
    [arView setPlacesOfInterest:placesOfInterest];

}

-(void)setMapType:(MKMapType)mapType
{
    [_theMapView setMapType:mapType];
}

-(void)showSettingsView
{

    //count the number of keys in the dict
    NSArray* dictKeys = [_buildingTypesDisplay allKeys];
    
    UIStoryboard *settingsView = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    VirtTourSettingsViewController* newView = [settingsView instantiateViewControllerWithIdentifier:@"SettingsView"];
    newView.delegate = self;
    newView.typesArray = dictKeys;
    
    [self.navigationController pushViewController:newView animated:YES];
    
}

-(void)showCurrentlySelectedDetailedView:(id) sender
{
    //same as the showDetailedMethod but uses a class parameter
    //to get around the requirement for an action in the
    //addTarget method for UIButton
    
    NSInteger rowId = [sender tag];
    
    //get the data to display the detailed view
    NSDictionary* rowData = [_myDBWrapper getRowWithRowId:rowId andCallback:^
                             {
                                 [self httpError];
                                 return;
                             }];
    
    NSString* title = [rowData valueForKey:@"name"];
    NSString* image = [rowData valueForKey:@"image"];
    
    NSString* text = [[_myDBWrapper getTextWithRowId:rowId andCallback:^
                       {
                           [self httpError];
                           return;
                       }] objectForKey:@"text"];
    
    UIStoryboard *detailedView = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    ARDetailedViewController* newView = [detailedView instantiateViewControllerWithIdentifier:@"DetailedView"];
    
    [self.navigationController pushViewController:newView animated:YES];
    
    [newView setCellDataWithName:title andImageName:image andText:text];
}

-(void)showDetailedViewWithRowId:(NSInteger)rowId
{
    //get the data to display the detailed view
    NSDictionary* rowData = [_myDBWrapper getRowWithRowId:rowId andCallback:^
                             {
                                 [self httpError];
                                 return;
                             }];
    
    NSString* title = [rowData valueForKey:@"name"];
    NSString* image = [rowData valueForKey:@"image"];
    
    NSString* text = [[_myDBWrapper getTextWithRowId:rowId andCallback:^
                      {
                          [self httpError];
                          return;
                      }] objectForKey:@"text"];
    
    UIStoryboard *detailedView = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    ARDetailedViewController* newView = [detailedView instantiateViewControllerWithIdentifier:@"DetailedView"];

    [self.navigationController pushViewController:newView animated:YES];
    
    [newView setCellDataWithName:title andImageName:image andText:text];

}

-(void)httpError
{
    NSLog(@"Error with internet connection...");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                    message:@"Sorry: You must be connected to the internet to use this app."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
//Helper method to convert meters to miles <- aka i got sick of doing myself
-(float)MetersToMiles:(CGFloat)meters{
    float miles = meters * 0.000621371192237334;
    
    return miles;
}

//bit of a, uh, problem - we need to re-order this code
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.title = APP_TITLE;
    
    UIBarButtonItem * settingsButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(showSettingsView)];
    
    self.navigationController.navigationItem.rightBarButtonItem = settingsButton;
    
    self.navigationItem.rightBarButtonItem = settingsButton;
    
    //init buildingtypes
    _buildingTypesDisplay = [[NSMutableDictionary alloc]init];
    
    ARView *arView = (ARView *)self.view;
    
    //Add the compass image to the view
    _compassImage = [[UIImageView alloc]initWithFrame:CGRectMake(20, 50, _compassImage.frame.origin.x + 90, _compassImage.frame.origin.y+90)];
    _compassImage.image = [UIImage imageNamed:@"compass.png"];
    [arView addSubview:_compassImage];
    
    //get building names and locations from database
    _myDBWrapper = [DBWrapper alloc];
    
    NSArray* buildings = [_myDBWrapper getAllBuildingsWithCallback:^
    {
        [self httpError];
        return;
    }];
    
    _buildings = buildings;
    
    //init the _nameToID dictionary. Helps to get the row id from the name
    _nameToID = [[NSMutableDictionary alloc] init];
    
    //I am initializing a new loc manager to get current location for distance
    //calculations i am going to add this to the marker class
    //but for now i am going to try this code out here
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    [_locationManager startUpdatingHeading];
    CLLocation *mylocation = [_locationManager location];
    
    /*
     This code was moved up so that the markers
     could be added to the map and the AR at the same 
     time
     */
    _theMapView = [[MKMapView alloc]init];
    _theMapView.frame = [[UIScreen mainScreen]bounds];
    _theMapView.delegate = self;
    _theMapView.mapType = MKMapTypeStandard;
    _theMapView.showsUserLocation = YES;
    
    //add map annotations for all buildings
    
    NSMutableArray* placesOfInterest = [self setupPlacesOfInterestWithBuildings:buildings andLocation:mylocation andMapView:_theMapView];
    
    [arView setPlacesOfInterest:placesOfInterest];

    _userLocation = _theMapView.userLocation;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_userLocation.location.coordinate, 1*METERS_PER_MILE, 1*METERS_PER_MILE);
    
    [_theMapView setRegion:region animated:YES];

    // Listen for changes in device orientation
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleOrientaionChanges)
                                                name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    
    _mapOverlay = (MapOverlay*)overlay;
    _mapOverlayView = [[MapOverlayView alloc]initWithOverlay:_mapOverlay];
    return _mapOverlayView;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    //get the row id in the database
    id rowID_id = [_nameToID valueForKey:[annotation title]];
    
    NSString *anID = @"PinViewID";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[_theMapView dequeueReusableAnnotationViewWithIdentifier:anID];
    //Note pin views can be throught of views similar to cells in a tableview
    //and can be modified in the similar manner
    if (pinView == NULL) {
        pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:anID];
        
        //set the color and the right button
        if ([[annotation title]isEqualToString:@"Current Location"])
        {
            
            //if you want to keep the same default pin look you can change the color here
            //based on the view.annotation.title property aka "williams" color is purple
            //ect..
            [pinView setPinColor:MKPinAnnotationColorPurple];
            pinView.canShowCallout = YES;
            pinView.animatesDrop = NO;
            
            //Add a detail disclosure button to the callout.
            //this is where i add a button to the pin view to give you an idea
            //of how to do it, add a view or another button in the same manner
            
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
            
            //[rightButton addTarget:self action:@selector(showTable) forControlEvents:UIControlEventTouchUpInside];
            
            pinView.rightCalloutAccessoryView = rightButton;
        }
        
        else
        {
            int rowID = [rowID_id intValue];
            
            //if you want to keep the same default pin look you can change the color here
            //based on the view.annotation.title property aka "williams" color is purple
            //ect..
            [pinView setPinColor:MKPinAnnotationColorGreen];
            pinView.canShowCallout = YES;
            pinView.animatesDrop = NO;
            
            //Add a detail disclosure button to the callout.
            //this is where i add a button to the pin view to give you an idea
            //of how to do it, add a view or another button in the same manner
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
                        
            [rightButton addTarget:self action:@selector(showCurrentlySelectedDetailedView:) forControlEvents:UIControlEventTouchUpInside];
            
            [rightButton setTag:rowID];
            
            pinView.rightCalloutAccessoryView = rightButton;
        }

        
    }else
        pinView.annotation = annotation;
    
    return pinView;
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    _theMapView.centerCoordinate = CLLocationCoordinate2DMake(42.422694, -76.495196);
    [_theMapView setZoomEnabled:YES];
    
}
- (void)handleOrientaionChanges{
    UIDevice *theDevice = [UIDevice currentDevice];
    if (theDevice.orientation == UIDeviceOrientationFaceUp) {
        NSLog(@"Face Up");
        [self.view addSubview:_theMapView];
        _ARViewDisplayed = NO;
    }else {
        [_theMapView removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	ARView *arView = (ARView *)self.view;
    _ARViewDisplayed = YES;
	[arView start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
