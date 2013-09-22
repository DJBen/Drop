//
//  DRFileDownloader.h
//  Drop
//
//  Created by Sihao Lu on 9/21/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBChooserResult;
@interface DRFileManager : NSObject

+ (void)downloadFileFromDropbox:(DBChooserResult *)dropboxResult withThumbnailImageView:(UIImageView *)thumbnailImageView withProgress:(void (^)(CGFloat progress))progressBlock completion:(void (^)(NSString *fileName, NSString *filePath))completionBlock;

@end
