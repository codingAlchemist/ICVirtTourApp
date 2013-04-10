//
//  VirtTourSettingsViewController.h
//  ICVirtCampusTour
//
//  Created by Adeesha on 4/6/13.
//  Copyright (c) 2013 IC. All rights reserved.
//

/**
 @author Jason Debottis, Adeesha Ekanayake
 @brief view controller for the settings view
 */

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "VirtTourViewController.h"

@class VirtTourViewController;

@interface VirtTourSettingsViewController : UITableViewController <settingsViewControllerDelegate>

/**
 *	@brief	ref to the parent detail view controller
 */
@property VirtTourViewController* delegate;
/**
 *	@brief	copy of the parent array where types displayed are mapped to a bool
 */
@property (nonatomic, strong) NSArray* typesArray;

/**
 *	@brief	changes the map type in the parent view
 *
 *	@param 	sender 	ref to sender
 */
-(IBAction)changeMapType:(UISegmentedControl*)sender;

/**
 *	@brief	changes the building types displayed in the parent view
 *
 *	@param 	sender 	ref to sender
 */
-(IBAction)changeBuildingSetting:(id)sender;

@end

