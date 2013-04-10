//
//  VirtTourAppDelegate.h
//  ICVirtCampusTour
//
//  Created by jason debottis on 3/27/13.
//  Copyright (c) 2013 IC. All rights reserved.
//

/**
 @author Jason Debottis, Adeesha Ekanayake
 @brief app delegate class
 */

#import <UIKit/UIKit.h>

@class VirtTourViewController;

@interface VirtTourAppDelegate : UIResponder <UIApplicationDelegate>

/**
 *	@brief	reference to window
 */
@property (strong, nonatomic) UIWindow *window;

/**
 *	@brief	reference to the view controller
 */
@property (strong, nonatomic) VirtTourViewController *viewController;

@end
