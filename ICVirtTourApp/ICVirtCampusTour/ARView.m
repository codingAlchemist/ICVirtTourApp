
#import "ARView.h"
#import "PlaceOfInterest.h"

#import <AVFoundation/AVFoundation.h>

#pragma mark -
#pragma mark Math utilities declaration

#define DEGREES_TO_RADIANS (M_PI/180.0)

typedef float mat4f_t[16];	// 4x4 matrix in column major order
typedef float vec4f_t[4];	// 4D vector

// Creates a projection matrix using the given y-axis field-of-view, aspect ratio, and near and far clipping planes
void createProjectionMatrix(mat4f_t mout, float fovy, float aspect, float zNear, float zFar);

// Matrix-vector and matrix-matricx multiplication routines
void multiplyMatrixAndVector(vec4f_t vout, const mat4f_t m, const vec4f_t v);
void multiplyMatrixAndMatrix(mat4f_t c, const mat4f_t a, const mat4f_t b);

// Initialize mout to be an affine transform corresponding to the same rotation specified by m
void transformFromCMRotationMatrix(vec4f_t mout, const CMRotationMatrix *m);

#pragma mark -
#pragma mark Geodetic utilities declaration

#define WGS84_A	(6378137.0)				// WGS 84 semi-major axis constant in meters
#define WGS84_E (8.1819190842622e-2)	// WGS 84 eccentricity

// Converts latitude, longitude to ECEF coordinate system
void latLonToEcef(double lat, double lon, double alt, double *x, double *y, double *z);

// Coverts ECEF to ENU coordinates centered at given lat, lon
void ecefToEnu(double lat, double lon, double x, double y, double z, double xr, double yr, double zr, double *e, double *n, double *u);

#pragma mark -
#pragma mark ARView extension

@interface ARView () {
	UIView *captureView;
	AVCaptureSession *captureSession;
	AVCaptureVideoPreviewLayer *captureLayer;
	
	CADisplayLink *displayLink;
	CMMotionManager *motionManager;
	CLLocationManager *locationManager;
	CLLocation *location;
	NSArray *placesOfInterest;
	mat4f_t projectionTransform;
	mat4f_t cameraTransform;	
	vec4f_t *placesOfInterestCoordinates;
}

- (void)initialize;

- (void)startCameraPreview;
- (void)stopCameraPreview;

- (void)startLocation;
- (void)stopLocation;

- (void)startDeviceMotion;
- (void)stopDeviceMotion;

- (void)startDisplayLink;
- (void)stopDisplayLink;

- (void)updatePlacesOfInterestCoordinates;

- (void)onDisplayLink:(id)sender;
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;

@end


#pragma mark -
#pragma mark ARView implementation

@implementation ARView

@dynamic placesOfInterest;


- (void)start
{
	[self startCameraPreview];
	[self startLocation];
	[self startDeviceMotion];
	[self startDisplayLink];

}

- (void)stop
{
	[self stopCameraPreview];
	[self stopLocation];
	[self stopDeviceMotion];
	[self stopDisplayLink];
}



- (void)setPlacesOfInterest:(NSArray *)pois
{
    
	for (PlaceOfInterest *poi in [placesOfInterest objectEnumerator]) {
		[poi.view removeFromSuperview];
	}	
	placesOfInterest = pois;
	if (location != nil) {
		[self updatePlacesOfInterestCoordinates];
	}
}

- (NSArray *)placesOfInterest
{
	return placesOfInterest;
}

- (void)initialize
{
	captureView = [[UIView alloc] initWithFrame:self.bounds];
	captureView.bounds = self.bounds;
	[self addSubview:captureView];
	[self sendSubviewToBack:captureView];
	
	// Initialize projection matrix	
	createProjectionMatrix(projectionTransform, 60.0f*DEGREES_TO_RADIANS, self.bounds.size.width*1.0f / self.bounds.size.height, 0.25f, 1000.0f);
    
}

