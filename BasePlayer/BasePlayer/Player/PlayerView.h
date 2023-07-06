//
//  PlayerView.h
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

#import <BDLive/BDLive.h>
#import "PlayerControlView.h"
#import "PlayerMaskView.h"
#import "PlayerResolutionView.h"
#import "PlayerSpeedView.h"
#import "LoadingView.h"
#import "NetworkNotReachableView.h"
#import "NetworkViaWWANView.h"
#import "PlayerReplayView.h"
#import "ContinuePlaybackToastView.h"

NS_ASSUME_NONNULL_BEGIN

@class PlayerView;
@protocol PlayerViewDelegate <NSObject>

@optional
- (void)playerView:(PlayerView *)playerView controlViewIsAppear:(BOOL)isAppear;
- (void)playerView:(PlayerView *)playerView didFinishPlayingWithIsLive:(BOOL)isLive;
- (void)playerView:(PlayerView *)playerView fullScreenButtonDidTouch:(BOOL)isSelected;
- (void)playerView:(PlayerView *)playerView videoSizeDidChange:(CGSize)size;
- (void)playerView:(PlayerView *)playerView coverImageDidChange:(nullable UIImage *)image error:(nullable NSError *)error;
- (void)playerViewDidSingleTap:(PlayerView *)playerView;
- (void)playerViewDidDoubleTap:(PlayerView *)playerView;
- (void)playerViewPlayerItemDidChange:(PlayerView *)playerView isLive:(BOOL)isLive willPlay:(BOOL)willPlay;

@end

@interface PlayerView : BDLBaseView

@property (nonatomic, weak) id<PlayerViewDelegate> delegate;
/// 弹窗的父控件 (倍速/清晰度)
@property (nonatomic, weak) UIView *popupSuperView;

@property (nonatomic, strong, readonly, nullable) BDLBasePlayerView *basePlayerView;

// 以下view如无自定义的需求，可以直接使用 BDLxxxView
@property (nonatomic, strong) PlayerMaskView *maskView;
@property (nonatomic, strong) PlayerControlView *controlView;
@property (nonatomic, strong, nullable) PlayerResolutionView *resolutionView;
@property (nonatomic, strong, nullable) PlayerSpeedView *speedView;
@property (nonatomic, strong, nullable) LoadingView *loadingView;
@property (nonatomic, strong, nullable) NetworkNotReachableView *networkNotReachableView;
@property (nonatomic, strong, nullable) NetworkViaWWANView *networkViaWWANView;
@property (nonatomic, strong, nullable) PlayerReplayView *replayView;
@property (nonatomic, strong, nullable) ContinuePlaybackToastView *continuePlaybackToastView;

@property (nonatomic, assign, readonly) BOOL isPiPStarted;
@property (nonatomic, assign, readonly) BOOL isFloating;
@property (nonatomic, assign, readonly) BOOL isFullScreen;
/// 播放器是否全屏
@property (nonatomic, assign) BOOL isPlayerFullSuper;
// 是否为竖屏视频
@property (nonatomic, assign) BOOL isPortraitVideo;

- (void)showControlViewIfNeededWithAutoHide:(BOOL)autoHide;
- (void)hideControlView;
- (void)autoHideControlView;

- (void)stop;

- (BOOL)canFloating;

- (void)enterFullScreen;
- (void)leaveFullScreen;

- (void)updatePlayerWhenLeaveFullScreen;

- (void)addBasePlayerView:(BDLBasePlayerView *)basePlayerView;

@end

NS_ASSUME_NONNULL_END
