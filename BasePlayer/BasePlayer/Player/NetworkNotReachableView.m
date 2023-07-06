//   
//   NetworkNotReachableView.m
//   BDLive
// 
//   Copyright © 2022 Beijing Volcano Engine Technology Co., Ltd. All rights reserved.
//   


#import <Masonry/Masonry.h>

#import "NetworkNotReachableView.h"
#import "BDLActivityService.h"
#import "Utils.h"

@interface NetworkNotReachableView ()

@end

@implementation NetworkNotReachableView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupViews {
    self.promptLabel = [[UILabel alloc] init];
    self.promptLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    self.promptLabel.textColor = [UIColor whiteColor];;
    self.promptLabel.textAlignment = NSTextAlignmentCenter;
    self.promptLabel.numberOfLines = 2;
    [self addSubview:self.promptLabel];
    self.promptLabel.textColor = [UIColor whiteColor];
    self.promptLabel.text = @"当前网络不可用，请检查网络连接后重试";
    
    self.retryButton = [[UIButton alloc] init];
    self.retryButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.retryButton.layer.cornerRadius = 19;
    self.retryButton.layer.borderWidth = 1;
    self.retryButton.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.3].CGColor;
    self.retryButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.retryButton addTarget:self action:@selector(onRetryButton:) forControlEvents:UIControlEventTouchUpInside];
    self.retryButton.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16); // 文字多的时候不那么拥挤
    [self addSubview:self.retryButton];
    self.retryButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];;
    [self.retryButton setTitle:@"刷新重试" forState:UIControlStateNormal];
}

- (void)setupConstraints {
    [self.promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.centerX.equalTo(self);
        make.left.greaterThanOrEqualTo(self);
        make.right.lessThanOrEqualTo(self);
        make.width.mas_equalTo(300);
    }];
    [self.retryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.promptLabel.mas_bottom).offset(12);
        make.height.equalTo(@38);
        make.width.greaterThanOrEqualTo(@98);
        make.left.greaterThanOrEqualTo(self);
        make.right.lessThanOrEqualTo(self);
        make.bottom.equalTo(self);
    }];
}

- (void)onRetryButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(networkNotReachableView:retryButtonDidTouch:)]) {
        [self.delegate networkNotReachableView:self retryButtonDidTouch:sender];
    }
}

@end
