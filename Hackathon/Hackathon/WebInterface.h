//
//  WebInterface.h
//  Hackathon
//
//  Created by matt on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "PoopImage.h"

typedef void(^WebInterfaceGetCb)(NSArray *);
typedef void(^WebInterfacePutCb)(NSString *);

@interface WebInterface : NSObject<CLLocationManagerDelegate>

- (void)uploadImage:(UIImage*)image withCallback:(WebInterfacePutCb)response;
- (void)requestImagesWithResponse:(WebInterfaceGetCb)response;
- (void)requestLocation;
- (void)voteImage:(PoopImage*)image with:(NSString*)upOrDown;

@property (nonatomic, retain) CLLocation *lastLocation;

@end
