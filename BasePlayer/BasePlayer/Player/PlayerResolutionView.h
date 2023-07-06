//   
//   PlayerResolutionView.h
//   BDLive
// 
//   Copyright © 2022 Beijing Volcano Engine Technology Co., Ltd. All rights reserved.
//   


#import "BDLPopupBaseView.h"
#import <BDLive/BDLive.h>

NS_ASSUME_NONNULL_BEGIN

@class PlayerResolutionView;

@protocol PlayerResolutionViewDelegate <NSObject>

- (void)resolutionView:(PlayerResolutionView *)resolutionView resolutionDidChange:(BDLVideoResolution)resolution;

@end

@interface PlayerResolutionView : BDLPopupBottomOrRightShowBaseView

@property (nonatomic, weak) id<PlayerResolutionViewDelegate> delegate;

@property (nonatomic, assign) BOOL fullScreen;

- (void)updateWithResolutions:(NSArray<NSNumber *> *)resolutions currentResolution:(BDLVideoResolution)currentResolution;
- (void)changeResolutionSuccess:(BOOL)success completeResolution:(BDLVideoResolution)completeResolution;

@end

NS_ASSUME_NONNULL_END
