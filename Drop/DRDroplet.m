//
//  DRDroplet.m
//  Drop
//
//  Created by Sihao Lu on 9/21/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import "DRDroplet.h"

@interface DRDroplet ()

@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

@implementation DRDroplet

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        _coordinate = coordinate;
    }
    return self;
}

#pragma mark - Annotation
- (NSString *)title {
    return @"Test";
}

- (NSString *)subtitle {
    return @"Test Subtitle";
}

- (CLLocationCoordinate2D)coordinate {
    return _coordinate;
}

@end