- (void)startCameraPreview
{	
	AVCaptureDevice* camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if (camera == nil) {
		return;
	}
	
	captureSession = [[AVCaptureSession alloc] init];
	AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:nil];
	[captureSession addInput:newVideoInput];
	
	captureLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
	captureLayer.frame = captureView.bounds;
	[captureLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[captureView.layer addSublayer:captureLayer];
	
	// Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[captureSession startRunning];
	});
}
- (void)stopCameraPreview
{	
	[captureSession stopRunning];
	[captureLayer removeFromSuperlayer];
	captureSession = nil;
	captureLayer = nil;
}

- (void)startLocation
{
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.distanceFilter = 100.0;
	[locationManager startUpdatingLocation];
}

- (void)stopLocation
{
	[locationManager stopUpdatingLocation];
	locationManager = nil;
}

- (void)startDeviceMotion
{	
	motionManager = [[CMMotionManager alloc] init];
	
	// Tell CoreMotion to show the compass calibration HUD when required to provide true north-referenced attitude
	motionManager.showsDeviceMovementDisplay = YES;

	
	motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
	
	// New in iOS 5.0: Attitude that is referenced to true north
	[motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical];
}

- (void)stopDeviceMotion
{
	[motionManager stopDeviceMotionUpdates];
	motionManager = nil;
}

- (void)startDisplayLink
{
	displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];
	[displayLink setFrameInterval:1];
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopDisplayLink
{
	[displayLink invalidate];
	displayLink = nil;
}

- (void)updatePlacesOfInterestCoordinates
{
	
	if (placesOfInterestCoordinates != NULL) {
		free(placesOfInterestCoordinates);
	}
	placesOfInterestCoordinates = (vec4f_t *)malloc(sizeof(vec4f_t)*placesOfInterest.count);
			
	int i = 0;
	
	double myX, myY, myZ;
	latLonToEcef(location.coordinate.latitude, location.coordinate.longitude, 0.0, &myX, &myY, &myZ);

	// Array of NSData instances, each of which contains a struct with the distance to a POI and the
	// POI's index into placesOfInterest
	// Will be used to ensure proper Z-ordering of UIViews
	typedef struct {
		float distance;
		int index;
	} DistanceAndIndex;
	NSMutableArray *orderedDistances = [NSMutableArray arrayWithCapacity:placesOfInterest.count];

	// Compute the world coordinates of each place-of-interest
	for (PlaceOfInterest *poi in [[self placesOfInterest] objectEnumerator]) {
		double poiX, poiY, poiZ, e, n, u;
		
		latLonToEcef(poi.location.coordinate.latitude, poi.location.coordinate.longitude, 0.0, &poiX, &poiY, &poiZ);
		ecefToEnu(location.coordinate.latitude, location.coordinate.longitude, myX, myY, myZ, poiX, poiY, poiZ, &e, &n, &u);
		
		placesOfInterestCoordinates[i][0] = (float)n;
		placesOfInterestCoordinates[i][1]= -(float)e;
		placesOfInterestCoordinates[i][2] = 0.0f;
		placesOfInterestCoordinates[i][3] = 1.0f;
		
		// Add struct containing distance and index to orderedDistances
		DistanceAndIndex distanceAndIndex;
		distanceAndIndex.distance = sqrtf(n*n + e*e);
		distanceAndIndex.index = i;
		[orderedDistances insertObject:[NSData dataWithBytes:&distanceAndIndex length:sizeof(distanceAndIndex)] atIndex:i++];
	}
	
	// Sort orderedDistances in ascending order based on distance from the user
	[orderedDistances sortUsingComparator:(NSComparator)^(NSData *a, NSData *b) {
		const DistanceAndIndex *aData = (const DistanceAndIndex *)a.bytes;
		const DistanceAndIndex *bData = (const DistanceAndIndex *)b.bytes;
		if (aData->distance < bData->distance) {
			return NSOrderedAscending;
		} else if (aData->distance > bData->distance) {
			return NSOrderedDescending;
		} else {
			return NSOrderedSame;
		}
	}];
	
	// Add subviews in descending Z-order so they overlap properly
	for (NSData *d in [orderedDistances reverseObjectEnumerator]) {
		const DistanceAndIndex *distanceAndIndex = (const DistanceAndIndex *)d.bytes;
		PlaceOfInterest *poi = (PlaceOfInterest *)[placesOfInterest objectAtIndex:distanceAndIndex->index];		
		[self addSubview:poi.view];
        
        UIImageView *borderView = [[UIImageView alloc]initWithFrame:self.bounds];
        borderView.backgroundColor = [UIColor clearColor];
        borderView.image = [UIImage imageNamed:@"ICAppBorder.png"];
        [self addSubview:borderView];

	}	
}

