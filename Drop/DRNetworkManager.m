//
//  DRFileDownloader.m
//  Drop
//
//  Created by Sihao Lu on 9/21/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import "DRNetworkManager.h"

#import <AFNetworking/AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import <DBChooser/DBChooser.h>
#import "DRAppDelegate.h"
#import "DRDroplet.h"

#define ServerPath @"http://54.227.244.15/"

@interface DRNetworkManager ()

@property (nonatomic) NSString *userID;

@property (nonatomic) NSString *userName;

@end

@implementation DRNetworkManager

+ (DRNetworkManager *)sharedManager {
    static dispatch_once_t onceToken;
    static DRNetworkManager *sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[DRNetworkManager alloc] init];
    });
    return sharedManager;
}

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

+ (void)loginToDropServer {
    DRAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSURL *url = [NSURL URLWithString:ServerPath];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    

    NSString *accessToken = [[[appDelegate session] accessTokenData] accessToken];
    
    if (!appDelegate.session.accessTokenData.accessToken) {
        NSLog(@"Warning! No access token.");
        return;
    }
    
    NSDictionary *params = @{@"access_token" : accessToken};
    [httpClient postPath:@"/login/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSDictionary *returnValue = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        
        [[self sharedManager] setUserID:returnValue[@"user_id"]];
        [[self sharedManager] setUserName:returnValue[@"user_name"]];
        
        NSLog(@"Request Successful, response '%@'", returnValue);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.description);
    }];
}

+ (void)uploadDroplet:(DRDroplet *)droplet withProgress:(void (^)(CGFloat))progressBlock withCompletion:(void (^)())completionBlock {
    NSURL *url = [NSURL URLWithString:ServerPath];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSString *mimeType;
    NSString *fileName;
    NSData *fileData;
    if ([droplet image]) {
        fileData = UIImagePNGRepresentation(droplet.image);
        mimeType = [self contentTypeForImageData:fileData];
        fileName = @"content.png";
    } else if ([droplet filePath]) {
        fileData = [NSData dataWithContentsOfFile:droplet.filePath];
        mimeType = [self mimeTypeForFileAtPath:droplet.filePath];
        fileName = [droplet.filePath lastPathComponent];
    }
    
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/drop/" parameters:@{@"access_token" : [self accessToken], @"comment" : fileName, @"title" : droplet.dropletDescription, @"type" : mimeType} constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
        [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:mimeType];
    }];
    
    NSLog(@"Access token: %@", [self accessToken]);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Upload successful %@", JSON);
        
        NSString *fileId = JSON[@"drop_id"];
        NSURL *url = [NSURL URLWithString:ServerPath];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        
        if (!fileId) return;
        
        NSDictionary *params = @{@"longitude" : @(droplet.coordinate.longitude), @"latitude" : @(droplet.coordinate.latitude), @"radius" : @(droplet.range), @"expires_in" : @(droplet.duration), @"file_id" : fileId, @"access_token" : [self accessToken]};
        
        [httpClient postPath:@"/entry/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *returnValue = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            completionBlock(returnValue[@"response"]);
            NSLog(@"Post entry: %@", returnValue);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Post drops failed %@", error);
            completionBlock(nil);
        }];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Upload failed with error %@", error);
        completionBlock();
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progressBlock((float)totalBytesWritten / totalBytesExpectedToWrite);
        });
    }];
    
    [httpClient enqueueHTTPRequestOperation:operation];
}

+ (void)getDropsNearCoordinate:(CLLocationCoordinate2D)coordinate withCompletion:(void (^)(NSArray *))completionBlock {
    static CLLocationDistance nearRange = 5000;
    
    NSURL *url = [NSURL URLWithString:ServerPath];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSDictionary *params = @{@"longitude" : @(coordinate.longitude), @"latitude" : @(coordinate.latitude), @"radius" : @(nearRange)};
    
    [httpClient getPath:@"/entry/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *returnValue = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSMutableArray *droplets = [[NSMutableArray alloc] init];
        for (NSDictionary *dropletInfo in returnValue[@"response"]) {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([dropletInfo[@"latitude"] doubleValue], [dropletInfo[@"longitude"] doubleValue]);
            DRDroplet *droplet = [[DRDroplet alloc] initWithCoordinate:coordinate];
            droplet.dropletDescription = dropletInfo[@"title"];
            droplet.comment = dropletInfo[@"comment"];
            droplet.mimeType = dropletInfo[@"type"];
            droplet.dropID = dropletInfo[@"file_id"];
            [droplets addObject:droplet];
        }
        completionBlock([droplets copy]);
        NSLog(@"%@", returnValue[@"response"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get drops failed %@", error);
        completionBlock(nil);
    }];
}

+ (void)downloadFileWithDroplet:(DRDroplet *)droplet withCompletion:(void (^)(NSString *))completionBlock {
    
    NSURL *url = [NSURL URLWithString:ServerPath];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSURLRequest *request = [httpClient requestWithMethod:@"GET" path:@"/drop/" parameters:@{@"drop_id" : droplet.dropID, @"querytype" : @(0)}];

    AFURLConnectionOperation *operation = [[AFURLConnectionOperation alloc] initWithRequest:request];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:droplet.comment];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Downloading from droplet: %f", (float)totalBytesRead / totalBytesExpectedToRead);
        });
    }];
    
    [operation setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(filePath);
        });
    }];
    
    [operation start];
    
}

#pragma mark - Helper Methods

+ (NSString *)mimeTypeForFileAtPath:(NSString *) path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    // Borrowed from http://stackoverflow.com/questions/5996797/determine-mime-type-of-nsdata-loaded-from-a-file
    // itself, derived from  http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!mimeType) {
        return @"application/octet-stream";
    }
    return (__bridge NSString *)mimeType;
}

+ (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

+ (NSString *)accessToken {
    DRAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return [[[appDelegate session] accessTokenData] accessToken];
}
@end
