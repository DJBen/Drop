//
//  DRAimingView.h
//  Drop
//
//  Created by Sihao Lu on 9/21/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DRAimingDelegate <NSObject>

- (void)dropFile;

@end

@interface DRAimingView : UIView

- (void)setDropVisible:(BOOL)visible animated:(BOOL)animated;

@property (nonatomic, assign) id <DRAimingDelegate> delegate;

@end
