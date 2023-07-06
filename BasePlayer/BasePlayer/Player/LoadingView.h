//   
//   LoadingView.h
//   BDLive
// 
//   Copyright © 2022 Beijing Volcano Engine Technology Co., Ltd. All rights reserved.
//   


#import <UIKit/UIKit.h>
#import "BDLPlayerConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoadingView : UIView

@property (nonatomic, strong, readonly) UIImageView *imageView;

- (void)showAnimation;
- (void)hideAnimation;

@end

NS_ASSUME_NONNULL_END
