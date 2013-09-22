//
//  DRDropSettingsViewController.m
//  Drop
//
//  Created by Sihao Lu on 9/21/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import "DRDropSettingsViewController.h"

#import "DRDroplet.h"
#import <DBChooser/DBChooser.h>
#import "DRNetworkManager.h"

// Please ignore these two macros
#define FioraBladeWaltz 1023
#define KarthusRequiem 3389

@interface DRDropSettingsViewController () <UIActionSheetDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) DRDroplet *droplet;

@property (nonatomic) NSTimeInterval duration;

@property (nonatomic) CLLocationDistance range;

@property (nonatomic, strong) NSString *dropletDescription;

@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) NSDictionary *durationOptions;

@property (nonatomic, strong) UIImage *chosenImage;

@property (nonatomic, strong) NSString *filePath;

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
    
    self.durationOptions = @{@"1 day" : @(3600 * 24), @"2 days" : @(2 * 3600 * 24), @"12 hours" : @(3600 * 12), @"6 hours" : @(3600 * 6), @"1 week" : @(3600 * 24 * 7)};
    [self updateDuration:@"1 day"];
    [self updateRange:500];
    [self updatePassword:@""];
    [self updateDropletDescription:@"My Droplet"];
    
    [self.mapView setRegion:self.originalRegion];
    self.droplet = [[DRDroplet alloc] initWithCoordinate:self.originalRegion.center];
    [self.mapView addAnnotation:self.droplet];
    
    // Delay 1 sec to focus screen
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [self focusToCurrentCoordinate];
        [self updateRange:500];
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
    DRDroplet *droplet = [[DRDroplet alloc] initWithCoordinate:self.mapView.centerCoordinate range:self.range duration:self.duration password:self.password];
    droplet.dropletDescription = self.dropletDescription;
    droplet.image = self.chosenImage;
    droplet.filePath = self.filePath;
    
    [self.delegate dropSettingsDone:self droplet:droplet];
}


#pragma mark - Map View Delegate
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
        circle.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.15];
        circle.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        circle.lineWidth = 1;
        return circle;
    }
    return nil;
}

#pragma mark - View Events
- (IBAction)rangeValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.rangeLabel.text = [NSString stringWithFormat:@"Range: %.0f m", slider.value];
}

- (IBAction)durationButtonTapped:(id)sender {
    UIActionSheet *durationSheet = [[UIActionSheet alloc] initWithTitle:@"Choose File Duration" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"1 week", @"2 days", @"1 day", @"12 hours", @"6 hours", nil];
    durationSheet.tag = FioraBladeWaltz;
    [durationSheet showInView:self.view];
}

- (IBAction)passwordButtonTapped:(id)sender {
    UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:@"Set Password" message:@"Please enter a password:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    [passwordAlert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    [passwordAlert show];
}


- (IBAction)describeDroplet:(id)sender {
    UIAlertView *descriptionAlert = [[UIAlertView alloc] initWithTitle:@"Edit Title" message:@"Please describe your droplet:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    descriptionAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    descriptionAlert.tag = 1;
    [descriptionAlert show];
}

- (IBAction)chooseContentButtonTapped:(id)sender {
    UIActionSheet *contentSheet = [[UIActionSheet alloc] initWithTitle:@"Drop something..." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"From Dropbox", @"From Camera", @"From Gallery", @"A Message", nil];
    contentSheet.tag = KarthusRequiem;
    [contentSheet showInView:self.view];
}

- (IBAction)rangeEditEnded:(id)sender {
    UISlider *slider = (UISlider *)sender;
    [self updateRange:slider.value];
}

#pragma mark - Helper Methods
- (void)updateDuration:(NSString *)durationName {
    [self.durationButton setTitle:durationName forState:UIControlStateNormal];
    self.duration = [self.durationOptions[durationName] doubleValue];
}

- (void)updatePassword:(NSString *)password {
    if (password.length > 0) {
        self.password = password;
        [self.passwordButton setTitle:@"Password Set" forState:UIControlStateNormal];
    } else {
        self.password = nil;
        [self.passwordButton setTitle:@"No Password" forState:UIControlStateNormal];
    }
}

- (void)updateRange:(CGFloat)range {
    self.range = range;
    [self.mapView removeOverlays:[self.mapView overlays]];
    MKCircle *rangeIndicator = [MKCircle circleWithCenterCoordinate:self.droplet.coordinate radius:range];
    [self.mapView addOverlay:rangeIndicator];
    
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.droplet.coordinate, range * 2.2, range * 2.2) animated:YES];
}

- (void)updateDropletDescription:(NSString *)description {
    self.dropletDescription = description;
    [self.dropletDescriptionButton setTitle:description forState:UIControlStateNormal];
}

- (void)focusToCurrentCoordinate {
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(self.originalRegion.center, span);
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == FioraBladeWaltz) {
        switch (buttonIndex) {
            case 0:
                [self updateDuration:@"1 week"];
                break;
            case 1:
                [self updateDuration:@"2 days"];
                break;
            case 2:
                [self updateDuration:@"1 day"];
                break;
            case 3:
                [self updateDuration:@"12 hours"];
                break;
            case 4:
                [self updateDuration:@"6 hours"];
                break;
            default:
                break;
        }
    } else if (actionSheet.tag == KarthusRequiem) {
        switch (buttonIndex) {
            case 0: {
                // Dropbox
                [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypeDirect fromViewController:self completion:^(NSArray *results) {
                    if ([results count]) {
                        self.chooseContentButton = NO;
                        DBChooserResult *result = results[0];
                        [DRNetworkManager downloadFileFromDropbox:result withThumbnailImageView:self.contentThumbnail withProgress:^(CGFloat progress) {
                            NSLog(@"%f", progress);
                            if (progress != 1.0f) {
                                self.contentDetailLabel.text = [NSString stringWithFormat:@"Downloading... (%.1f%%)", progress * 100];
                            }
                            
                        } completion:^(NSString *fileName, NSString *filePath) {
                            NSLog(@"%@", filePath);
                            self.filePath = filePath;
                            self.contentDetailLabel.text = fileName;
                            self.chooseContentButton.enabled = YES;
                        }];
                    }
                }];
                break;
            }
            case 1: {
                // Photo
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:picker animated:YES completion:nil];
                break;
            }
            case 2: {
                // Gallery
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerCameraCaptureModePhoto;
                [self presentViewController:picker animated:YES completion:nil];
                break;
            }
            case 3:
                // Message
                break;
            default:
                break;
        }
    }
}

#pragma mark - Alert View Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) {
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                // Confirm
                [self updatePassword:[alertView textFieldAtIndex:0].text];
                break;
            default:
                break;
        }
    } else if (alertView.tag == 1) {
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                // OK
                [self updateDropletDescription:[alertView textFieldAtIndex:0].text];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Image Picker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.chosenImage = info[UIImagePickerControllerOriginalImage];
    self.contentThumbnail.image = self.chosenImage;
    self.contentDetailLabel.text = @"Your Image";
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
