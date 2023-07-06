//
//  PlayerControlView.m
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

#import "PlayerControlView.h"

#import <CoreText/CoreText.h>

@interface PlayerControlView () <
PlayerSliderViewDelegate
>

@property (nonatomic, assign, getter=isSliding) BOOL sliding;

@property (nonatomic, assign) BDLLanguageType langType;
@property (nonatomic, assign) BDLVideoResolution resolution;

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, assign) BOOL isVod;

@property (nonatomic, weak) id<BDLActivityService> svc;

@property (nonatomic, assign) BDLActivityStatus status;

- (void)setupViews;
- (void)setupLandscapeConstraints;

- (void)onFullScreenButton:(UIButton *)sender;

@end

@implementation PlayerControlView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.speed = BDLPlayerSpeed100X;
        self.needFullScreenButton = YES;
        [self setupViews];
        [self setupConstraints];
        [self setupActivity];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    
    self.controlBarView = [[UIView alloc] init];
    self.controlBarView.backgroundColor = [UIColor clearColor];
    
    [self.controlBarView addSubview:self.sliderView];
    [self.controlBarView addSubview:self.currentTimeLabel];
    [self.controlBarView addSubview:self.durationLabel];
    
    self.playButton = [[UIButton alloc] init];
    [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
    [self.playButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.playButton addTarget:self action:@selector(onPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlBarView addSubview:self.playButton];
    
    self.speedButton = [[UIButton alloc] init];
    [self.speedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.speedButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.speedButton addTarget:self action:@selector(onSpeedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlBarView addSubview:self.speedButton];
    
    self.centerPlayButton = [[UIButton alloc] init];
    [self.centerPlayButton setImage:[UIImage imageNamed:@"centerPlay"] forState:UIControlStateNormal];
    [self.centerPlayButton addTarget:self action:@selector(onCenterPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.centerPlayButton];
    
    self.refreshButton = [[UIButton alloc] init];
    [self.refreshButton setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    [self.refreshButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.refreshButton addTarget:self action:@selector(onRefreshButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlBarView addSubview:self.refreshButton];
    
    self.resolutionButton = [[UIButton alloc] init];
    [self.resolutionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.resolutionButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.resolutionButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
    [self.resolutionButton addTarget:self action:@selector(onResolutionButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlBarView addSubview:self.resolutionButton];
    
    self.backButton = [[UIButton alloc] init];
    [self.backButton setImage:[UIImage imageNamed:@"leftArrow"] forState:UIControlStateNormal];
    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.backButton addTarget:self action:@selector(onBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backButton];
    
    self.fullScreenButton = [[UIButton alloc] init];
    [self.fullScreenButton setImage:[UIImage imageNamed:@"fullScreen"] forState:UIControlStateNormal];
    [self.fullScreenButton setImage:[UIImage imageNamed:@"exit_fullscreen"] forState:UIControlStateSelected];
    [self.fullScreenButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.fullScreenButton addTarget:self action:@selector(onFullScreenButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlBarView addSubview:self.fullScreenButton];
   
    for (UIView *v in self.subviews) {
        v.hidden = YES;
    }
    [self addSubview:self.controlBarView];
    [self showGradientLayer:YES];
}

- (void)setupPortraitConstraints {
    [self.controlBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self);
        }
        make.height.mas_equalTo(40);
    }];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.controlBarView.mas_left).offset(21);
        make.bottom.equalTo(self.controlBarView).offset(-9);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.centerPlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    [self.refreshButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playButton.mas_right).offset(10);
        make.centerY.equalTo(self.playButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(16);
        make.top.equalTo(self.mas_top).offset(16);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.resolutionButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.controlBarView).offset(self.fullScreenButton.hidden ? -12 : -45);
        make.centerY.equalTo(self.playButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(40, 30));
    }];
    [self.fullScreenButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.controlBarView).offset(-12);
        make.centerY.equalTo(self.playButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playButton.mas_right).offset(12);
        make.centerY.equalTo(self.playButton.mas_centerY);
    }];
    [self.speedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.resolutionButton.mas_left).offset(-10);
        make.centerY.equalTo(self.playButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(40, 30));
    }];
    
    [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.speedButton.mas_left).offset(-10);
        make.centerY.equalTo(self.playButton.mas_centerY);
    }];
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel.mas_right).offset(8);
        make.right.equalTo(self.durationLabel.mas_left).offset(-8);
        make.centerY.equalTo(self.playButton.mas_centerY);
        make.height.mas_equalTo(14);
    }];
}

