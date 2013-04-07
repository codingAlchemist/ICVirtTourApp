//
//  VirtTourViewController.m
//  ICVirtCampusTour
//
//  Created by jason debottis on 3/27/13.
//  Copyright (c) 2013 IC. All rights reserved.
//


#import "VirtTourViewController.h"
#import "VirtTourWebViewController.h"

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

@interface VirtTourViewController ()

@end

@implementation VirtTourViewController

-(void)showSettingsView
{
    NSLog(@"Show settings view");
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
-(NSInteger)MetersToMiles:(CGFloat)meters{
    NSInteger miles = meters * 0.000621371192237334;
    return miles;
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.title = @"IC Virtual Tour";
    
    //add extra settings button
    
    //UIBarButtonItem * settingsButton =
    //[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(showSettingsView)];
    
    UIBarButtonItem * settingsButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonSystemItemAction target:self action:@selector(showSettingsView)];
    
    self.navigationController.navigationItem.rightBarButtonItem = settingsButton;
    
    self.navigationItem.rightBarButtonItem = settingsButton;
    
    
    ARView *arView = (ARView *)self.view;
    
    //get building names and locations from database
    _myDBWrapper = [DBWrapper alloc];
    
    NSArray* buildings = [_myDBWrapper getAllBuildingsWithCallback:^
    {
        [self httpError];
        return;
    }];
    
    _buildings = buildings;
    
    /*
     checking contents of dictionary
    for (int i=0; i<buildings.count; i++)
    {
        NSLog(@"%@", [buildings objectAtIndex:i]);
    }
     */
    
    /*
     old code to hard-code the locations
    _buildingNames = [[NSMutableArray alloc]init];
    [_buildingNames addObject:@"Williams"];
    [_buildingNames addObject:@"Health SCiences"];
    [_buildingNames addObject:@"Hill"];
    [_buildingNames addObject:@"DestinyUSA"];
    
    CLLocationCoordinate2D poiCoords[] ={{42.422694, -76.495196},
                                         {42.420075,-76.49806},
                                         {42.420566,-76.497073},
                                         {43.072855,-76.171569}};
    
    int numPois = sizeof(poiCoords) / sizeof(CLLocationCoordinate2D);
    

	NSMutableArray *placesOfInterest = [NSMutableArray arrayWithCapacity:numPois];
	for (int i = 0; i < numPois; i++) {
        ARMarker *marker = [[ARMarker alloc]initWithImage:@"Pointer.PNG" andTitle:[NSString stringWithFormat:@"%@",[_buildingNames objectAtIndex:i]]];
		PlaceOfInterest *poi = [PlaceOfInterest placeOfInterestWithView:marker at:[[CLLocation alloc] initWithLatitude:poiCoords[i].latitude longitude:poiCoords[i].longitude]];
		[placesOfInterest insertObject:poi atIndex:i];
	}
	[arView setPlacesOfInterest:placesOfInterest];
    */
    
    //I am initializing a new loc manager to get current location for distance
    //calculations i am going to add this to the marker class
    //but for now i am going to try this code out here
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    CLLocation *mylocation = [_locationManager location];
    
    
    NSMutableArray* placesOfInterest = [NSMutableArray arrayWithCapacity:buildings.count];
    for (int i=0; i<buildings.count; i++)
    {
        NSDictionary* building = [buildings objectAtIndex:i];
        
        
        double latitude = [[building objectForKey:@"x"] doubleValue];
        double longitude = [[building objectForKey:@"y"] doubleValue];
        
        CLLocation *theBuildingLocation = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
        CGFloat distance = [mylocation distanceFromLocation:theBuildingLocation];
        NSString *theDistance = [[NSString alloc]initWithFormat:@"%i",[self MetersToMiles:distance]];
        
        ARMarker* marker = [[ARMarker alloc] initWithImage:@"Pointer.PNG" andTitle:[building objectForKey:@"name"]showDistance:theDistance];
        
        marker.parent = self;
        marker.rowId = (i+1);

        PlaceOfInterest *poi = [PlaceOfInterest placeOfInterestWithView:marker at:[[CLLocation alloc] initWithLatitude:latitude longitude:longitude]];
		[placesOfInterest insertObject:poi atIndex:i];
        
    }
    
    [arView setPlacesOfInterest:placesOfInterest];
    
    _theMapView = [[MKMapView alloc]init];
    _theMapView.frame = [[UIScreen mainScreen]bounds];
    _theMapView.delegate = self;
    _theMapView.mapType = MKMapTypeStandard;
    _theMapView.showsUserLocation = YES;
    
    //add the campus map overlay
    _mapOverlay = [[MapOverlay alloc]init];
    [_theMapView addOverlay:_mapOverlay];
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
    
    NSString *anID = @"PinViewID";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[_theMapView dequeueReusableAnnotationViewWithIdentifier:anID];
    //Note pin views can be throught of views similar to cells in a tableview
    //and can be modified in the similar manner
    if (pinView == NULL) {
        pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:anID];
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
    }else
        pinView.annotation = annotation;
    
    return pinView;
    
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    if ([view.annotation.title isEqualToString:@"Williams"]) {
        _webView = [[VirtTourWebViewController alloc]initWithNibName:@"VirtTourWebViewController" bundle:nil andURL:@"http://www.ithaca.edu"];
        [self presentViewController:_webView animated:YES completion:^{}];
        //[_navController pushViewController:_webView animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    //Annotation *theAnnotation = [[Annotation alloc]initWithCoordinates:_userLocation.coordinate title:@"ME" subTitle:@"I am here"];
    
    //To add more than one location pin
    //NSArray *myPins = [[NSArray alloc]initWithObjects:theAnnotation, nil];
    //[_theMapView addAnnotation:theAnnotation];
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
