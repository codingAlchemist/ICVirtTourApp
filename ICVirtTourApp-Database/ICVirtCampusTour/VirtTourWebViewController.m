//
//  VirtTourWebViewController.m
//  ICVirtCampusTour
//
//  Created by jason debottis on 4/1/13.
//  Copyright (c) 2013 IC. All rights reserved.
//

#import "VirtTourWebViewController.h"

@interface VirtTourWebViewController ()

@end

@implementation VirtTourWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andURL:(NSString *)url
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _theURL = [[NSURL alloc]initWithString:url];
        _theURLReq = [[NSURLRequest alloc]initWithURL:_theURL];
        
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_campusWebView loadRequest:_theURLReq];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}
@end
