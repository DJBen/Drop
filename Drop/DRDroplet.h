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

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
