//
//  DRFileDownloader.h
//  Drop
//
//  Created by Sihao Lu on 9/21/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@class DBChooserResult, DRDroplet;
@interface DRNetworkManager : NSObject

+ (void)downloadFileFromDropbox:(DBChooserResult *)dropboxResult withThumbnailImageView:(UIImageView *)thumbnailImageView withProgress:(void (^)(CGFloat progress))progressBlock completion:(void (^)(NSString *fileName, NSString *filePath))completionBlock;

+ (void)loginToDropServer;

+ (void)uploadDroplet:(DRDroplet *)droplet withProgress:(void (^)(CGFloat progress))progressBlock withCompletion:(void (^)())completionBlock;

+ (void)getDropsNearCoordinate:(CLLocationCoordinate2D)coordinate withCompletion:(void (^)(NSArray *droplets))completionBlock;

+ (void)downloadFileWithDroplet:(DRDroplet *)droplet withCompletion:(void (^)(NSString *filePath))completionBlock;

@end
