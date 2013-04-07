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
-(float)MetersToMiles:(CGFloat)meters{
    float miles = meters * 0.000621371192237334;
    
    return miles;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set title
    self.title = @"IC Virtual Tour";
    
    UIBarButtonItem * settingsButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(showSettingsView)];
    
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
    
    //init the _nameToID dictionary. Helps to get the row id from the name
    _nameToID = [[NSMutableDictionary alloc] init];
    
    //I am initializing a new loc manager to get current location for distance
    //calculations i am going to add this to the marker class
    //but for now i am going to try this code out here
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
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
    
    NSMutableArray* placesOfInterest = [NSMutableArray arrayWithCapacity:buildings.count];
    for (int i=0; i<buildings.count; i++)
    {
        NSDictionary* building = [buildings objectAtIndex:i];
        
        double latitude = [[building objectForKey:@"x"] doubleValue];
        double longitude = [[building objectForKey:@"y"] doubleValue];
        
        CLLocation *theBuildingLocation = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
        CLLocationCoordinate2D theMapLocation = CLLocationCoordinate2DMake(latitude, longitude);
        
        CGFloat distance = [mylocation distanceFromLocation:theBuildingLocation];
        NSString *theDistance = [[NSString alloc]initWithFormat:@"%.2f",[self MetersToMiles:distance]];
        
        Annotation* mapMarker = [[Annotation alloc]initWithCoordinates:theMapLocation title:[building objectForKey:@"name"] subTitle:[building objectForKey:@"type"]];
        
        //add item to dictionary
        [_nameToID setObject:[building objectForKey:@"id"] forKey:[building objectForKey:@"name"]];
        
        [_theMapView addAnnotation:mapMarker];
        
        ARMarker* marker = [[ARMarker alloc] initWithImage:@"Pointer.PNG" andTitle:[building objectForKey:@"name"]showDistance:theDistance];
        
        marker.parent = self;
        marker.rowId = (i+1);

        PlaceOfInterest *poi = [PlaceOfInterest placeOfInterestWithView:marker at:[[CLLocation alloc] initWithLatitude:latitude longitude:longitude]];
		[placesOfInterest insertObject:poi atIndex:i];
        
        
    }
    
    [arView setPlacesOfInterest:placesOfInterest];
    

    /*
     Sorry Jason, I took out the overlay :)
     */
    //add the campus map overlay
    //_mapOverlay = [[MapOverlay alloc]init];
    //[_theMapView addOverlay:_mapOverlay];
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
        if (rowID_id == NULL)
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
            
            //[rightButton addTarget:self action:@selector(showTable) forControlEvents:UIControlEventTouchUpInside];
            
            pinView.rightCalloutAccessoryView = rightButton;
        }

        
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
