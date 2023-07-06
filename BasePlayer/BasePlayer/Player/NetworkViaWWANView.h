//   
//   NetworkViaWWANView.h
//   BDLive
// 
//   Copyright © 2022 Beijing Volcano Engine Technology Co., Ltd. All rights reserved.
//   


#import "BDLBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@class NetworkViaWWANView;

@protocol NetworkViaWWANViewDelegate <NSObject>

- (void)networkViaWWANViewDidTouch:(NetworkViaWWANView *)wwanView;

@end

@interface NetworkViaWWANView : BDLBaseView

@property (nonatomic, weak) id<NetworkViaWWANViewDelegate> delegate;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UIView *contentView;

@end

NS_ASSUME_NONNULL_END
