//
//  FloatingPlayer.m
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

#import "FloatingPlayer.h"
#import "LogManager.h"

#import <BDLive/BDLive.h>

/// 父类遵守了 BDLBasePlayerViewDelegate
@interface BDLFloatingPlayer() <BDLBasePlayerViewDelegate>
@end

@implementation FloatingPlayer

- (void)basePlayerViewDidSingleTap:(BDLBasePlayerView *)basePlayerView {
    LogContent(@"纯净播放器单击了");
    [super basePlayerViewDidSingleTap:basePlayerView];
}

- (void)basePlayerViewDidDoubleTap:(BDLBasePlayerView *)basePlayerView {
    LogContent(@"纯净播放器双击了");
    [super basePlayerViewDidDoubleTap:basePlayerView];
}

@end
