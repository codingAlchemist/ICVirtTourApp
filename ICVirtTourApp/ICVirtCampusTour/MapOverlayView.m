//
//  MapOverlayView.m
//  ARViewTestProject
//
//  Created by jason debottis on 3/26/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import "MapOverlayView.h"

@implementation MapOverlayView

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context{
    UIImage *image = [UIImage imageNamed:@"collegeMap.png"];
    CGImageRef imageRef = image.CGImage;
    
    MKMapRect theMapRect = [self.overlay boundingMapRect];
    
    CGRect theRect = [self rectForMapRect:theMapRect];
    
    CGContextDrawImage(context, theRect, imageRef);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
