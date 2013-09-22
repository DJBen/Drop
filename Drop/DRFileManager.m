//
//  DRFileDownloader.m
//  Drop
//
//  Created by Sihao Lu on 9/21/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import "DRFileManager.h"

#import <AFNetworking/AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import <DBChooser/DBChooser.h>

@implementation DRFileManager

+ (void)downloadFileFromDropbox:(DBChooserResult *)dropboxResult withThumbnailImageView:(UIImageView *)thumbnailImageView withProgress:(void (^)(CGFloat))progressBlock completion:(void (^)(NSString *, NSString *))completionBlock {
    NSURLRequest *request = [NSURLRequest requestWithURL:dropboxResult.link];
    AFURLConnectionOperation *operation = [[AFURLConnectionOperation alloc] initWithRequest:request];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:dropboxResult.name];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progressBlock((float)totalBytesRead / totalBytesExpectedToRead);
        });
    }];
    
    [operation setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(dropboxResult.name, filePath);
        });
    }];
    
    [operation start];
    
    // Set thumbnail to image view
    [thumbnailImageView setImageWithURL:(dropboxResult.thumbnails[@"64x64"])?dropboxResult.thumbnails[@"64x64"]:dropboxResult.iconURL];
}

@end
