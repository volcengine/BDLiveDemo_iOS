//
//  SampleHandler.m
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


#import "SampleHandler.h"
#import <VolcEngineRTCScreenCapturer/ByteRTCScreenCapturerExt.h>

@interface SampleHandler () <ByteRtcScreenCapturerExtDelegate>

@property (nonatomic, assign) BOOL shouldScreenShare;

@end

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // groupId：步骤 4 中选中的 App Group 的 Container ID
    [[ByteRtcScreenCapturerExt shared] startWithDelegate:self groupId:@"<#groupId#>"];
    // 如果主持人在 App 的预览页（即可选择录屏直播的页面）中，屏幕共享扩展将收到 App 发出的 onNotifyAppRunning 回调。如果扩展在 2 秒内没有收到 onNotifyAppRunning 回调，则认为主持人未在 App 的预览页，您应该通过调用 finishBroadcastWithError: 方法停止屏幕采集
    // 按需自定义 NSLocalizedFailureReasonErrorKey 的值
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.shouldScreenShare) {
            NSDictionary *dic = @{
                NSLocalizedFailureReasonErrorKey : @"The host is not in the live room"};
            NSError *error = [NSError errorWithDomain:RPRecordingErrorDomain
                                                 code:RPRecordingErrorUserDeclined
                                             userInfo:dic];
            [self finishBroadcastWithError:error];
        }
    });
}


- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    
    // 混流
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo: // 采集到的屏幕视频流
        case RPSampleBufferTypeAudioApp: // 采集到的设备音频流
            [[ByteRtcScreenCapturerExt shared] processSampleBuffer:sampleBuffer withType:sampleBufferType]; // 使用该方法，将采集到的屏幕视频流和设备音频流推送至观看页
            break;
        case RPSampleBufferTypeAudioMic:
            // 采集到的麦克风音频流
            // 开播 SDK 实现了麦克风音频流的采集并将其推送至观看页。因此，您无需在此处理麦克风音频流
            break;
            
        default:
            break;
    }
}

/// 在主持人停止共享屏幕时触发该回调，通知您停止屏幕采集
- (void)onQuitFromApp {
    // 按需自定义 NSLocalizedFailureReasonErrorKey 的值
    NSDictionary *dic = @{
        NSLocalizedFailureReasonErrorKey : @"You stopped sharing the screen"};
    NSError *error = [NSError errorWithDomain:RPRecordingErrorDomain
                                         code:RPRecordingErrorUserDeclined
                                     userInfo:dic];
    [self finishBroadcastWithError:error];
}


/// App 在后台被终止时触发该回调，通知您停止屏幕采集
- (void)onSocketDisconnect {
    // 按需自定义 NSLocalizedFailureReasonErrorKey 的值
    NSDictionary *dic = @{
        NSLocalizedFailureReasonErrorKey : @"Disconnected"};
    NSError *error = [NSError errorWithDomain:RPRecordingErrorDomain
                                         code:RPRecordingErrorUserDeclined
                                     userInfo:dic];
    [self finishBroadcastWithError:error];
}

/// 检测到 App 正在运行时触发该回调
- (void)onNotifyAppRunning {
    self.shouldScreenShare = YES;
}

@end
