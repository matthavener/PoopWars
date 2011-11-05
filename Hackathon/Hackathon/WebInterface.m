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

@interface WebInterface() 
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) UIImage *pendingImage;
@property (nonatomic, copy) WebInterfacePutCb pendingImageResponse;
@property (nonatomic, retain) ASIFormDataRequest *pendingImageRequest;
@end

@implementation WebInterface
@synthesize locationManager = _locationManager, pendingImage = _pendingImage;
@synthesize pendingImageResponse = _pendingImageResponse;
@synthesize pendingImageRequest = _pendingImageRequest;

- (void)dealloc
{
    [_pendingImageRequest release];
    [_pendingImageResponse release];
    [_pendingImage release];
    [_locationManager release];
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

- (void)uploadImage:(UIImage*)image withCallback:(WebInterfacePutCb)response;
{
    self.pendingImage = image;
    self.pendingImageResponse = response;
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [self.locationManager startUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [self.locationManager stopUpdatingLocation];
    if (!self.pendingImage)
        return;
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://lkjasdlfkjasdf.com"]];
    [request setPostValue:[NSString stringWithFormat:@"%f", newLocation.coordinate.latitude] forKey:@"lat"];
    [request setPostValue:[NSString stringWithFormat:@"%f", newLocation.coordinate.longitude] forKey:@"long"];
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

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"failed %@", error);
    self.pendingImage = nil;
}

- (void)requestImagesWithResponse:(WebInterfaceGetCb)response
{
    
}


@end
