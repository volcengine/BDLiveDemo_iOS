//
//  PlayerControlView.h
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

#import <UIKit/UIKit.h>
#import <BDLive/BDLive.h>

#import "PlayerSliderView.h"
#import "PlayerSpeedView.h"

NS_ASSUME_NONNULL_BEGIN

@class PlayerControlView;

@protocol PlayerControlViewDelegate <NSObject>

- (void)controlView:(PlayerControlView *)controlView playButtonDidTouch:(BOOL)isSelected;

- (void)controlViewSliderBeganDrag;
- (void)controlViewSliderEndDrag;
- (void)controlViewSliderViewDidTap;
- (void)controlView:(PlayerControlView *)controlView progressDidChange:(CGFloat)progress;

@optional

- (void)controlViewRefreshButtonDidTouch:(PlayerControlView *)controlView;
- (void)controlViewResolutionButtonDidTouch:(PlayerControlView *)controlView;
- (void)controlViewSpeedButtonDidTouch:(PlayerControlView *)controlView;
- (void)controlView:(PlayerControlView *)controlView fullScreenButtonDidTouch:(BOOL)isSelected;
- (void)controlView:(PlayerControlView *)controlView resolutionDidChange:(BDLVideoResolution)resolution;

@end

@interface PlayerControlView : BDLBaseView <BDLBasicService>

@property (nonatomic, weak) id<PlayerControlViewDelegate> delegate;

@property (nonatomic, strong) UIView *controlBarView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong, nullable) UIButton *centerPlayButton;
@property (nonatomic, strong, nullable) UIButton *refreshButton;
@property (nonatomic, strong, nullable) UIButton *fullScreenButton;
@property (nonatomic, strong, nullable) UIButton *backButton;

@property (nonatomic, assign) BOOL needFullScreenButton;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, strong) PlayerSliderView *sliderView;
@property (nonatomic, readonly, getter=isSliding) BOOL sliding;

@property (nonatomic, strong) UIButton *speedButton;

@property (nonatomic, assign) PlayerSpeed speed;

@property (nonatomic, strong, nullable) UIButton *resolutionButton;
- (BOOL)canShow;
- (void)play;
- (void)pause;

- (void)updatePlayButton:(BOOL)isPlaying;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
- (void)setCacheProgress:(CGFloat)progress animated:(BOOL)animated;
- (BOOL)showIfNeeded;
- (void)hide;
- (BOOL)isPlaying;

- (BOOL)startFloating;
- (void)stopFloating;

- (void)updateResolutionButtonWithResolutions:(NSArray<NSNumber *> *)resolutions currentResolution:(BDLVideoResolution)resolution;
- (void)changeResolutionSuccess:(BOOL)success completeResolution:(BDLVideoResolution)completeResolution;

- (void)onFullScreen;

@end

NS_ASSUME_NONNULL_END
