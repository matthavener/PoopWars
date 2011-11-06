//
//  PoopImage.h
//  Hackathon
//
//  Created by matt on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PoopImage : NSObject

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, assign) NSInteger rating;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, assign) NSInteger rowId;

- (void)requestImageOnCompletion:(void (^)(void))cb;
@end
