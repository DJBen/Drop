//
//  DRViewController.h
//  Drop
//
//  Created by Sihao Lu on 9/21/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

@interface DRMainViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)dropButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dropButton;

@end