- (void)onDisplayLink:(id)sender
{
	CMDeviceMotion *d = motionManager.deviceMotion;
	if (d != nil) {
		CMRotationMatrix r = d.attitude.rotationMatrix;
		transformFromCMRotationMatrix(cameraTransform, &r);
		[self setNeedsDisplay];
	}
}

- (void)drawRect:(CGRect)rect
{
	if (placesOfInterestCoordinates == nil) {
		return;
	}
	
	mat4f_t projectionCameraTransform;
	multiplyMatrixAndMatrix(projectionCameraTransform, projectionTransform, cameraTransform);
	
	int i = 0;
    
    //init the datastruc here
    _placesArray = malloc(120 * sizeof(int*));
    
    for (int i=0; i <120; i++)
    {
        *(_placesArray+i) = malloc(MAXSIZE * sizeof(int));
    }
    
    
	for (PlaceOfInterest *poi in [placesOfInterest objectEnumerator]) {
		vec4f_t v;
		multiplyMatrixAndVector(v, projectionCameraTransform, placesOfInterestCoordinates[i]);
		
		float x = (v[0] / v[3] + 1.0f) * 0.5f;
		float y = (v[1] / v[3] + 1.0f) * 0.5f;
        
        //check for overlap here, and enter into the datastructure

        
		if (v[2] < 0.0f) {
    
			//poi.view.center = CGPointMake(x*self.bounds.size.width, self.bounds.size.height-y*self.bounds.size.height);
            
            //calculate x and y
            float xPos = self.bounds.size.width * (x-0.5);
            float yPos = (1-y) * self.bounds.size.width;
            
            //check xpos for overlap
            int placesArrayIndex = (int) ((xPos/500) + 60);
            
            if (placesArrayIndex > 0 && placesArrayIndex < 120)
            {
                //check if the array index is null
                if (_placesArray[placesArrayIndex][0] == 0)
                {
                    //if null, add and move on
                    _placesArray[placesArrayIndex][0] = 1;
                    
                }
                else
                {
                    //if not null, add to the 2nd arr
                    //find the next empty slot in the arr
                    int j=0;
                    while (_placesArray[placesArrayIndex][j] != 0)
                        j++;
                
                    //add to the jth element
                    _placesArray[placesArrayIndex][j] = 1;
                    
                    int index = j+1;
                    
                    //if odd index - yPos += (i * self.bounds.size.height)
                    if(index % 2)
                    {
                        yPos += (index * 10);
                    }
                    
                    //find if even index - yPos -= (i * self.bounds.size.height)
                    else
                    {
                        yPos -= (index * 10);
                    }
                    
                }
                
                
            }
            
            poi.view.center = CGPointMake(xPos, yPos);
            
			poi.view.hidden = NO;
            
            //NSLog(@"pai: %d", placesArrayIndex);
            
		} else {
			poi.view.hidden = YES;
		}
        
		i++;
	}
    
    //nullify the hashtable
    _placesArray = NULL;

}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	location = newLocation;
	if (placesOfInterest != nil) {
		[self updatePlacesOfInterestCoordinates];
	}	
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self initialize];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initialize];
	}
	return self;
}

@end

#pragma mark -
#pragma mark Math utilities definition

