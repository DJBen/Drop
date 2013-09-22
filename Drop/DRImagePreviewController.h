//
//  DRImagePreviewController.h
//  Drop
//
//  Created by Sihao Lu on 9/22/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DRDroplet.h"

@interface DRImagePreviewController : UIViewController

@property (nonatomic, weak) DRDroplet *droplet;

- (IBAction)doneButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
