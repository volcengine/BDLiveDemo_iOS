//
//  LivePullViewController.h
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

NS_ASSUME_NONNULL_BEGIN

@class LivePullViewController;
@protocol LivePullViewControllerActionProvider <NSObject>

- (void)showLivePullViewController:(LivePullViewController *)livePullVC;

- (void)hideLivePullViewController:(LivePullViewController *)livePullVC;
- (void)livePullViewControllerWillLeaveLiveRoom:(LivePullViewController *)livePullVC;

@end

@interface LivePullViewController : UIViewController

@property (nonatomic, weak) id<LivePullViewControllerActionProvider> actionProvider;

@end

NS_ASSUME_NONNULL_END
