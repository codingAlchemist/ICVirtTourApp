//
//  ARDetailedViewController.h
//  DBExampleProject
//
//  Created by Adeesha on 4/4/13.
//  Copyright (c) 2013 Adeesha Ekanayake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARMarker.h"

#define IMAGEURL @"http://mordor.adeeshaek.com/app_images"

@interface ARDetailedViewController : UITableViewController<detailViewControllerDelegate>

@property IBOutlet UITextView* textView;
@property IBOutlet UIWebView* webView;
@property ARMarker* delegate;

-(void)setCellDataWithName:(NSString *)name andImageName:(NSString *)imageName andText:(NSString *)text;

@end