- (void)setupLandscapeConstraints {
    // NOTE: 全屏的时候，compactControlView会调用到这里，所以里面有些布局判断了状态
    [self.controlBarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    [self.playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.controlBarView.mas_left).offset(24);
        make.bottom.equalTo(self.controlBarView).offset(-6);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.centerPlayButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    [self.refreshButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playButton.mas_right).offset(10);
        make.centerY.equalTo(self.playButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.fullScreenButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.controlBarView.mas_right).offset(-12);
        make.centerY.equalTo(self.playButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(16);
        make.top.equalTo(self.mas_top).offset(16);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.resolutionButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.controlBarView).offset(self.fullScreenButton.hidden ? -12 : -45);
        make.centerY.equalTo(self.playButton);
        make.size.mas_equalTo(CGSizeMake(40, 30));
    }];
    [self.speedButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.resolutionButton.mas_centerX).offset(-40);
        make.centerY.equalTo(self.playButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(40, 30));
    }];
    [self.sliderView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.controlBarView.mas_left).offset(18);
        make.right.equalTo(self.controlBarView.mas_right).offset(-18);
        make.centerY.equalTo(self.controlBarView.mas_bottom).offset(-40);
        make.height.mas_equalTo(14);
    }];
    [self.currentTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.refreshButton.mas_right).offset(16);
        make.centerY.equalTo(self.playButton.mas_centerY);
    }];
    [self.durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel.mas_right);
        make.centerY.equalTo(self.playButton.mas_centerY);
    }];
}

- (void)setupConstraints {
    [self setupLandscapeConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.gradientLayer.frame = self.bounds;
}

- (void)setupActivity {
    BDLActivityModel *model = [self.svc getActivityModel];
    BDLBasicModel *basicModel = model.basic;
    self.langType = [self.svc getCurrentLangType];
    [self activityStatusDidChange:basicModel.status];
}

- (void)refreshViews {
    if (BDLPlayerSpeed100X == self.speed) {
        [self.speedButton setTitle:@"倍速" forState:UIControlStateNormal];
    }
    [self refreshResolutionButton];
}

- (UIFontDescriptor *)fontDescriptor {
    NSArray *settings = @[@{
        UIFontFeatureTypeIdentifierKey : @(6),
        UIFontFeatureSelectorIdentifierKey : @(kMonospacedNumbersSelector),
    }];
    UIFont *font = [UIFont systemFontOfSize:0];
    UIFontDescriptor *descriptor = [[font fontDescriptor] fontDescriptorByAddingAttributes:@{
        UIFontDescriptorFeatureSettingsAttribute : settings,
    }];
    return descriptor;
}

- (NSAttributedString *)timeStringFromProgress:(CGFloat)progress isCurrentTime:(BOOL)isCurrentTime {
    int time = self.duration * progress;
    NSString *str = nil;
    if (time >= 3600) {
        int hour = time / 3600;
        int minute = (time - hour * 3600) / 60;
        int second = time % 60;
        str = [NSString stringWithFormat:@"%i:%02i:%02i", hour, minute, second];
    } else {
        int minute = time / 60;
        int second = time % 60;
        str = [NSString stringWithFormat:@"%02i:%02i", minute, second];
    }
    if (isCurrentTime) {
        if (!self.backButton.hidden) {
            str = [str stringByAppendingString:@"/"];
        }
    }
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 2;
    shadow.shadowColor = [UIColor colorWithWhite:0 alpha:0.25];
    return [[NSAttributedString alloc] initWithString:str attributes:@{NSShadowAttributeName:shadow}];
}

- (PlayerSliderView *)sliderView {
    if (!_sliderView) {
        _sliderView = [[PlayerSliderView alloc] init];
        _sliderView.delegate = self;
    }
    return _sliderView;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.textAlignment = NSTextAlignmentRight;
        _currentTimeLabel.font = [UIFont fontWithDescriptor:self.fontDescriptor size:12];
        _currentTimeLabel.text = @"00:00";
        [_currentTimeLabel sizeToFit];
    }
    return _currentTimeLabel;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _durationLabel.textAlignment = NSTextAlignmentLeft;
        _durationLabel.font = [UIFont fontWithDescriptor:self.fontDescriptor size:12];
        _durationLabel.text = @"00:00";
        [_durationLabel sizeToFit];
    }
    return _durationLabel;
}

