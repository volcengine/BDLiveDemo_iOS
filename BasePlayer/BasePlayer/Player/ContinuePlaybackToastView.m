//   
//   ContinuePlaybackToastView.m
//   BDLive
// 
//   BDLive SDK License
//   
//   Copyright 2022 Beijing Volcano Engine Technology Ltd. All Rights Reserved.
//   
//   The BDLive SDK was developed by Beijing Volcanoengine Technology Ltd. (hereinafter “Volcano Engine”). Any copyright or patent right is owned by and proprietary material of the Volcano Engine. 
//   
//   BDLive SDK is available under the VolcLive product and licensed under the commercial license.  Customers can contact service@volcengine.com for commercial licensing options.  Here is also a link to subscription services agreement: https://www.volcengine.com/docs/6256/68938.
//   
//   Without Volcanoengine's prior written permission, any use of BDLive SDK, in particular any use for commercial purposes, is prohibited. This includes, without limitation, incorporation in a commercial product, use in a commercial service, or production of other artefacts for commercial purposes. 
//   
//   Without Volcanoengine's prior written permission, the BDLive SDK may not be reproduced, modified and/or made available in any form to any third party. 
//   


#import "ContinuePlaybackToastView.h"

#import <Masonry/Masonry.h>

@implementation ContinuePlaybackToastView

- (instancetype)initWithPlaybackTime:(NSTimeInterval)time {
    self = [super init];
    if (self) {
        [self setupViewsWithTime:time];
        [self setupConstraints];
    }
    return self;
}

- (void)setupViewsWithTime:(NSTimeInterval)time {
    self.backgroundColor = UIColor.blackColor;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 4;

    self.label = [[UILabel alloc] init];
    self.label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:11];
    self.label.textColor = UIColor.whiteColor;
    NSInteger playbackTime = time;
    NSInteger hours = playbackTime / 3600;
    playbackTime %= 3600;
    NSInteger minutes = playbackTime / 60;
    playbackTime %= 60;
    NSInteger seconds = playbackTime;
    if (time > 3600) {
        self.label.text = [NSString stringWithFormat:@" 已为您定位至 %02ld:%02ld:%02ld ", hours, minutes, seconds];
    } else {
        self.label.text = [NSString stringWithFormat:@" 已为您定位至 %02ld:%02ld ", minutes, seconds];
    }
    [self addSubview:self.label];
}

- (void)setupConstraints {
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).inset(4);
    }];
}

@end
