//   
//   PlayerSpeedView.h
//   BDLive
// 
//   Copyright © 2022 Beijing Volcano Engine Technology Co., Ltd. All rights reserved.
//   


#import "BDLPopupBaseView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PlayerSpeed) {
    PlayerSpeed200X,
    PlayerSpeed150X,
    PlayerSpeed125X,
    PlayerSpeed100X,
    PlayerSpeed075X,
    PlayerSpeed050X,
};

@class PlayerSpeedView;

@protocol PlayerSpeedViewDelegate <NSObject>

- (void)speedView:(PlayerSpeedView *)speedView speedDidChange:(PlayerSpeed)speed;

@end

@interface PlayerSpeedView : BDLPopupBottomOrRightShowBaseView

@property (nonatomic, weak) id<PlayerSpeedViewDelegate> delegate;

@property (nonatomic, assign) BOOL fullScreen;
@property (nonatomic, assign) PlayerSpeed speed;

+ (CGFloat)valueFromSpeed:(PlayerSpeed)speed;

@end

NS_ASSUME_NONNULL_END
