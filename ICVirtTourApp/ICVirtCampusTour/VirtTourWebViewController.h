//
//  VirtTourWebViewController.h
//  ICVirtCampusTour
//
//  Created by jason debottis on 4/1/13.
//  Copyright (c) 2013 IC. All rights reserved.
//

/**
 @author Jason Debottis, Adeesha Ekanayake
 @brief view controller for the web view
 */

/*
 Jason, what does this view do?
 is it redundant?
 */

#import <UIKit/UIKit.h>

@interface VirtTourWebViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIWebView *campusWebView;
@property (strong, nonatomic) IBOutlet UIToolbar *backBarButton;
@property (strong,nonatomic) NSURL *theURL;
@property (strong,nonatomic) NSURLRequest *theURLReq;
- (IBAction)goBack:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andURL:(NSString *)url;
@end
