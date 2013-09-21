//
//  DRDropSettingsViewController.h
//  Drop
//
//  Created by Sihao Lu on 9/21/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

@protocol DRDropSettingsDelegate <NSObject>

- (void)dropSettingsCancelled:(id)sender;
- (void)dropSettingsDone:(id)sender;

@end

@interface DRDropSettingsViewController : UIViewController

- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)dropButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, assign) id <DRDropSettingsDelegate> delegate;

- (void)focusToCoordinate:(CLLocationCoordinate2D)coordinate;

@end
