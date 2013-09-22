//
//  DRViewController.m
//  Drop
//
//  Created by Sihao Lu on 9/21/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import "DRMainViewController.h"

#import "DRAppDelegate.h"
#import "DRDroplet.h"
#import "DRAimingView.h"
#import "DRDropSettingsViewController.h"

#define DroppableRadius 1000

@interface DRMainViewController () <UIGestureRecognizerDelegate, DRAimingDelegate, DRDropSettingsDelegate>

@property (nonatomic) BOOL firstTimeLocationUpdate;
@property (nonatomic) BOOL dropMode;

@property (nonatomic, strong) MKUserLocation *currentUserLocation;

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
    
    [self logIn];
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

#pragma mark - Facebook Stuff
- (void)logIn {
    [self updateFacebookButton];
    
    DRAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (!appDelegate.session.isOpen) {
        // create a fresh session object
        appDelegate.session = [[FBSession alloc] init];
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
//        if (appDelegate.session.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [appDelegate.session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                // we recurse here, in order to update buttons and labels
                [self updateFacebookButton];
            }];
//        }
    }
}

- (void)updateFacebookButton {
    // get the app delegate, so that we can reference the session property
    DRAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.session.isOpen) {
        // valid account UI is shown whenever the session is open
        [self.facebookLogButton setTitle:@"Log Out"];
    } else {
        // login-needed account UI is shown whenever the session is closed
        [self.facebookLogButton setTitle:@"Log In"];
    }
}

- (IBAction)facebookLogButtonTapped:(id)sender {
    // get the app delegate so that we can access the session property
    DRAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    // this button's job is to flip-flop the session from open to closed
    if (appDelegate.session.isOpen) {
        // if a user logs out explicitly, we delete any cached token information, and next
        // time they run the applicaiton they will be presented with log in UX again; most
        // users will simply close the app or switch away, without logging out; this will
        // cause the implicit cached-token login to occur on next launch of the application
        [appDelegate.session closeAndClearTokenInformation];
        
    } else {
        if (appDelegate.session.state != FBSessionStateCreated) {
            // Create a new, logged out session.
            appDelegate.session = [[FBSession alloc] init];
        }
        
        // if the session isn't open, let's open it now and present the login UX to the user
        [appDelegate.session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            // and here we make sure to update our UX according to the new session state
            [self updateFacebookButton];
        }];
    }
}

#pragma mark - Gesture Recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Map Delegate
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    // Set drop button enabled / disabled
    [self.currentAimingView setDropEnabled:[self isInDroppableRange]];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    _currentUserLocation = userLocation;
    
    // Center at user location.
    if (self.firstTimeLocationUpdate) {
        MKCoordinateSpan span = MKCoordinateSpanMake(0.025, 0.025);
        MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, span);
        [mapView setRegion:region animated:YES];
        _firstTimeLocationUpdate = NO;
    }

    [self refreshOverlay];
}

- (void)refreshOverlay {
    [self.mapView removeOverlays:[self.mapView overlays]];
    if (self.dropMode) {
        MKCircle *rangeIndicator = [MKCircle circleWithCenterCoordinate:self.currentUserLocation.coordinate radius:DroppableRadius];
        [self.mapView addOverlay:rangeIndicator];
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

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *circle = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        if ([self isInDroppableRange]) {
            circle.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.15];
            circle.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        } else {
            circle.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.15];
            circle.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:0.5];
        }
        circle.lineWidth = 1;
        return circle;
    }
    return nil;
}

- (BOOL)isInDroppableRange {
    CLLocation *pinLocation = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    return [pinLocation distanceFromLocation:self.currentUserLocation.location] <= DroppableRadius;
}

- (IBAction)dropButtonTapped:(id)sender {
    if (self.dropMode) {
        self.dropMode = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.currentAimingView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.currentAimingView removeFromSuperview];
        }];
    } else {
        self.dropMode = YES;
        // Add aiming view
        self.currentAimingView = [[DRAimingView alloc] init];
        self.currentAimingView.delegate = self;
        [self.view addSubview:self.currentAimingView];
    }
    [self refreshOverlay];
}

- (void)didDragMap:(UIPanGestureRecognizer *)gestureRecognizer {
    if (!self.currentAimingView) return;
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.currentAimingView setDropVisible:YES animated:YES];
        [self refreshOverlay];
    } else {
        [self.currentAimingView setDropVisible:NO animated:YES];
    }
}

#pragma mark - Aiming Delegate
- (void)dropFile {
    self.dropMode = NO;
    
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
    [self refreshOverlay];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropSettingsDone:(id)sender droplet:(DRDroplet *)droplet {
    [self refreshOverlay];
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
