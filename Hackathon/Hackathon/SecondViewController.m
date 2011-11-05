//
//  SecondViewController.m
//  Hackathon
//
//  Created by matt on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SecondViewController.h"
#import "WebInterface.h"
#import "AppDelegate.h"

@interface SecondViewController ()
@property (nonatomic, retain) NSArray *poopImages;
@end

@implementation SecondViewController

@synthesize tableView = _tableView;
@synthesize poopImages = _poopImages;

- (void)dealloc
{
    [_poopImages release];
    [_tableView release];
    [super dealloc];
}

#pragma mark - UITableView 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.poopImages)
        return 1;
    return self.poopImages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WebInterface *webInterface = ((AppDelegate*)[UIApplication sharedApplication].delegate).webInterface;
    
    if (!self.poopImages)
        return [self.tableView dequeueReusableCellWithIdentifier:@"loadingcell"];

    PoopImage *pi = [self.poopImages objectAtIndex:indexPath.row];
    NSAssert(pi, @"pi null");
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poopcell"];
    NSAssert(cell, @"cell null");
    
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    if (webInterface.lastLocation) {
        CLLocationDistance d = [pi.location distanceFromLocation:webInterface.lastLocation];
        label.text = [NSString stringWithFormat:@"distance %f rating %d", d, pi.rating];
    } else {
        label.text = [NSString stringWithFormat:@"rating %d", pi.rating];
    }

    if (pi.image) {
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:2];
        imageView.image = pi.image;
    } else {
        [pi requestImageOnCompletion:^{
            [self.tableView reloadData];
        }];
        // TODO filler image
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
	// Do any additional setup after loading the view, typically from a nib.
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
    WebInterface *webInterface = ((AppDelegate*)[UIApplication sharedApplication].delegate).webInterface;
    [webInterface requestImagesWithResponse:^(NSArray *imgs) {
        self.poopImages = imgs;
        [self.tableView reloadData];
    }];
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
