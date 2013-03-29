

#import "ARMarker.h"
//#import "ARCoordinate.h"

#define BOX_WIDTH 180
#define BOX_HEIGHT 50

@implementation ARMarker
 
- (id)initWithImage:(NSString *)image
       andTitle:(NSString*)title{
    
	CGRect theFrame = CGRectMake(0, 0, BOX_WIDTH, BOX_HEIGHT);	
	if (self = [super initWithFrame:theFrame]) {
                
        //Create the title lable
		_titleLabel	= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOX_WIDTH, 20.0)];        
		_titleLabel.backgroundColor = [UIColor colorWithWhite:.3 alpha:.8];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.textAlignment = NSTextAlignmentLeft;
		_titleLabel.text = title;
        
        //Create the expand button
        _expandViewButton = [[UIButton alloc]initWithFrame:CGRectMake(_titleLabel.frame.origin.x + 150, _titleLabel.frame.origin.y, 40, 50)];
        [_expandViewButton setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
        [_expandViewButton addTarget:self action:@selector(expandInfoView) forControlEvents:UIControlEventTouchUpInside];
		                
        //Add the marker views
        [self addSubview:_titleLabel];
		[self addSubview:_expandViewButton];
		[self setBackgroundColor:[UIColor colorWithRed:155 green:155 blue:155 alpha:0.5]];
	}
	

    return self;
}

- (void)expandInfoView{
    NSURL *theURL = [[NSURL alloc]initWithString:@"http://www.destinyusa.com"];
    NSURLRequest *theURLReq = [[NSURLRequest alloc]initWithURL:theURL];

    if (!_expanded) {
        _expanded = TRUE;
        
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, BOX_WIDTH+80, BOX_HEIGHT);
            _expandViewButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
        }completion:^(BOOL finished){
            [UIView animateWithDuration:.8 animations:^{
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, BOX_WIDTH+80, BOX_HEIGHT+200);
                
            }completion:^(BOOL finished){
                //Create the web view
                _infoView = [[UIWebView alloc]initWithFrame:CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y+30, self.frame.size.width, self.frame.size.height)];
                //[self addSubview:_infoView];
                [self insertSubview:_infoView belowSubview:_expandViewButton];
                
                _infoView.scalesPageToFit = YES;
                [_infoView loadRequest:theURLReq];
            }];
            
        }];
    }else if (_expanded){
        _expanded = FALSE;
        [_infoView removeFromSuperview];
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, BOX_WIDTH+80, BOX_HEIGHT);
            
        }completion:^(BOOL finished){
            [UIView animateWithDuration:.8 animations:^{
                _expandViewButton.transform = CGAffineTransformMakeRotation(0);
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, BOX_WIDTH, BOX_HEIGHT);
                
                
            }];
            
        }];
        
    }

}


@end