- (BOOL)isSliding {
    _sliding = self.sliderView.isSliding;
    return _sliding;
}

- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    self.durationLabel.attributedText = [self timeStringFromProgress:1 isCurrentTime:NO];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    _currentTime = currentTime;
    CGFloat progress = self.duration > 0 ? (currentTime / self.duration) : 0;
    [self setProgress:progress animated:NO];
}

- (BOOL)isPlaying {
    return self.playButton.selected;
}

- (void)play {
    if (self.playButton.selected) {
        self.playButton.selected = NO; // NOTE: 这里因为播放器可controlView对应关系没有固定,可能存在创建了新的播放器,但是没有恢复播放按钮状态的情况
    }
    [self.playButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)pause {
    if (self.playButton.isSelected) {
        [self.playButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)updatePlayButton:(BOOL)isPlaying {
    self.playButton.selected = isPlaying;
    self.centerPlayButton.hidden = isPlaying;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    self.currentTimeLabel.attributedText = [self timeStringFromProgress:progress isCurrentTime:YES];
    [self.sliderView setProgress:progress animated:animated];
}

- (void)setCacheProgress:(CGFloat)progress animated:(BOOL)animated {
    [self.sliderView setCacheProgress:progress animated:animated];
}

- (BOOL)showIfNeeded {
    if (![self canShow]) {
        return NO;
    }
    self.hidden = NO;
        
    return YES;
}

- (BOOL)canShow {
    // 非全屏，没有媒体的时候，不显示
    if (!self.fullScreenButton.selected
        && (BDLActivityStatusEnd == self.status
            || (BDLActivityStatusPreview == self.status && !self.isVod))) {
        return NO;
    }
    return YES;
}

- (void)hide {
    self.hidden = YES;
}

- (BOOL)startFloating {
    [self changeSubViewsAlphaExpectCenterPlayButton:0.0];
    return YES;
}

- (void)stopFloating {
    [self changeSubViewsAlphaExpectCenterPlayButton:1.0];
}

- (void)changeSubViewsAlphaExpectCenterPlayButton:(CGFloat)alpha {
    for (UIView *view in self.subviews) {
        if (view == self.centerPlayButton) {
            continue;
        }
        view.alpha = alpha;
    }
}

- (void)setSpeed:(PlayerSpeed)speed {
    _speed = speed;
    NSString *title = @"倍速";
    if (self.speed != PlayerSpeed100X) {
        switch (self.speed) {
            case PlayerSpeed200X: title = @"2.0x";  break;
            case PlayerSpeed150X: title = @"1.5x";  break;
            case PlayerSpeed125X: title = @"1.25x"; break;
            case PlayerSpeed075X: title = @"0.75x"; break;
            case PlayerSpeed050X: title = @"0.5x";  break;
            default: break;
        }
    }
    [self.speedButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark - Actions

- (void)onPlayButton:(UIButton *)sender {
    if (BDLActivityStatusEnd == self.status) {
        return;
    }
    
    self.playButton.selected = !self.playButton.selected;
    self.centerPlayButton.hidden = self.playButton.selected;
    
    if ([self.delegate respondsToSelector:@selector(controlView:playButtonDidTouch:)]) {
        [self.delegate controlView:self playButtonDidTouch:self.playButton.isSelected];
    }
}

- (void)onCenterPlayButton:(UIButton *)sender {
    [self onPlayButton:self.playButton];
}

- (void)onRefreshButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(controlViewRefreshButtonDidTouch:)]) {
        [self.delegate controlViewRefreshButtonDidTouch:self];
    }
}

- (void)onFullScreen {
    [self onFullScreenButton:self.fullScreenButton];
}

- (void)onFullScreenButton:(UIButton *)sender {
    self.fullScreenButton.selected = !self.fullScreenButton.selected;
    self.backButton.hidden = !self.fullScreenButton.selected;
    [self showOrHideFullScreenButton:!self.fullScreenButton.selected && self.needFullScreenButton];
    if (self.fullScreenButton.selected) {
        [self.playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.controlBarView).offset(15);
            make.bottom.equalTo(self.controlBarView).offset(-6);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
    } else {
        [self.playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.controlBarView.mas_left).offset(24);
            make.bottom.equalTo(self.controlBarView).offset(-6);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
    }
    
    if ([self.delegate respondsToSelector:@selector(controlView:fullScreenButtonDidTouch:)]) {
        [self.delegate controlView:self fullScreenButtonDidTouch:self.fullScreenButton.selected];
    }
}

- (void)setNeedFullScreenButton:(BOOL)needFullScreenButton {
    _needFullScreenButton = needFullScreenButton;
    [self showOrHideFullScreenButton:!self.fullScreenButton.selected && self.needFullScreenButton];
}

- (void)showOrHideFullScreenButton:(BOOL)show {
    self.fullScreenButton.hidden = !show;
    if (!self.resolutionButton.hidden) {
        [self.resolutionButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.controlBarView).offset(self.fullScreenButton.hidden ? -12 : -45);
        }];
    }
    else if (!self.speedButton.hidden) {
        [self.speedButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.controlBarView).offset(self.fullScreenButton.hidden ? -12 : -45);
            make.centerY.equalTo(self.playButton.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(40, 30));
        }];
    }
}

