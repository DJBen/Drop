//
//  DRDropSettingsViewController.m
//  Drop
//
//  Created by Sihao Lu on 9/21/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import "DRDropSettingsViewController.h"

@interface DRDropSettingsViewController ()

@end

@implementation DRDropSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self.delegate dropSettingsCancelled:self];
}
- (IBAction)dropButtonTapped:(id)sender {
    [self.delegate dropSettingsDone:self];
}

- (void)focusToCoordinate:(CLLocationCoordinate2D)coordinate {
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    [self.mapView setRegion:region animated:YES];
}
@end
