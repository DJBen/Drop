//
//  DRDropSettingsViewController.h
//  Drop
//
//  Created by Sihao Lu on 9/21/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

@class DRDroplet;
@protocol DRDropSettingsDelegate <NSObject>

- (void)dropSettingsCancelled:(id)sender;
- (void)dropSettingsDone:(id)sender droplet:(DRDroplet *)droplet;

@end

@interface DRDropSettingsViewController : UIViewController <MKMapViewDelegate>

- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)dropButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, assign) id <DRDropSettingsDelegate> delegate;

@property (nonatomic) MKCoordinateRegion originalRegion;

@property (weak, nonatomic) IBOutlet UILabel *rangeLabel;
- (IBAction)rangeValueChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *durationButton;
- (IBAction)durationButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *passwordButton;
- (IBAction)passwordButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *chooseContentButton;
- (IBAction)chooseContentButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *contentDetailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentThumbnail;

@property (weak, nonatomic) IBOutlet UIButton *dropletDescriptionButton;
- (IBAction)describeDroplet:(id)sender;

@end
