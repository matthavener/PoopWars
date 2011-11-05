//
//  WebInterface.h
//  Hackathon
//
//  Created by matt on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^WebInterfaceGetCb)(NSArray *);
typedef void(^WebInterfacePutCb)(NSString *);

@interface PoopImages 
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) NSInteger rating;
@property (nonatomic, retain) CLLocation *location;
@end

@interface WebInterface : NSObject<CLLocationManagerDelegate>

- (void)uploadImage:(UIImage*)image withCallback:(WebInterfacePutCb)response;
- (void)requestImagesWithResponse:(WebInterfaceGetCb)response;
@end