- (void)onBackButton:(UIButton *)sender {
    [self onFullScreenButton:self.fullScreenButton];
}

- (void)onSpeedButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(controlViewSpeedButtonDidTouch:)]) {
        [self.delegate controlViewSpeedButtonDidTouch:self];
    }
}

- (void)onResolutionButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(controlViewResolutionButtonDidTouch:)]) {
        [self.delegate controlViewResolutionButtonDidTouch:self];
    }
}

#pragma mark - PlayerSliderViewDelegate

- (void)sliderViewBeganDrag {
    if ([self.delegate respondsToSelector:@selector(controlViewSliderBeganDrag)]) {
        [self.delegate controlViewSliderBeganDrag];
    }
}

- (void)sliderViewEndDrag {
    if ([self.delegate respondsToSelector:@selector(controlViewSliderEndDrag)]) {
        [self.delegate controlViewSliderEndDrag];
    }
}

- (void)sliderView:(PlayerSliderView *)sliderView progressDidChange:(CGFloat)progress {
    self.currentTimeLabel.attributedText = [self timeStringFromProgress:progress isCurrentTime:YES];
    if ([self.delegate respondsToSelector:@selector(controlView:progressDidChange:)]) {
        [self.delegate controlView:self progressDidChange:progress];
    }
}

- (void)sliderViewDidTap:(PlayerSliderView *)sliderView {
    if ([self.delegate respondsToSelector:@selector(controlViewSliderViewDidTap)]) {
        [self.delegate controlViewSliderViewDidTap];
    }
}

#pragma mark - ResolutionButton

- (void)refreshResolutionButton {
    NSString *title = @"unknown";
    switch (self.resolution) {
        case BDLVideoResolutionLD:
            title = @"流畅";
            break;
        case BDLVideoResolutionSD:
            title = @"标清";
            break;
        case BDLVideoResolutionHD:
            title = @"高清";
            break;
        case BDLVideoResolutionUHD:
            title = @"超清";
            break;
        case BDLVideoResolutionBD:
            title = @"蓝光";
            break;
        case BDLVideoResolutionOrigin:
            title = @"原画";
            break;
        case BDLVideoResolutionAuto:
            title = @"智能";
            break;
        default:
            break;
    }
    [self.resolutionButton setTitle:title forState:UIControlStateNormal];
}

- (void)showResolutionButton {
    self.resolutionButton.hidden = NO;
    [self.speedButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.resolutionButton.mas_centerX).offset(-40);
        make.centerY.equalTo(self.playButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(40, 30));
    }];
}

- (void)hideResolutionButton {
    self.resolutionButton.hidden = YES;
    if (nil == self.playButton
        || nil == self.fullScreenButton) {
        return;
    }
    [self.speedButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.fullScreenButton.mas_centerX).offset(-38);
        make.centerY.equalTo(self.playButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(40, 30));
    }];
}

- (void)updateResolutionButtonWithResolutions:(NSArray<NSNumber *> *)resolutions currentResolution:(BDLVideoResolution)resolution {
    if (resolutions.count <= 1) {
        [self hideResolutionButton];
    } else {
        self.resolution = resolution;
        [self refreshResolutionButton];
        [self showResolutionButton];
    }
}

