//
//  FirstViewController.m
//  Hackathon
//
//  Created by matt on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>


@interface FirstViewController ()
@property (nonatomic, retain) AVCaptureVideoPreviewLayer* previewLayer;
@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, retain) AVCaptureStillImageOutput *imageOutput;
@end

@implementation FirstViewController

@synthesize previewLayer = _previewLayer;
@synthesize session = _session;
@synthesize imageOutput = _imageOutput;

@synthesize takePhotoButton = _takePhotoButton;

- (void)dealloc 
{
    [_imageOutput release];
    [_previewLayer release];
    [_session release];

    [_takePhotoButton dealloc];

    [super dealloc];
}

- (AVCaptureConnection*)videoConnectionForConnections:(NSArray*)connections {
    for (AVCaptureConnection *connection in connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                return connection;
            }
        }
    }
    NSAssert(false, @"Failed");
    return nil;
}

- (AVCaptureConnection*)imageOutputConnection {
    return [self videoConnectionForConnections:self.imageOutput.connections];
}

- (IBAction)takePhoto:(id)sender 
{
    AVCaptureConnection *videoConnection = self.imageOutputConnection;
    
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         if (error) {
             NSLog(@"error %@", error);
             return;
         }
         CFDictionaryRef exifAttachments =
         CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments) {
             //NSLog(@"attach %@", exifAttachments);
         }
         // Continue as appropriate.
        
         UIImage *orig = [UIImage imageWithData:
                            [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer]];
         
         //UIImageView *v = [[UIImageView alloc] initWithImage:orig];
         
         [self.session stopRunning];
         WebInterface *webInterface = ((AppDelegate*)[UIApplication sharedApplication].delegate).webInterface;
         [webInterface uploadImage:orig withCallback:^(NSString *s) {
             NSLog(@"response was %@", s);
             UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Poop dropped!" message:@"Kerplunk-Splash!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [av show];
             [av release];
             [self.session startRunning];
         }];
         
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.session = [[[AVCaptureSession alloc] init] autorelease];
    self.session.sessionPreset = AVCaptureSessionPreset352x288;
    
    AVCaptureDevice *dev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *in = [AVCaptureDeviceInput deviceInputWithDevice:dev error:&error];
    [self.session addInput:in];
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    self.previewLayer.bounds = self.view.layer.bounds;
    self.previewLayer.position = CGPointMake(
                                             CGRectGetMidX(self.previewLayer.bounds), 
                                             CGRectGetMidY(self.previewLayer.bounds));
    [self.view.layer addSublayer:self.previewLayer];
    [self.view bringSubviewToFront:self.takePhotoButton];
    
    self.imageOutput = [[[AVCaptureStillImageOutput alloc] init] autorelease];
    self.imageOutput.outputSettings = 
        [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    
    [self.session addOutput:self.imageOutput];

    self.previewLayer.orientation = AVCaptureVideoOrientationPortrait;
    self.imageOutputConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [self.session startRunning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
