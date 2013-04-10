//
//  VirtTourSettingsViewController.h
//  ICVirtCampusTour
//
//  Created by Adeesha on 4/6/13.
//  Copyright (c) 2013 IC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "VirtTourViewController.h"

@class VirtTourViewController;

@interface VirtTourSettingsViewController : UITableViewController <settingsViewControllerDelegate>

@property VirtTourViewController* delegate;
@property (nonatomic, strong) NSArray* typesArray;

-(IBAction)changeMapType:(UISegmentedControl*)sender;

@end

