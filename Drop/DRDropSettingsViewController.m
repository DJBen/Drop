//
//  DRDropSettingsViewController.m
//  Drop
//
//  Created by Sihao Lu on 9/21/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import "DRDropSettingsViewController.h"

#import "DRDroplet.h"

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
    [self.mapView setRegion:self.originalRegion];
    [self.mapView addAnnotation:[[DRDroplet alloc] initWithCoordinate:self.originalRegion.center]];
    
    // Delay 1 sec to focus
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [self focusToCurrentCoordinate];
    });
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
    [self.delegate dropSettingsDone:self droplet:nil];
}

- (void)focusToCurrentCoordinate {
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(self.originalRegion.center, span);
    [self.mapView setRegion:region animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"DRDroplet";
    if ([annotation isKindOfClass:[DRDroplet class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.pinColor = MKPinAnnotationColorPurple;
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    
    return nil;
}
- (IBAction)rangeValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.rangeLabel.text = [NSString stringWithFormat:@"Range: %.1f km", slider.value / 1000];
    [self updateRangeVisualRepresentation];
}

- (void)updateRangeVisualRepresentation {
    
}

@end