- (void)changeResolutionSuccess:(BOOL)success completeResolution:(BDLVideoResolution)completeResolution {
    if (success) {
        self.resolution = completeResolution;
        [self refreshResolutionButton];
    }
}

- (BOOL)shouldAutoPlay {
   return YES;
}

#pragma mark - BDLBasicService

- (void)activityStatusDidChange:(BDLActivityStatus)status {
    //NSLog(@"controlView %p activityStatusDidChange status=%@", self, @(status));
    self.status = status;
    
    self.isVod = NO;
    if (BDLActivityStatusPreview == status) {
        BDLActivityModel *model = [self.svc getActivityModel];
        if (model.basic.previewVideoUrl.length > 0) {
            self.isVod = YES;
        }
    } else if (BDLActivityStatusReplay == status) {
        self.isVod = YES;
    }
    
    BOOL autoPlay = [self shouldAutoPlay];
    if (!autoPlay
        && (BDLActivityStatusLive == status || self.isVod)) {
        self.centerPlayButton.hidden = NO;
    } else {
        self.centerPlayButton.hidden = YES;
    }
    // VOD时显示进度条
    self.sliderView.hidden = !self.isVod;
    self.currentTimeLabel.hidden = !self.isVod;
    self.durationLabel.hidden = !self.isVod;
    self.speedButton.hidden = !self.isVod;
    
    if (BDLActivityStatusLive == status
        || self.isVod) {
        self.fullScreenButton.hidden = self.fullScreenButton.selected;
        self.playButton.hidden = NO;
    } else {
        self.fullScreenButton.hidden = YES;
        self.playButton.hidden = YES;
    }
    
    if (BDLActivityStatusLive == status) {
        self.refreshButton.hidden = NO;
    } else {
        self.refreshButton.hidden = YES;
    }
    
    // 直播时分辨率按钮位置需根据刷新按钮位置调整
    if (BDLActivityStatusLive == status) {
        [self.resolutionButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.controlBarView).offset(self.fullScreenButton.hidden ? -12 : -45);
            make.centerY.equalTo(self.playButton);
            make.size.mas_equalTo(CGSizeMake(40, 30));
        }];
    } else {
        [self.resolutionButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.controlBarView).offset(self.fullScreenButton.hidden ? -12 : -45);
            make.centerY.equalTo(self.playButton.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(40, 30));
        }];
    }
    
    // 状态改变时 controlView 默认显示未播放状态
    if (self.playButton.selected && self.isVod) {
        [self onPlayButton:self.playButton];
        self.playButton.selected = NO;
    }
    
    [self refreshViews];
}

- (void)previewVideoDidChange:(NSString *)url isEnabled:(BOOL)isEnabled {
    [self activityStatusDidChange:self.status];
}

#pragma mark - BDLLanguageService

- (void)languageDidChangeEnable:(BOOL)isLanguageEnabled
                      langTypes:(NSArray<NSNumber *> *)langTypes
            multiLanguageEnable:(BOOL)isMultiLanguageEnabled {
    [self refreshViews];
}

- (void)languageTypeDidChange:(BDLLanguageType)langType {
    self.langType = langType;
    [self refreshViews];
}

#pragma mark - GradientLayer

- (void)addGradientLayer {
    if (self.gradientLayer != nil) {
        return;
    }
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.bounds;
    self.gradientLayer.colors = @[
        (__bridge id)[UIColor colorWithWhite:0 alpha:0.5].CGColor,
        (__bridge id)[UIColor clearColor].CGColor,
        (__bridge id)[UIColor clearColor].CGColor,
        (__bridge id)[UIColor colorWithWhite:0 alpha:0.5].CGColor];
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint = CGPointMake(0, 1);
    self.gradientLayer.locations = @[@0, @0.2, @0.8, @1];
    [self.layer insertSublayer:self.gradientLayer atIndex:0];
}

- (void)removeGradientLayer {
    if (self.gradientLayer != nil) {
        [self.gradientLayer removeFromSuperlayer];
        self.gradientLayer = nil;
    }
}

- (void)showGradientLayer:(BOOL)show {
    if (show) {
        [self addGradientLayer];
    } else {
        [self removeGradientLayer];
    }
}

- (id<BDLActivityService>)svc {
    if (!_svc) {
        _svc = [[BDLLiveEngine sharedInstance] getActivityService];
    }
    return _svc;
}
@end
