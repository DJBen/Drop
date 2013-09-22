//
//  DRDroplet.h
//  Drop
//
//  Created by Sihao Lu on 9/21/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface DRDroplet : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic) CLLocationDistance range;

@property (nonatomic) NSTimeInterval duration;

@property (nonatomic, strong) NSString *dropletDescription;

@property (nonatomic, strong) NSString *comment;

@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) NSString *dropID;

@property (nonatomic, strong) NSString *mimeType;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate range:(CLLocationDistance)range duration:(NSTimeInterval)duration password:(NSString *)password;

@end
