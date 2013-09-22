//
//  DRDroplet.m
//  Drop
//
//  Created by Sihao Lu on 9/21/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import "DRDroplet.h"

@interface DRDroplet ()

@end

@implementation DRDroplet

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        _coordinate = coordinate;
    }
    return self;
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate range:(CLLocationDistance)range duration:(NSTimeInterval)duration password:(NSString *)password {
    self = [self initWithCoordinate:coordinate];
    if (self) {
        _range = range;
        _duration = duration;
        _password = password;
    }
    return self;
}

#pragma mark - Annotation
- (NSString *)title {
    return self.dropletDescription;
}

- (NSString *)subtitle {
    return self.comment;
}

@end
