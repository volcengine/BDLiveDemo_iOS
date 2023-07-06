//   
//   PlayerReplayView.m
//   BDLive
// 
//   Copyright © 2022 Beijing Volcano Engine Technology Co., Ltd. All rights reserved.
//   


#import <Masonry/Masonry.h>

#import "PlayerReplayView.h"
#import "BDLActivityService.h"
#import "Utils.h"

@interface PlayerReplayView ()

@property (nonatomic, strong) UIView *replayView;

@property (nonatomic, strong) UILabel *replayLabel;
@property (nonatomic, strong) UIButton *replayButton;

@end

@implementation PlayerReplayView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupViews {
    
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    
    self.replayView = [[UIView alloc] init];
    self.replayView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.replayView];
    
    self.replayLabel = [[UILabel alloc] init];
    [self.replayView addSubview:self.replayLabel];
    self.replayLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    self.replayLabel.textColor = [UIColor whiteColor];
    self.replayLabel.textAlignment = NSTextAlignmentCenter;
    self.replayLabel.numberOfLines = 2;
    self.replayLabel.text = @"点击重新播放";
    
    self.replayButton = [[UIButton alloc] init];
    [self.replayView addSubview:self.replayButton];
    [self.replayButton addTarget:self action:@selector(onReplayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.replayButton setTitle:nil forState:UIControlStateNormal];
    self.replayButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.replayButton.backgroundColor = UIColor.clearColor;
    [self.replayButton setImage:[UIImage imageNamed:@"replay"] forState:UIControlStateNormal];
}

- (void)setupConstraints {
    [self.replayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(200);
    }];
    [self.replayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.replayView);
        make.centerX.equalTo(self.replayView);
        make.width.mas_equalTo(300);
    }];
    [self.replayButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.replayView);
        make.top.equalTo(self.replayLabel.mas_bottom).offset(16);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.bottom.equalTo(self.replayView);
    }];
    
}

- (void)onReplayButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(playerReplayView:replayButtonDidTouch:)]) {
        [self.delegate playerReplayView:self replayButtonDidTouch:sender];
    }
}

- (void)onTapGesture:(UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(replayViewDidTouch:)]) {
        [self.delegate replayViewDidTouch:self];
    }
}

@end
