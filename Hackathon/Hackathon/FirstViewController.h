//
//  FirstViewController.h
//  Hackathon
//
//  Created by matt on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController

- (IBAction)takePhoto:(id)sender;

@property (nonatomic, retain) IBOutlet UIButton *takePhotoButton;

@end
