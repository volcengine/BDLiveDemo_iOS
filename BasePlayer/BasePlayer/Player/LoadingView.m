//   
//   LoadingView.m
//   BDLive
// 
//   Copyright © 2022 Beijing Volcano Engine Technology Co., Ltd. All rights reserved.
//   


#import <Masonry/Masonry.h>

#import "LoadingView.h"

@interface LoadingView ()

@property (nonatomic, assign) BOOL isAnimating;

@end

@implementation LoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    _imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = [UIImage imageNamed:@"loading"];
    [self addSubview:self.imageView];
}

- (void)setupConstraints {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
}

- (void)showAnimation {
    if (self.isAnimating) {
        return;
    }
    self.isAnimating = YES;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    animation.duration = 1;
    animation.cumulative = YES;
    animation.repeatCount = FLT_MAX;
    animation.removedOnCompletion = NO;
    [self.imageView.layer addAnimation:animation forKey:@"rotationAnimation"];
}

- (void)hideAnimation {
    if (!self.isAnimating) {
        return;
    }
    self.isAnimating = NO;
    [self.imageView.layer removeAllAnimations];
}

@end
