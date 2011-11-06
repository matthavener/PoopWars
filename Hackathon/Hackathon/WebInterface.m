//
//  WebInterface.m
//  Hackathon
//
//  Created by matt on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WebInterface.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"


@interface WebInterface() 
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) UIImage *pendingImage;
@property (nonatomic, copy) WebInterfacePutCb pendingImageResponse;
@property (nonatomic, retain) ASIFormDataRequest *pendingImageRequest;
@property (nonatomic, retain) ASIHTTPRequest *getImagesRequest;
@end

@implementation WebInterface
@synthesize locationManager = _locationManager, pendingImage = _pendingImage;
@synthesize pendingImageResponse = _pendingImageResponse;
@synthesize pendingImageRequest = _pendingImageRequest;
@synthesize getImagesRequest = _getImagesRequest;
@synthesize lastLocation = _lastLocation;

- (void)dealloc
{
    [_pendingImageRequest release];
    [_pendingImageResponse release];
    [_pendingImage release];
    [_locationManager release];
    [_getImagesRequest release];
    [_lastLocation release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    }
    return self;
}

- (void)uploadPendingImage
{
    if (!self.pendingImage)
        return;
    
    if (!self.lastLocation)
    {
        [self requestLocation];
        return;
    }
    NSLog(@"uploading pending %@", [NSString stringWithFormat:@"%f", self.lastLocation.coordinate.latitude]);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:
                                   [NSURL URLWithString:@"http://www.lessucettes.com/hackathon/save_images.cgi"]];
    [request setPostValue:[NSString stringWithFormat:@"%f", self.lastLocation.coordinate.latitude] forKey:@"lat"];
    [request setPostValue:[NSString stringWithFormat:@"%f", self.lastLocation.coordinate.longitude] forKey:@"long"];
    [request setPostValue:@"0" forKey:@"userid"];
    [request setData:UIImageJPEGRepresentation(self.pendingImage, 1.0) 
        withFileName:@"poop.jpg" andContentType:@"image/jpeg" forKey:@"image"];
    [request setCompletionBlock:^{
        self.pendingImageResponse(@"Success");
        self.pendingImage = nil;
    }];
    [request setFailedBlock:^{
        self.pendingImageResponse(@"Failed");
        self.pendingImage = nil;
    }];
    [request startAsynchronous];
    self.pendingImageRequest = request;
}

- (void)requestLocation
{
    NSLog(@"request location");
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [self.locationManager startUpdatingLocation];
}

- (void)uploadImage:(UIImage*)image withCallback:(WebInterfacePutCb)response;
{
    NSLog(@"trying upload");
    self.pendingImage = image;
    self.pendingImageResponse = response;

    [self uploadPendingImage];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"got location");
    self.lastLocation = newLocation;
    [self.locationManager stopUpdatingLocation];
    [self uploadPendingImage];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"failed %@", error);
    self.pendingImage = nil;
}

- (void)requestImagesWithResponse:(WebInterfaceGetCb)response
{
#if 0
    PoopImage *a = [[[PoopImage alloc] init] autorelease];
    a.location = [[[CLLocation alloc] initWithLatitude:0.0 longitude:0.0] autorelease];
    PoopImage *b = [[[PoopImage alloc] init] autorelease];
    b.location = [[[CLLocation alloc] initWithLatitude:0.0 longitude:0.0] autorelease];
    PoopImage *c = [[[PoopImage alloc] init] autorelease];
    c.location = [[[CLLocation alloc] initWithLatitude:0.0 longitude:0.0] autorelease];
    
    NSArray *test = [NSArray arrayWithObjects:a, b, c, nil];
    response(test);
#else
    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:
                               [NSURL URLWithString:@"http://www.lessucettes.com/hackathon/get_images.cgi"]];
    [request setCompletionBlock:^{
        NSError *error = nil;
        NSDictionary *res = [[CJSONDeserializer deserializer] 
                        deserializeAsDictionary:[request responseData] 
                        error:&error];
        NSArray *list = [res valueForKey:@"images"];
        //NSLog(@"res %@ error %@ list %@", res, error, list);
        NSMutableArray *entries = [NSMutableArray array];
        for (NSDictionary *entry in list)
        {
            PoopImage *pi = [[PoopImage alloc] init];
            pi.imageName = [entry valueForKey:@"image"];
            NSNumber *lat = [entry valueForKey:@"lat"];
            NSNumber *log = [entry valueForKey:@"lon"];
            pi.location = [[[CLLocation alloc] 
                            initWithLatitude:[lat doubleValue] longitude:[log doubleValue]] 
                           autorelease];
            NSNumber *rating = [entry valueForKey:@"rating"];
            pi.rating = [rating integerValue];
            NSNumber *rowId = [entry valueForKey:@"rowid"];
            pi.rowId = [rowId integerValue];
            [entries addObject:pi];
            [pi release];
        }
        [entries sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            PoopImage *a = obj1;
            PoopImage *b = obj2;
            return a.rowId < b.rowId ? NSOrderedDescending : NSOrderedAscending;
        }];
        response([NSArray arrayWithArray:entries]);
    }];
    [request setFailedBlock:^{
        NSLog(@"failed to download");
    }];
    [request startAsynchronous];
#endif
}

- (void)voteImage:(PoopImage*)image with:(NSString*)upOrDown
{
    NSLog(@"vote for %@ vote %@", image, upOrDown);
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:
                                   [NSURL URLWithString:@"http://www.lessucettes.com/hackathon/rate_images.cgi"]];
    [request setPostValue:image.imageName forKey:@"imageid"];
    [request setPostValue:upOrDown forKey:@"rating"];
    [request setCompletionBlock:^{
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Vote Received" message:@"p-diddy would be proud" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [av release];
    }];
    [request setFailedBlock:^{
        NSLog(@"failed");
    }];
    [request startAsynchronous];
}

@end
