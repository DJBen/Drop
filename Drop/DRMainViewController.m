//
//  DRViewController.m
//  Drop
//
//  Created by Sihao Lu on 9/21/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import "DRMainViewController.h"

#import "DRDroplet.h"
#import "DRAimingView.h"
#import "DRDropSettingsViewController.h"

@interface DRMainViewController () <UIGestureRecognizerDelegate, DRAimingDelegate, DRDropSettingsDelegate>

@property (nonatomic) BOOL firstTimeLocationUpdate;

@property (nonatomic, strong) DRAimingView *currentAimingView;

@end

@implementation DRMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _firstTimeLocationUpdate = YES;
    
    UIPanGestureRecognizer *panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRec setDelegate:self];
    [self.mapView addGestureRecognizer:panRec];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"dropSettingsSegue"]) {
        UINavigationController *nav = [segue destinationViewController];
        DRDropSettingsViewController *dropSettingsViewController = [nav viewControllers][0];
        dropSettingsViewController.delegate = self;
        [dropSettingsViewController setOriginalRegion:self.mapView.region];
    }
}

#pragma mark - Gesture Recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Map Delegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    // Center at user location.
    if (self.firstTimeLocationUpdate) {
        MKCoordinateSpan span = MKCoordinateSpanMake(0.025, 0.025);
        MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, span);
        [mapView setRegion:region animated:YES];
        _firstTimeLocationUpdate = NO;
    }
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

- (IBAction)dropButtonTapped:(id)sender {
    
    // Add aiming view
    self.currentAimingView = [[DRAimingView alloc] init];
    self.currentAimingView.delegate = self;
    [self.view addSubview:self.currentAimingView];
    
    // Temporarily disable drop button
    [self.dropButton setEnabled:NO];

}

- (void)didDragMap:(UIPanGestureRecognizer *)gestureRecognizer {
    if (!self.currentAimingView) return;
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.currentAimingView setDropVisible:YES animated:YES];
    } else {
        [self.currentAimingView setDropVisible:NO animated:YES];
    }
}

#pragma mark - Aiming Delegate
- (void)dropFile {
    // Re-enable drop button
    [self.dropButton setEnabled:YES];
    
    // Remove aiming view
    [UIView animateWithDuration:0.3 animations:^{
        self.currentAimingView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.currentAimingView removeFromSuperview];
    }];
    
    [self performSegueWithIdentifier:@"dropSettingsSegue" sender:self];
}

#pragma mark - Drop Settings Delegate
- (void)dropSettingsCancelled:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropSettingsDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
