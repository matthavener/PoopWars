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
@synthesize rowId = _rowId;

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
    NSString *imageUrl = [NSString stringWithFormat:@"http://www.lessucettes.com/hackathon/images/%@.jpg", self.imageName];
    NSLog(@"getting %@", imageUrl);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:
                               [NSURL URLWithString:imageUrl]];
                                
    [request setCompletionBlock:^{
        UIImage *image = [UIImage imageWithData:[request responseData]];
        if (!image)
        {
            NSLog(@"bad url %@", imageUrl);
            return;
        }
        NSLog(@"image %@", image);
        self.image = image;
        cb();
    }];
    [request startAsynchronous];
}

@end
