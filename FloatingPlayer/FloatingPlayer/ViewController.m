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
#import <YYCategories/YYCategories.h>

@interface ViewController () <BDLLivePullViewControllerDelegate, BDLLivePullViewControllerActionProvider, BDLFloatingPlayerDelegate>

@property (nonatomic, strong) BDLActivity *activity;
@property (nonatomic, strong) BDLFloatingPlayer *floatingPlayer;
@property (nonatomic, strong) BDLLivePullViewController *livePullVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.activity = [[BDLActivity alloc] init];
    self.activity.activityId = @(1678089977360392);
    self.activity.token = @"JQCFns";
    self.activity.authMode = BDLActivityAuthModePublic;
    self.activity.isPortrait = YES;
}

- (IBAction)onFloatingPlayerButton:(UIButton *)sender {
    [self leaveLiveRoom];
    [[BDLLiveEngine sharedInstance] joinLiveRoomWithActivity:self.activity success:^{
        [self showFloatingPlayer:self.activity.isPortrait];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (IBAction)onLiveRoomButton:(UIButton *)sender {
    [self hideFloatingPlayer];
    [self joinLiveRoom];
}

#pragma mark - FloatingPlayer

- (void)showFloatingPlayer:(BOOL)isPortrait {
    self.floatingPlayer = [[BDLFloatingPlayer alloc] initWithPortrait:isPortrait];
    self.floatingPlayer.delegate = self;
    [self.floatingPlayer showWithCloseButton:YES];
}

- (void)hideFloatingPlayer {
    if (self.floatingPlayer != nil) {
        [self.floatingPlayer hide];
        [self.floatingPlayer.basePlayerView removeFromSuperview];
        self.floatingPlayer = nil;
    }
}

#pragma mark - LiveRoom

- (void)joinLiveRoom {
    [[BDLLiveEngine sharedInstance] joinLiveRoomWithActivity:self.activity success:^{
        self.livePullVC = [[BDLLiveEngine sharedInstance] getLivePullViewController];
        self.livePullVC.delegate = self;
        self.livePullVC.actionProvider = self;
        [self configLivePullVC];
        [self showLivePullVC];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (void)leaveLiveRoom {
    [self.livePullVC close:NO];
    self.livePullVC = nil;
}

- (void)configLivePullVC {
    @weakify(self);
    self.livePullVC.config.customizeMenuBarView = ^(BDLLivePullViewController * _Nonnull viewController, BDLMenuBarView * _Nonnull view) {
        view.customizeCardView = ^__kindof BDLBaseView * _Nullable(BDLMenuBarView * _Nonnull view, BDLCardView * _Nonnull cardView) {
            cardView.viewTappedBlock = ^(NSString * _Nullable urlStr, BOOL enableFloating) {
                @strongify(self);
                if (!self) {
                    return;
                }
                [self.livePullVC close:YES];
            };
            return cardView;
        };
    };
    
    self.livePullVC.config.customFloatingController = ^(BDLLivePullViewController * _Nonnull viewController, BDLFloatingController * _Nonnull floatingController) {
        floatingController.customizeFloatingCardView = ^__kindof BDLBaseView * _Nullable(BDLFloatingController * _Nonnull floatingController, BDLFloatingCardView * _Nonnull view) {
            view.viewTappedBlock = ^(NSString * _Nullable urlStr, BOOL enableFloating) {
                @strongify(self);
                if (!self) {
                    return;
                }
                [self.livePullVC close:YES];
            };
            return view;
        };
        
        floatingController.customizeUpperAdView = ^__kindof BDLBaseView * _Nullable(BDLFloatingController * _Nonnull floatingController, BDLUpperAdView * _Nonnull view) {
            view.viewTappedBlock = ^(NSString * _Nullable urlStr, BOOL enableFloating) {
                @strongify(self);
                if (!self) {
                    return;
                }
                [self.livePullVC close:YES];
            };
            return view;
        };
    };
    
    self.livePullVC.config.customizeViewConstraints = ^(BDLLivePullViewController * _Nonnull viewController) {
        @strongify(self);
        if (!self) {
            return;
        }
        if (self.livePullVC.isPortrait) {
            [viewController.pageAdView mas_remakeConstraints:^(MASConstraintMaker *make) {
                // 自定义位置及大小
                make.left.mas_equalTo(50);
                make.top.mas_equalTo(100);
                make.size.mas_equalTo(CGSizeMake(200, 100));
            }];
        }
    };
}

- (void)showLivePullVC {
    self.livePullVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.livePullVC animated:NO completion:nil];
}

- (void)hideLivePullVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BDLLivePullViewControllerDelegate

- (void)livePullViewControllerWillLeaveLiveRoom: ( BDLLivePullViewController *)livePullVC {
    self.livePullVC = nil;
}

#pragma mark - BDLLivePullViewControllerActionProvider

- (void)showLivePullViewController:(BDLLivePullViewController *)livePullVC {
    [self showLivePullVC];
}

- (void)hideLivePullViewController:(BDLLivePullViewController *)livePullVC {
    [self hideLivePullVC];
}

// MARK: - BDLFloatingPlayerDelegate

- (void)floatingPlayerWillAppear:(BDLFloatingPlayer *)floatingPlayer {
    NSLog(@"floatingPlayer(%p) will appear", floatingPlayer);
}

- (void)floatingPlayerDidDisappear:(BDLFloatingPlayer *)floatingPlayer {
    NSLog(@"floatingPlayer(%p) did disappear", floatingPlayer);
}

- (void)floatingPlayerDidSingleTap:(BDLFloatingPlayer *)floatingPlayer {
    NSLog(@"floatingPlayer(%p) did tap", floatingPlayer);
    [self hideFloatingPlayer];
    [[BDLLiveEngine sharedInstance] leaveLiveRoom];
    [self joinLiveRoom];
}

- (void)floatingPlayerDidDoubleTap:(BDLFloatingPlayer *)floatingPlayer {
    NSLog(@"floatingPlayer(%p) did double tap", floatingPlayer);
    [floatingPlayer.basePlayerView pause];
}

- (void)floatingPlayerWillClose:(BDLFloatingPlayer *)floatingPlayer {
    NSLog(@"floatingPlayer(%p) close", floatingPlayer);
    [self hideFloatingPlayer];
    [[BDLLiveEngine sharedInstance] leaveLiveRoom];
}

@end
