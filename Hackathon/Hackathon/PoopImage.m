//
//  PoopImage.m
//  Hackathon
//
//  Created by matt on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PoopImage.h"
#import "ASIHTTPRequest.h"

@interface PoopImage()
@property (nonatomic, retain) ASIHTTPRequest *request;
@end

@implementation PoopImage
@synthesize image = _image, location = _location, rating = _rating;
@synthesize request = _request;
@synthesize imageName = _imageName;


- (void)dealloc
{
    [_image release];
    [_location release];
    [_request release];
    [_imageName release];
    [super dealloc];
}

- (void)requestImageOnCompletion:(void (^)(void))cb
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:
                               [NSURL URLWithString:
                                [NSString stringWithFormat:@"http://laksjdflaksdfj.com/%@", self.imageName]]];
    [request setCompletionBlock:^{
        self.image = [UIImage imageWithData:[request responseData]];
        cb();
    }];
    [request startAsynchronous];
}

@end
