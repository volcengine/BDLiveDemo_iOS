//
//  ContentViewController.m
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

#import "ContentViewController.h"
#import "PlayerFullScreenViewController.h"

#import <BDLive/BDLive.h>

@interface ContentViewController () <BDLPlayerViewDelegate>

@property (nonatomic, strong) BDLActivity *activity;
@property (nonatomic, assign) ContentViewPlayerShowMode mode;
@property (nonatomic, strong) UIView *playerContainerView;
@property (nonatomic, strong) BDLPlayerView *playerView;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) PlayerFullScreenViewController *fullScreenVC;
@property (nonatomic, copy) void(^playerContainerViewConstrains)(MASConstraintMaker *make);

@end

@implementation ContentViewController

- (instancetype)initWithActivity:(BDLActivity *)activity mode:(ContentViewPlayerShowMode)mode {
    if (self = [super init]) {
        self.activity = activity;
        self.mode = mode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.137 green:0.137 blue:0.137 alpha:1];
    
    self.playerContainerView = [[UIView alloc] init];
    [self.view addSubview:self.playerContainerView];
    __weak typeof(self) weakSelf = self;
    switch (self.mode) {
        case ContentViewPlayerShowModeMiddleUp: {
            self.playerContainerViewConstrains = ^(MASConstraintMaker *make) {
                make.centerY.equalTo(weakSelf.view).offset(-100);
                make.left.right.equalTo(weakSelf.view);
                make.height.equalTo(weakSelf.view.mas_width).multipliedBy(9 / 16.0);
            };
        }
            break;
        case ContentViewPlayerShowModeTopFix: {
            self.playerContainerViewConstrains = ^(MASConstraintMaker *make) {
                if (@available(iOS 11, *)) {
                    make.top.equalTo(weakSelf.view.mas_safeAreaLayoutGuideTop);
                }
                else {
                    make.top.equalTo(weakSelf.view);
                }
                make.left.right.equalTo(weakSelf.view);
                make.height.equalTo(weakSelf.view.mas_width).multipliedBy(9 / 16.0);
            };
        }
            break;
        case ContentViewPlayerShowModeMiddleUpWithMargin: {
            self.playerContainerViewConstrains = ^(MASConstraintMaker *make) {
                make.centerY.equalTo(weakSelf.view).offset(-100);
                make.left.right.equalTo(weakSelf.view).inset(40);
                make.height.equalTo(weakSelf.view.mas_width).multipliedBy(9 / 16.0);
            };
        }
            break;
        case ContentViewPlayerShowModeLeft: {
            self.playerContainerViewConstrains = ^(MASConstraintMaker *make) {
                if (@available(iOS 11, *)) {
                    make.top.equalTo(weakSelf.view.mas_safeAreaLayoutGuideTop);
                }
                else {
                    make.top.equalTo(weakSelf.view);
                }
                make.left.equalTo(weakSelf.view);
                make.width.equalTo(weakSelf.view.mas_width).dividedBy(1.5);
                make.height.equalTo(weakSelf.view.mas_width).multipliedBy(9 / 16.0 / 1.5);
            };
        }
            break;
        case ContentViewPlayerShowModeTopLeft: {
            self.playerContainerViewConstrains = ^(MASConstraintMaker *make) {
                if (@available(iOS 11, *)) {
                    make.top.equalTo(weakSelf.view.mas_safeAreaLayoutGuideTop);
                }
                else {
                    make.top.equalTo(weakSelf.view);
                }
                make.left.equalTo(weakSelf.view);
                make.width.equalTo(weakSelf.view.mas_width).dividedBy(1.5);
                make.height.equalTo(weakSelf.view.mas_width).multipliedBy(9 / 16.0 / 1.5);
            };
        }
            break;
        case ContentViewPlayerShowModeLeftCenter: {
            self.playerContainerViewConstrains = ^(MASConstraintMaker *make) {
                make.centerY.equalTo(weakSelf.view);
                make.left.equalTo(weakSelf.view);
                make.width.equalTo(weakSelf.view.mas_width).dividedBy(1.5);
                make.height.equalTo(weakSelf.view.mas_width).multipliedBy(9 / 16.0 / 1.5);
            };
        }
            break;
    }
    
    [self.playerContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        self.playerContainerViewConstrains(make);
    }];
    
    self.playerView = [[BDLPlayerView alloc] initWithPortrait:self.activity.isPortrait];
    self.playerView.delegate = self;
 
    [self.playerContainerView addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.playerContainerView);
    }];
    
    UIButton *closeButton = [[UIButton alloc] init];
    [self.view addSubview:closeButton];
    self.closeButton = closeButton;
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(onCloseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.view);
        make.height.equalTo(@44);
        make.width.equalTo(@60);
    }];
}

- (void)onCloseButtonClick {
    [self.playerView stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([self isPortrait]) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)isPortrait {
    return self.mode <= ContentViewPlayerShowModePortraitEnd;
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
        self.fullScreenVC = [[PlayerFullScreenViewController alloc] initWithView:self.playerView];
        if ([self isPortrait]) {
            self.fullScreenVC.orientation = UIInterfaceOrientationPortrait;
        }
        else {
            self.fullScreenVC.orientation = UIInterfaceOrientationLandscapeRight;
        }
        
        [self.view bringSubviewToFront:self.playerContainerView];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.3 animations: ^{
            [self.playerContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self presentViewController:self.fullScreenVC animated:NO completion:nil];
        }];
    } else {
        [self.view bringSubviewToFront:self.closeButton];
        [self.playerContainerView addSubview:self.playerView];
        [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.playerContainerView);
        }];
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];

        [self.fullScreenVC dismissViewControllerAnimated:NO completion:^{
            [UIView animateWithDuration:0.3
                             animations:^{
                [self.playerContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    self.playerContainerViewConstrains(make);
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

@end
