//
//  ViewController.m
//   BDLive
//
//   BDLive SDK License
//
//   Copyright 2022 Beijing Volcano Engine Technology Ltd. All Rights Reserved.
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

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import <BDLive/BDLive.h>

@interface ViewController () <BDLPlayerViewDelegate, BDLLoginProvider>

@property (nonatomic, strong) BDLPlayerView *playerView;
@property (nonatomic, strong) UIView *playerContainerView;
@property (nonatomic, strong) BDLPlayerFullScreenViewController *fullScreenVC;

#if __has_include(<BDLive/BDLAudienceLinkController.h>)

@property (nonatomic, strong) UIButton *cancelAudienceLinkButton;

@property (nonatomic, strong) BDLAudienceLinkController *audienceLinkController;
@property (nonatomic, weak) BDLAudienceLinkEntranceView *audienceLinkEntranceView;
@property (nonatomic, weak) BDLAudienceLinkPreviewView *audienceLinkPreviewView;
@property (nonatomic, weak) BDLAudienceLinkRemoteContainerView *audienceLinkRemoteContainerView;

#endif

@end

@implementation ViewController

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
    activity.activityId = @(1794755538574419);
    activity.token = @"UoMdEG";
    activity.authMode = BDLActivityAuthModePublic;
    
    activity.isPortrait = NO;
    // 组件接入连麦，公开模式，需要实现登录逻辑
    [[BDLLiveEngine sharedInstance] setLoginProvider:self];
    [[BDLLiveEngine sharedInstance] joinLiveRoomWithActivity:activity success:^{
        self.playerView = [[BDLPlayerView alloc] initWithPortrait:activity.isPortrait];
        self.playerView.delegate = self;
        if (@available(iOS 14.0, *)) {
            self.playerView.config.common.enableVodPiP = NO;
            self.playerView.config.common.enableLivePiP = NO;
        }
        self.playerView.config.common.enableBackgroundAudio = NO;
        
        self.playerView.controlView.sliderView.thumbView.backgroundColor = [UIColor greenColor];
        self.playerView.controlView.sliderView.backgroundView.backgroundColor = [UIColor redColor];
        self.playerView.controlView.sliderView.cacheProgressView.backgroundColor = [UIColor orangeColor];
        self.playerView.controlView.sliderView.trackProgressView.backgroundColor = [UIColor yellowColor];
        
        [self.playerContainerView addSubview:self.playerView];
        [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.playerContainerView);
        }];
        [self setupAudienceLink];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (void)leaveLiveRoom {
    void(^leave)(void) = ^ {
        
        if (self.playerView != nil) {
            [self.playerView stop];
            [self.playerView removeFromSuperview];
            self.playerView = nil;
        }
        [[BDLLiveEngine sharedInstance] leaveLiveRoom];
        
#if __has_include(<BDLive/BDLAudienceLinkController.h>)
        [self.audienceLinkEntranceView removeFromSuperview];
        [self.audienceLinkPreviewView removeFromSuperview];
        [self.audienceLinkRemoteContainerView removeFromSuperview];
        
        self.audienceLinkEntranceView = nil;
        self.audienceLinkPreviewView = nil;
        self.audienceLinkRemoteContainerView = nil;
        self.audienceLinkController = nil;
#endif
    };
    
#if __has_include(<BDLive/BDLAudienceLinkController.h>)
    BDLAudienceLinkState state = [self.audienceLinkController getCurrentAudienceLinkState];
    if (state == BDLAudienceLinkStateLinked) {
        BDLAudienceLinkExitWarningView *view = [[BDLAudienceLinkExitWarningView alloc] init];
        [view bottomShowInView:self.view completion:^(BDLPopupBaseView * _Nonnull view) {
                    
        }];
        view.onConfirmClickCallback = ^(BDLAudienceLinkExitWarningView * _Nonnull view, UIButton * _Nonnull button) {
            [self.audienceLinkController cancelAudienceLink:^{
                [view hideWithCompletion:nil];
                leave();
            }];
        };
        view.onCancelClickCallback = ^(BDLAudienceLinkExitWarningView * _Nonnull view, UIButton * _Nonnull button) {
            [view hideWithCompletion:nil];
        };
        view.onBackgroundTapCallback = ^(BDLPopupBaseView * _Nonnull view) {
            [view hideWithCompletion:nil];
        };
    }
    else if (state != BDLAudienceLinkStateUnknown
             && state != BDLAudienceLinkStateUnlinked) { // 此时应该是处于，发起了连麦申请，但是主持人还未同意的状态，需要 取消连麦
        [self.audienceLinkController cancelAudienceLink:^{
            leave();
        }];
    }
    else {
        leave();
    }
#else
    leave();
#endif
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

/// 连麦组件接入相关逻辑
- (void)setupAudienceLink {
#if __has_include(<BDLive/BDLAudienceLinkController.h>)
    
    [[[BDLLiveEngine sharedInstance] getActivityService] getRegisterController].popupSuperView = self.view;
    // 初始化连麦 Controller，需要在进房成功后进行。
    self.audienceLinkController = [[BDLAudienceLinkController alloc] init];
    // 设置弹窗的父 View
    self.audienceLinkController.popupSuperView = self.view;
    // 本地预览画面显示在连麦房间画面中。
    self.audienceLinkController.showSelfVideoInRemoteView = YES;
    
    __weak typeof(self) weakSelf = self;
    // 设置 显示连麦入口的回调
    // Demo这里显示在 self.view 的左上了
    self.audienceLinkController.showEntranceViewBlock = ^(BDLAudienceLinkController * _Nonnull audienceLinkController, BDLAudienceLinkEntranceView * _Nonnull view, BOOL isFromEnableChange) {
        weakSelf.audienceLinkEntranceView = view;
        [weakSelf.view addSubview:view];
        // 是否来自连麦开关变化，如果是，则有个出现动画（非必须）
        if (isFromEnableChange) {
            view.frame = CGRectMake(-64, 100, 64, 64);
            [UIView animateWithDuration:0.3 animations:^{
                view.frame = CGRectMake(10, 100, 64, 64);
            }];
        }
    };
    // 设置 隐藏连麦入口 的回调
    self.audienceLinkController.hideEntranceViewBlock = ^(BDLAudienceLinkController * _Nonnull audienceLinkController, BDLAudienceLinkEntranceView * _Nonnull view) {
        weakSelf.audienceLinkEntranceView = nil;
        [view removeFromSuperview];
    };
    // 设置 显示本地预览 的回调
    self.audienceLinkController.showPreviewViewBlock = ^(BDLAudienceLinkController * _Nonnull audienceLinkController, BDLAudienceLinkPreviewView * _Nonnull previewView, double aspectRatio) {
        weakSelf.audienceLinkPreviewView = previewView;
        [weakSelf.view addSubview:previewView];
        [previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.view).offset(10);
            make.width.equalTo(@300);
            make.height.equalTo(previewView.mas_width).dividedBy(aspectRatio ?: 1);
            make.top.equalTo(weakSelf.view.mas_safeAreaLayoutGuideTop).offset(100);
        }];
    };
    // 设置 隐藏本地预览 的回调
    self.audienceLinkController.hidePreviewViewBlock = ^(BDLAudienceLinkController * _Nonnull audienceLinkController, BDLAudienceLinkPreviewView * _Nonnull previewView) {
        weakSelf.audienceLinkPreviewView = previewView;
        [previewView removeFromSuperview];
    };
    // 设置 显示连麦房间画面 的回调
    self.audienceLinkController.showRemoteContainerViewBlock = ^(BDLAudienceLinkController * _Nonnull audienceLinkController, BDLAudienceLinkRemoteContainerView * _Nonnull remoteContainerView) {
        weakSelf.audienceLinkRemoteContainerView = remoteContainerView;
        [weakSelf.view addSubview:remoteContainerView];
        [remoteContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(weakSelf.view);
            make.height.equalTo(remoteContainerView.mas_width).multipliedBy(9/16.0);
            make.top.equalTo(weakSelf.view.mas_safeAreaLayoutGuideTop).offset(250);
        }];
        // 隐藏播放器画面并停止播放
        weakSelf.playerView.hidden = YES;
        weakSelf.playerView.basePlayerView.forbidPlay = YES;
        // 设置videoView点击回调（非必须，如果不需响应用户点击连麦画面则无需赋值）
        remoteContainerView.onUserVideoClickBlock = ^(BDLAudienceLinkRemoteContainerView * _Nonnull containerView, BDLAudienceLinkLayoutUser * _Nonnull user, BOOL isSelf) {
            NSLog(@"点击了用户画面 \n user:【%p】isSelf:【%d】", user, isSelf);
        };
    };
    // 设置 隐藏连麦房间画面 的回调
    self.audienceLinkController.hideRemoteContainerViewBlock = ^(BDLAudienceLinkController * _Nonnull audienceLinkController, BDLAudienceLinkRemoteContainerView * _Nonnull remoteContainerView) {
        weakSelf.playerView.basePlayerView.forbidPlay = NO;
        weakSelf.playerView.hidden = NO;
        weakSelf.audienceLinkRemoteContainerView = nil;
        [remoteContainerView removeFromSuperview];
    };
    
    self.audienceLinkController.onAudienceLinkStateChangeBlock = ^(BDLAudienceLinkController * _Nonnull audienceLinkController, BDLAudienceLinkState state) {
        if (state == BDLAudienceLinkStateLinked) {
            if (!weakSelf.cancelAudienceLinkButton) {
                weakSelf.cancelAudienceLinkButton = [[UIButton alloc] initWithFrame:CGRectMake(300, 80, 44, 44)];
                [weakSelf.cancelAudienceLinkButton setTitle:@"取消连麦" forState:UIControlStateNormal];
                weakSelf.cancelAudienceLinkButton.backgroundColor = [UIColor grayColor];
                [weakSelf.cancelAudienceLinkButton addTarget:weakSelf action:@selector(onCancelAudienceClick) forControlEvents:UIControlEventTouchUpInside];
            }
            [weakSelf.view addSubview:weakSelf.cancelAudienceLinkButton];
        }
        else {
            [weakSelf.cancelAudienceLinkButton removeFromSuperview];
        }
    };
#endif
}

- (void)onCancelAudienceClick {
#if __has_include(<BDLive/BDLAudienceLinkController.h>)
    [self.audienceLinkController cancelAudienceLink:^{
        NSLog(@"取消连麦");
    }];
#endif
}

- (void)loginWithActivity:(BDLActivity *)activity completion:(void (^)(NSString * _Nullable))completion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入Token" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"这里输入自定义登录token";
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completion(alert.textFields.firstObject.text);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completion(nil);
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loginComplete:(BDLActivity *)activity error:(NSError *)error {
    NSLog(@"组定义登录结果 error:【%@】", error);
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
        self.fullScreenVC = [[BDLPlayerFullScreenViewController alloc] initWithView:self.playerView];
        
        [self.view bringSubviewToFront:self.playerContainerView];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
        CGFloat angle = M_PI_2;
        if (UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeRight) {
            angle = -M_PI_2;
        }
        self.fullScreenVC.view.backgroundColor = [UIColor clearColor];
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
            self.fullScreenVC.view.backgroundColor = [UIColor blackColor];
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
