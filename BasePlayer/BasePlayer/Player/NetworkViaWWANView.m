//   
//   NetworkViaWWANView.m
//   BDLive
// 
//   Copyright © 2022 Beijing Volcano Engine Technology Co., Ltd. All rights reserved.
//   


#import <Masonry/Masonry.h>

#import "NetworkViaWWANView.h"

@interface NetworkViaWWANView ()

@end

@implementation NetworkViaWWANView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupViews {
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    [self addGestureRecognizer:tapGesture];
    
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    self.contentView.layer.cornerRadius = 4;
    [self addSubview:self.contentView];
    
    self.promptLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.promptLabel];
    self.promptLabel.textColor = [UIColor whiteColor];
    self.promptLabel.text = @"当前处于非Wi-Fi网络，播放将消耗流量";
    self.promptLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    self.promptLabel.textColor = [UIColor whiteColor];
    self.promptLabel.textAlignment = NSTextAlignmentCenter;
    self.promptLabel.numberOfLines = 2;
    self.promptLabel.textColor = [UIColor whiteColor];
    self.promptLabel.text = @"当前处于非Wi-Fi网络，播放将消耗流量";
}

- (void)setupConstraints {
    [self.promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(300);
    }];
    
    CGFloat offset = 16;
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.promptLabel).offset(-offset);
        make.bottom.equalTo(self.promptLabel).offset(offset);
        make.left.equalTo(self.promptLabel).offset(-offset);
        make.right.equalTo(self.promptLabel).offset(offset);
    }];
}

- (void)onTapGesture:(UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(networkViaWWANViewDidTouch:)]) {
        [self.delegate networkViaWWANViewDidTouch:self];
    }
}

@end
