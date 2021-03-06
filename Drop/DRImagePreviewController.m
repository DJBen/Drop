//
//  DRImagePreviewController.m
//  Drop
//
//  Created by Sihao Lu on 9/22/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import "DRImagePreviewController.h"

#import "DRNetworkManager.h"
#import <MBProgressHUD.h>

@interface DRImagePreviewController ()

@end

@implementation DRImagePreviewController

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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Loading Image..."];
    [DRNetworkManager downloadFileWithDroplet:self.droplet withCompletion:^(NSString *filePath) {
        [self.imageView setImage:[UIImage imageWithContentsOfFile:filePath]];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
