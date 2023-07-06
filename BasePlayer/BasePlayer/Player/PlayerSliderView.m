//
//  PlayerSliderView.m
// 
//   BDLive SDK License
//   
//   Copyright 2023 Beijing Volcano Engine Technology Ltd. All Rights Reserved.
//   
//   The BDLive SDK was developed by Beijing Volcanoengine Technology Ltd. (hereinafter “Volcano Engine”). 
//   Any copyright or patent right is owned by and proprietary material of the Volcano Engine. 
//   
//   BDLive SDK is available under the VolcLive product and licensed under the commercial license. 
//   Customers can contact service@volcengine.com for commercial licensing options. 
//   Here is also a link to subscription services agreement: https://www.volcengine.com/docs/6256/68938.
//   
//   Without Volcanoengine's prior written permission, any use of BDLive SDK, in particular any use for commercial purposes, is prohibited. 
//   This includes, without limitation, incorporation in a commercial product, use in a commercial service, or production of other artefacts for commercial purposes. 
//   
//   Without Volcanoengine's prior written permission, the BDLive SDK may not be reproduced, modified and/or made available in any form to any third party. 
//


#import <Masonry/Masonry.h>

#import "PlayerSliderView.h"

#define kBDLSliderHeight 3.0
#define kBDLThumbViewWidth 12.0

@interface PlayerSliderView ()

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat cacheProgress;
@property (nonatomic, assign) CGFloat progressBeforeDragging;
@property (nonatomic, assign, getter=isSliding) BOOL sliding;

@end

@implementation PlayerSliderView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.backgroundView];
    [self addSubview:self.thumbView];
    [self.backgroundView addSubview:self.cacheProgressView];
    [self.backgroundView addSubview:self.trackProgressView];
    [self addGestureRecognizer:self.panGesture];
    [self addGestureRecognizer:self.tapGesture];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateLayout];
    [self updateCacheProgress];
    [self updateTrackProgress];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    progress = MIN(1, MAX(0, progress));
    self.progress = progress;
    
    [UIView animateWithDuration:animated ? 0.3 : 0.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self updateTrackProgress];
    } completion:nil];
}

- (void)setCacheProgress:(CGFloat)progress animated:(BOOL)animated {
    progress = MIN(1, MAX(0, progress));
    self.cacheProgress = progress;
    [self updateCacheProgress];
}

- (void)updateLayout {
    CGRect rc;
    rc.size.width = self.frame.size.width;
    rc.size.height = kBDLSliderHeight;
    rc.origin.x = self.frame.size.width/2 - rc.size.width/2;
    rc.origin.y = self.frame.size.height/2 - rc.size.height/2;
    self.backgroundView.frame = rc;
    
    rc = self.trackProgressView.frame;
    rc.size.height = self.backgroundView.frame.size.height;
    self.trackProgressView.frame = rc;
    
    rc = self.cacheProgressView.frame;
    rc.size.height = self.backgroundView.frame.size.height;
    self.cacheProgressView.frame = rc;
    
    CGPoint pt = self.thumbView.center;
    pt.y = self.backgroundView.center.y;
    self.thumbView.center = pt;
}

- (void)updateCacheProgress {
    CGRect rc = self.cacheProgressView.frame;
    rc.size.width = self.backgroundView.frame.size.width * self.cacheProgress;
    self.cacheProgressView.frame = rc;
}

- (void)updateTrackProgress {
    CGRect rc = self.trackProgressView.frame;
    rc.size.width = self.backgroundView.frame.size.width * self.progress;
    self.trackProgressView.frame = rc;
    [self updateThumbPosition];
}

- (void)updateThumbPosition {
    CGFloat minCenterX = kBDLThumbViewWidth * 0.5;
    CGFloat maxCenterX = self.backgroundView.frame.size.width - kBDLThumbViewWidth * 0.5;
    CGPoint pt = self.thumbView.center;
    pt.x = [self progressMaxWidth] * self.progress + minCenterX;
    pt.x = MIN(maxCenterX, MAX(minCenterX, pt.x));
    self.thumbView.center = pt;
}

- (CGFloat)progressMaxWidth {
    return self.backgroundView.frame.size.width - kBDLThumbViewWidth;
}

- (void)onPanGesture:(UIPanGestureRecognizer *)pan {
    UIGestureRecognizerState state = pan.state;
    CGPoint translate = [pan translationInView:self];
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            self.sliding = YES;
            self.progressBeforeDragging = self.progress;
            [UIView animateWithDuration:0.3 animations:^{
                self.thumbView.transform = CGAffineTransformMakeScale(1.3, 1.3);
            }];
            if ([self.delegate respondsToSelector:@selector(sliderViewBeganDrag)]) {
                [self.delegate sliderViewBeganDrag];
            }
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat progressDelta = translate.x / [self progressMaxWidth];
            CGFloat newProgress = self.progressBeforeDragging + progressDelta;
            newProgress = newProgress < 0 ? 0 : newProgress;
            newProgress = newProgress > 1 ? 1 : newProgress;
            [self setProgress:newProgress animated:NO];
            if ([self.delegate respondsToSelector:@selector(sliderView:progressDidChange:)]) {
                [self.delegate sliderView:self progressDidChange:newProgress];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed: {
            [UIView animateWithDuration:0.3 animations:^{
                self.thumbView.transform = CGAffineTransformIdentity;
            }];
            self.sliding = NO;
            if ([self.delegate respondsToSelector:@selector(sliderViewEndDrag)]) {
                [self.delegate sliderViewEndDrag];
            }
        }
            break;
        default:
            break;
    }
}

- (void)onTapGesture:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    CGFloat newProgress = point.x / self.frame.size.width;
    [self setProgress:newProgress animated:NO];
    if ([self.delegate respondsToSelector:@selector(sliderView:progressDidChange:)]) {
        [self.delegate sliderView:self progressDidChange:newProgress];
    }
    if ([self.delegate respondsToSelector:@selector(sliderViewDidTap:)]) {
        [self.delegate sliderViewDidTap:self];
    }
}

- (UIView *)thumbView {
    if (!_thumbView) {
        _thumbView = [[UIView alloc] init];
        _thumbView.layer.cornerRadius = kBDLThumbViewWidth * 0.5;
        _thumbView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        CGRect frame = _thumbView.frame;
        frame.size = CGSizeMake(kBDLThumbViewWidth, kBDLThumbViewWidth);
        _thumbView.frame = frame;
        //_thumbView.layer.borderWidth = 3;
        //_thumbView.layer.borderColor = self.config.common.themeColor.CGColor;
        _thumbView.userInteractionEnabled = NO;
    }
    return _thumbView;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.layer.cornerRadius = kBDLSliderHeight * 0.5;
        _backgroundView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.6];
    }
    return _backgroundView;
}

- (UIView *)trackProgressView {
    if (!_trackProgressView) {
        _trackProgressView = [[UIView alloc] init];
        _trackProgressView.backgroundColor = [UIColor colorWithRed:44/255.0 green:110/255.0 blue:250/255.0 alpha:1];
        _trackProgressView.layer.cornerRadius = kBDLSliderHeight * 0.5;
    }
    return _trackProgressView;
}

- (UIView *)cacheProgressView {
    if (!_cacheProgressView) {
        _cacheProgressView = [[UIView alloc] init];
        _cacheProgressView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5];
        _cacheProgressView.layer.cornerRadius = kBDLSliderHeight * 0.5;
    }
    return _cacheProgressView;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    }
    return _panGesture;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    }
    return _tapGesture;
}

@end
