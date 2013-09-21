//
//  DRAimingView.m
//  Drop
//
//  Created by Sihao Lu on 9/21/13.
//  Copyright (c) 2013 Hophacks 2013. All rights reserved.
//

#import "DRAimingView.h"

@interface DRAimingView ()

@property (nonatomic, strong) UIButton *drop;

@end

@implementation DRAimingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Set background color half transparent
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        
        // Add pin to the center of screen
        UIImage *mockPin = [UIImage imageNamed:@"MockPin"];
        UIImageView *whitePin = [[UIImageView alloc] initWithImage:mockPin];
        CGSize pinSize = mockPin.size;
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        whitePin.frame = CGRectMake((screenBounds.size.width - pinSize.width) / 2, (screenBounds.size.height - pinSize.height) / 2 + pinSize.height / 2, pinSize.width, pinSize.height);
        [self addSubview:whitePin];
        
        self.drop = [UIButton buttonWithType:UIButtonTypeSystem];
        CGSize dropSize = CGSizeMake(100, 50);
        self.drop.frame = CGRectMake((screenBounds.size.width - dropSize.width) / 2, (screenBounds.size.height - dropSize.height) / 2 - pinSize.height, dropSize.width, dropSize.height);
        [self.drop setTitle:@"Drop it" forState:UIControlStateNormal];
        [self.drop setBackgroundColor:[UIColor whiteColor]];
        [self.drop addTarget:self action:@selector(dropButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.drop setAlpha:0.0];
        [self addSubview:self.drop];
        
    }
    return self;
}

- (id)init {
    self = [self initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        [self setDropVisible:YES animated:YES];
    }
    return self;
}

- (void)setDropVisible:(BOOL)visible animated:(BOOL)animated {
    if (visible) {
        if (animated) {
            [UIView animateWithDuration:0.4 animations:^{
                self.drop.alpha = 1.0;
            }];
        } else {
            [self.drop setAlpha:1.0];
        }
    } else {
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                self.drop.alpha = 0.0f;
            }];
        } else {
            [self.drop setAlpha:0.0];
        }
    }
}

- (void)setDropEnabled:(BOOL)enabled {
    if (enabled && !self.drop.enabled) {
        [self.drop setEnabled:YES];
    } else if (!enabled && self.drop.enabled) {
        [self.drop setEnabled:NO];
    }
}

- (void)dropButtonTapped:(UIButton *)dropButton {
    [self setDropVisible:NO animated:YES];
    [self.delegate dropFile];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return CGRectContainsPoint(self.drop.frame, point);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
