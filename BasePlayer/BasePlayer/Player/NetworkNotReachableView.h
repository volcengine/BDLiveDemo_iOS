//   
//   NetworkNotReachableView.h
//   BDLive
// 
//   Copyright © 2022 Beijing Volcano Engine Technology Co., Ltd. All rights reserved.
//   


#import "BDLBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@class NetworkNotReachableView;

@protocol NetworkNotReachableViewDelegate <NSObject>

- (void)networkNotReachableView:(NetworkNotReachableView *)notReachableview retryButtonDidTouch:(UIButton *)button;

@end

@interface NetworkNotReachableView : BDLBaseView

@property (nonatomic, weak) id<NetworkNotReachableViewDelegate> delegate;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UIButton *retryButton;

@end

NS_ASSUME_NONNULL_END
