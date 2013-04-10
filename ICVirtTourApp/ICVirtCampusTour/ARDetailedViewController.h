//
//  ARDetailedViewController.h
//  DBExampleProject
//
//  Created by Adeesha on 4/4/13.
//  Copyright (c) 2013 Adeesha Ekanayake. All rights reserved.
//

/**
 @author Jason Debottis, Adeesha Ekanayake
 @brief view controller for the detailed view
 */

#import <UIKit/UIKit.h>
#import "ARMarker.h"

#define IMAGEURL @"http://mordor.adeeshaek.com/app_images"

@interface ARDetailedViewController : UITableViewController<detailViewControllerDelegate>

/**
 *	@brief	ref to the text view
 */
@property IBOutlet UITextView* textView;
/**
 *	@brief	ref to the web view which displays the image
 */
@property IBOutlet UIWebView* webView;
/**
 *	@brief	ref to the ARMarker for the building for which this detailed view was invoked
 */
@property ARMarker* delegate;

/**
 *	@brief	lets parent set the data in this view
 *
 *	@param 	name 	the name of the building
 *	@param 	imageName 	name of the image. Without extension, extension assumed to be PNG
 *	@param 	text 	the text to be shown. Straight fromt the DB
 */
-(void)setCellDataWithName:(NSString *)name andImageName:(NSString *)imageName andText:(NSString *)text;

@end



