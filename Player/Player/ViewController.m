//
//  ViewController.m
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

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import <BDLive/BDLive.h>

@interface ViewController () <BDLPlayerViewDelegate>

@property (nonatomic, strong) BDLPlayerView *playerView;
@property (nonatomic, strong) UIView *playerContainerView;
@property (nonatomic, strong) BDLPlayerFullScreenViewController *fullScreenVC;

@end

@implementation ViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self leaveLiveRoom];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.playerContainerView = [[UIView alloc] init];
    [self.view addSubview:self.playerContainerView];
    [self.playerContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.view);
        }
        make.left.width.equalTo(self.view);
        make.height.mas_equalTo(self.playerContainerView.mas_width).multipliedBy(9.0 / 16.0);
    }];
}

- (void)joinLiveRoom {
    BDLActivity *activity = [[BDLActivity alloc] init];
    activity.activityId = @(1678089977360392);
    activity.token = @"JQCFns";
    activity.authMode = BDLActivityAuthModePublic;
    activity.isPortrait = NO;
    [[BDLLiveEngine sharedInstance] joinLiveRoomWithActivity:activity success:^{
        self.playerView = [[BDLPlayerView alloc] initWithPortrait:activity.isPortrait];
        self.playerView.delegate = self;
        
        self.playerView.config.common.enableFloatingView = NO;
        self.playerView.config.common.enableBackgroundAudio = NO;
        
        self.playerView.controlView.sliderView.thumbView.backgroundColor = [UIColor greenColor];
        self.playerView.controlView.sliderView.backgroundView.backgroundColor = [UIColor redColor];
        self.playerView.controlView.sliderView.cacheProgressView.backgroundColor = [UIColor orangeColor];
        self.playerView.controlView.sliderView.trackProgressView.backgroundColor = [UIColor yellowColor];
        
        [self.playerContainerView addSubview:self.playerView];
        [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.playerContainerView);
        }];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (void)leaveLiveRoom {
    if (self.playerView != nil) {
        [self.playerView stop];
        [self.playerView removeFromSuperview];
        self.playerView = nil;
    }
    [[BDLLiveEngine sharedInstance] leaveLiveRoom];
}

- (IBAction)onPlayButton:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"Play"]) {
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
        [self joinLiveRoom];
    } else {
        [sender setTitle:@"Play" forState:UIControlStateNormal];
        [self leaveLiveRoom];
    }
}

#pragma mark - BDLPlayerViewDelegate

- (void)playerView:(BDLPlayerView *)playerView controlViewIsAppear:(BOOL)isAppear {
    NSLog(@"playerView=%p isAppear=%d", playerView, isAppear);
}

- (void)playerView:(BDLPlayerView *)playerView didFinishPlayingWithIsLive:(BOOL)isLive {
    NSLog(@"playerView=%p isLive=%d", playerView, isLive);
}

- (void)playerView:(BDLPlayerView *)playerView fullScreenButtonDidTouch:(BOOL)isSelected {
    NSLog(@"playerView=%p fullScreenButton.isSelected=%d", playerView, isSelected);
    if (isSelected) {
        self.fullScreenVC = [[BDLPlayerFullScreenViewController alloc] initWithPlayerView:self.playerView];
        
        [self.view bringSubviewToFront:self.playerContainerView];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
        CGFloat angle = M_PI_2;
        if (UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeRight) {
            angle = -M_PI_2;
        }
        [UIView animateWithDuration:0.3 animations: ^{
            [self.playerContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.view);
                make.width.equalTo(self.view.mas_height);
                make.height.equalTo(self.view.mas_width);
            }];
            self.playerContainerView.transform = CGAffineTransformRotate(self.playerContainerView.transform, angle);
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self presentViewController:self.fullScreenVC animated:NO completion:nil];
        }];
    } else {
        [self.playerContainerView addSubview:self.playerView];
        [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.playerContainerView);
        }];

        CGFloat angle = M_PI_2;
        if (UIApplication.sharedApplication.statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
            angle = -M_PI_2;
        }
        self.playerContainerView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle);
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];

        [self.fullScreenVC dismissViewControllerAnimated:NO completion:^{
            [UIView animateWithDuration:0.3
                             animations:^{
                self.playerContainerView.transform = CGAffineTransformIdentity;
                [self.playerContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    if (@available(iOS 11, *)) {
                        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
                    } else {
                        make.top.equalTo(self.view);
                    }
                    make.left.width.equalTo(self.view);
                    make.height.mas_equalTo(self.playerContainerView.mas_width).multipliedBy(9.0 / 16.0);
                }];
                [self.view setNeedsLayout];
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.fullScreenVC = nil;
            }];
        }];
    }
}

- (void)playerView:(BDLPlayerView *)playerView videoSizeDidChange:(CGSize)size {
    NSLog(@"playerView=%p videoSize=%@", playerView, NSStringFromCGSize(size));
}

- (void)playerView:(BDLPlayerView *)playerView coverImageSizeDidChange:(CGSize)size {
    NSLog(@"playerView=%p coverImageSize=%@", playerView, NSStringFromCGSize(size));
}

- (void)playerView:(BDLPlayerView *)playerView maskViewDidTap:(BDLPlayerMaskView *)maskView {
    NSLog(@"playerView=%p maskViewDidTap", playerView);
}

#pragma mark - Orientation

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)onDeviceOrientationDidChange:(NSNotification *)notification {
    UIDeviceOrientation orientation = UIDevice.currentDevice.orientation;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        [self.playerView enterFullScreen];
    } else if (UIDeviceOrientationPortrait == orientation) {
        [self.playerView leaveFullScreen];
    }
}

@end