// Creates a projection matrix using the given y-axis field-of-view, aspect ratio, and near and far clipping planes
void createProjectionMatrix(mat4f_t mout, float fovy, float aspect, float zNear, float zFar)
{
	float f = 1.0f / tanf(fovy/2.0f);
	
	mout[0] = f / aspect;
	mout[1] = 0.0f;
	mout[2] = 0.0f;
	mout[3] = 0.0f;
	
	mout[4] = 0.0f;
	mout[5] = f;
	mout[6] = 0.0f;
	mout[7] = 0.0f;
	
	mout[8] = 0.0f;
	mout[9] = 0.0f;
	mout[10] = (zFar+zNear) / (zNear-zFar);
	mout[11] = -1.0f;
	
	mout[12] = 0.0f;
	mout[13] = 0.0f;
	mout[14] = 2 * zFar * zNear /  (zNear-zFar);
	mout[15] = 0.0f;
}

// Matrix-vector and matrix-matricx multiplication routines
void multiplyMatrixAndVector(vec4f_t vout, const mat4f_t m, const vec4f_t v)
{
	vout[0] = m[0]*v[0] + m[4]*v[1] + m[8]*v[2] + m[12]*v[3];
	vout[1] = m[1]*v[0] + m[5]*v[1] + m[9]*v[2] + m[13]*v[3];
	vout[2] = m[2]*v[0] + m[6]*v[1] + m[10]*v[2] + m[14]*v[3];
	vout[3] = m[3]*v[0] + m[7]*v[1] + m[11]*v[2] + m[15]*v[3];
}

void multiplyMatrixAndMatrix(mat4f_t c, const mat4f_t a, const mat4f_t b)
{
	uint8_t col, row, i;
	memset(c, 0, 16*sizeof(float));
	
	for (col = 0; col < 4; col++) {
		for (row = 0; row < 4; row++) {
			for (i = 0; i < 4; i++) {
				c[col*4+row] += a[i*4+row]*b[col*4+i];
			}
		}
	}
}

// Initialize mout to be an affine transform corresponding to the same rotation specified by m
void transformFromCMRotationMatrix(vec4f_t mout, const CMRotationMatrix *m)
{
	mout[0] = (float)m->m11;
	mout[1] = (float)m->m21;
	mout[2] = (float)m->m31;
	mout[3] = 0.0f;
	
	mout[4] = (float)m->m12;
	mout[5] = (float)m->m22;
	mout[6] = (float)m->m32;
	mout[7] = 0.0f;
	
	mout[8] = (float)m->m13;
	mout[9] = (float)m->m23;
	mout[10] = (float)m->m33;
	mout[11] = 0.0f;
	
	mout[12] = 0.0f;
	mout[13] = 0.0f;
	mout[14] = 0.0f;
	mout[15] = 1.0f;
}

#pragma mark -
#pragma mark Geodetic utilities definition

// References to ECEF and ECEF to ENU conversion may be found on the web.

// Converts latitude, longitude to ECEF coordinate system
void latLonToEcef(double lat, double lon, double alt, double *x, double *y, double *z)
{   
	double clat = cos(lat * DEGREES_TO_RADIANS);
	double slat = sin(lat * DEGREES_TO_RADIANS);
	double clon = cos(lon * DEGREES_TO_RADIANS);
	double slon = sin(lon * DEGREES_TO_RADIANS);
	
	double N = WGS84_A / sqrt(1.0 - WGS84_E * WGS84_E * slat * slat);
	
	*x = (N + alt) * clat * clon;
	*y = (N + alt) * clat * slon;
	*z = (N * (1.0 - WGS84_E * WGS84_E) + alt) * slat;
}

// Coverts ECEF to ENU coordinates centered at given lat, lon
void ecefToEnu(double lat, double lon, double x, double y, double z, double xr, double yr, double zr, double *e, double *n, double *u)
{
	double clat = cos(lat * DEGREES_TO_RADIANS);
	double slat = sin(lat * DEGREES_TO_RADIANS);
	double clon = cos(lon * DEGREES_TO_RADIANS);
	double slon = sin(lon * DEGREES_TO_RADIANS);
	double dx = x - xr;
	double dy = y - yr;
	double dz = z - zr;
	
	*e = -slon*dx  + clon*dy;
	*n = -slat*clon*dx - slat*slon*dy + clat*dz;
	*u = clat*clon*dx + clat*slon*dy + slat*dz;
}
