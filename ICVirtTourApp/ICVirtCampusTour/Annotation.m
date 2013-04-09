//
//  Annotation.m
//  MapViewTest
//
//  Created by jason debottis on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation


- (id) initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates 
                     title:(NSString *)paramTitle
                  subTitle:(NSString *)paramSubTitle
{ 
        self = [super init];
    
        if (self != nil)
        {
            _coordinate = paramCoordinates; 
            _title = paramTitle;
            _subtitle = paramSubTitle;
        }
    
    return(self); 
}
- (id)initWithCurrentLocation:(CLLocation *)paramCoordinates title:(NSString *)paramTitle subTitle:(NSString *)paramSubTitle
{ 
    self = [super init];
    
    if (self != nil)
    {
        _myLocation = paramCoordinates; 
        _title = paramTitle;
        _subtitle = paramSubTitle;
    }
    
    return(self); 
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
