

#import "ARMarker.h"
//#import "ARCoordinate.h"

#define BOX_WIDTH 180
#define BOX_HEIGHT 50

@implementation ARMarker
 
- (id)initWithImage:(NSString *)image
       andTitle:(NSString*)title{
    
    _name = title;
    
	CGRect theFrame = CGRectMake(0, 0, BOX_WIDTH, BOX_HEIGHT);	
	if (self = [super initWithFrame:theFrame]) {
                        
        //Create the info button with Title       
        _labelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, BOX_WIDTH, 20.0)];
        _labelButton.backgroundColor = [UIColor colorWithWhite:.3 alpha:.8];
        [_labelButton setTitle:title forState:UIControlStateNormal];
        [_labelButton addTarget:self action:@selector(launchInfoView) forControlEvents:UIControlEventTouchUpInside];
        
        _markerImage = [[UIImageView alloc]initWithFrame:CGRectMake(_labelButton.frame.origin.x + 150, _labelButton.frame.origin.y, 40, 50)];
        _markerImage.image = [UIImage imageNamed:image];
        
        [_labelButton addSubview:_markerImage];

        //Add the marker views
        [self addSubview:_labelButton];
		//[self setBackgroundColor:[UIColor colorWithRed:155 green:155 blue:155 alpha:0.5]];
        [self setBackgroundColor:[UIColor clearColor]];
	}
	

    return self;
}

- (id)initWithImage:(NSString *)image
           andTitle:(NSString*)title
       showDistance:(NSString*)distance{
    
    _name = title;
    
	CGRect theFrame = CGRectMake(0, 0, BOX_WIDTH, BOX_HEIGHT);
	if (self = [super initWithFrame:theFrame]) {
        UILabel *theDistance = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, BOX_WIDTH, 20.0)];
        theDistance.text = [NSString stringWithFormat:@"%@ miles",distance];
        //Create the info button with Title
        _labelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, BOX_WIDTH, 20.0)];
        _labelButton.backgroundColor = [UIColor colorWithWhite:.3 alpha:.8];
        [_labelButton setTitle:title forState:UIControlStateNormal];
        [_labelButton addTarget:self action:@selector(launchInfoView) forControlEvents:UIControlEventTouchUpInside];
        
        _markerImage = [[UIImageView alloc]initWithFrame:CGRectMake(_labelButton.frame.origin.x + 150, _labelButton.frame.origin.y, 40, 50)];
        _markerImage.image = [UIImage imageNamed:image];
        
        [_labelButton addSubview:_markerImage];
        
        //Add the marker views
        [self addSubview:theDistance];
        [self addSubview:_labelButton];
        
        [self setBackgroundColor:[UIColor clearColor]];
	}
	
    
    return self;
}

-(void)launchInfoView
{
    [_parent showDetailedViewWithRowId:_rowId];
}


@end
