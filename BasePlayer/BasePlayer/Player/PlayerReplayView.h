//   
//   PlayerReplayView.h
//   BDLive
// 
//   Copyright © 2022 Beijing Volcano Engine Technology Co., Ltd. All rights reserved.
//   


#import "BDLBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@class PlayerReplayView;

@protocol PlayerReplayViewDelegate <NSObject>

- (void)replayViewDidTouch:(PlayerReplayView *)replayView;
- (void)playerReplayView:(PlayerReplayView *)replayView replayButtonDidTouch:(UIButton *)button;

@end

@interface PlayerReplayView : BDLBaseView

@property (nonatomic, weak) id<PlayerReplayViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
