//
//  LivePullViewController.m
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

#import "LivePullViewController.h"
#import "PlayerView.h"
#import <BDLive/BDLive.h>
#import "LogManager.h"
#import "PlayerFullScreenViewController.h"
#import "FloatingPlayer.h"

@interface LivePullViewController () <BDLFloatingPlayerDelegate, PlayerViewDelegate>

@property (nonatomic, weak) id<BDLActivityService> svc;

@property (nonatomic, strong) UIButton *logButton;
@property (nonatomic, strong) UIView *playerContainerView;
@property (nonatomic, strong) PlayerView *playerView;

@property (nonatomic, strong) FloatingPlayer *floatingPlayer;

@property (nonatomic, strong) BDLCommentView *commentView;
/// 公开模式需要registerController处理注册逻辑
@property (nonatomic, strong) BDLRegisterController *registerController;

@property (nonatomic, strong) PlayerFullScreenViewController *fullScreenVC;
@property (nonatomic, assign) CGRect playerFrameBeforeFullScreen;

@end

@implementation LivePullViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    [self setupBDLive];
    [self setupViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.logButton.selected) {
        [[LogManager sharedInstance] showLogView];
    }
}
- (void)dealloc {
    [[LogManager sharedInstance] hideLogView];
    NSLog(@"LivePullViewController dealloc");
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (void)setupBDLive {
    // 设置注册，用于公开模式时候注册弹窗显示
    [self.svc getRegisterController].popupSuperView = self.view;
}

- (void)setupViews {
    UIButton *closeButton = [[UIButton alloc] init];
    [self.view addSubview:closeButton];
    [closeButton addTarget:self action:@selector(onCloseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    closeButton.backgroundColor = [UIColor lightGrayColor];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.width.equalTo(@50);
        make.height.equalTo(@40);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.view);
        }
    }];
    
    UIButton *closeWithFloatingWindowBtn = [[UIButton alloc] init];
    [self.view addSubview:closeWithFloatingWindowBtn];
    [closeWithFloatingWindowBtn addTarget:self action:@selector(onCloseWithFloatingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [closeWithFloatingWindowBtn setTitle:@"显示浮窗" forState:UIControlStateNormal];
    closeWithFloatingWindowBtn.backgroundColor = [UIColor lightGrayColor];
    [closeWithFloatingWindowBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [closeWithFloatingWindowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(closeButton.mas_right).offset(20);
        make.top.equalTo(closeButton);
        make.width.equalTo(@50);
        make.height.equalTo(@40);
    }];
    
    UIButton *videoListBtn = [[UIButton alloc] init];
    [self.view addSubview:videoListBtn];
    [videoListBtn addTarget:self action:@selector(onVideoListButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    videoListBtn.backgroundColor = [UIColor lightGrayColor];
    [videoListBtn setTitle:@"多线路" forState:UIControlStateNormal];
    [videoListBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [videoListBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(closeWithFloatingWindowBtn.mas_right).offset(20);
        make.top.equalTo(closeButton);
        make.width.equalTo(@50);
        make.height.equalTo(@40);
    }];
    
    UIButton *logButton = [[UIButton alloc] init];
    [self.view addSubview:logButton];
    self.logButton = logButton;
    [logButton addTarget:self action:@selector(onLogButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    logButton.backgroundColor = [UIColor lightGrayColor];
    [logButton setTitle:@"开启log" forState:UIControlStateNormal];
    [logButton setTitle:@"关闭log" forState:UIControlStateSelected];
    [logButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [logButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(videoListBtn.mas_right).offset(20);
        make.top.equalTo(closeButton);
        make.width.equalTo(@50);
        make.height.equalTo(@40);
    }];
    
    self.commentView = [[BDLCommentView alloc] initWithPortrait:NO];
    [self.view addSubview:self.commentView];
    self.commentView.popupSuperView = self.view;
    [self.commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(closeButton.mas_bottom).offset(20);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@300);
    }];
    
    self.playerContainerView = [[UIView alloc] init];
    [self.view addSubview:self.playerContainerView];
    [self.playerContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.commentView.mas_bottom).offset(20);
        make.left.right.equalTo(self.view);
        make.height.equalTo(self.playerContainerView.mas_width).multipliedBy(9.0 / 16);
    }];
    
    self.playerView = [[PlayerView alloc] init];
    [self.playerContainerView addSubview:self.playerView];
    self.playerView.popupSuperView = self.view;
    self.playerView.delegate = self;
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.playerContainerView);
    }];
}

- (void)showSelf {
    if ([self.actionProvider respondsToSelector:@selector(showLivePullViewController:)]) {
        [self.actionProvider showLivePullViewController:self];
    }
}

- (void)hideSelf {
    if ([self.actionProvider respondsToSelector:@selector(hideLivePullViewController:)]) {
        [self.actionProvider hideLivePullViewController:self];
    }
}

// MARK: - action
- (void)onLogButtonClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        [[LogManager sharedInstance] showLogView];
    }
    else {
        [[LogManager sharedInstance] hideLogView];
    }
}

- (void)onCloseButtonClicked:(UIButton *)btn {
    [self hideSelf];
    if ([self.actionProvider respondsToSelector:@selector(livePullViewControllerWillLeaveLiveRoom:)]) {
        [self.actionProvider livePullViewControllerWillLeaveLiveRoom:self];
    }
}

- (void)onCloseWithFloatingButtonClicked:(UIButton *)btn {
    if (![self.playerView canFloating] || [self.floatingPlayer isFloating]) {
        return;
    }
    
    [self hideSelf];
    
    self.floatingPlayer = [[FloatingPlayer alloc] initWithPortrait:NO basePlayerView:self.playerView.basePlayerView];
    self.floatingPlayer.delegate = self;
    self.playerView.basePlayerView.userInteractionEnabled = NO;
    self.floatingPlayer.basePlayerView.userInteractionEnabled = YES;
    [self.floatingPlayer showWithFrame:CGRectMake(10, 100, 160, 90) closeButton:YES];
}

- (void)onVideoListButtonClick:(UIButton *)btn {
    BDLActivityModel *activityModel = [self.svc getActivityModel];
    BDLBasicModel *basicModel = activityModel.basic;
    __weak typeof(self) weakSelf = self;
    NSMutableArray *actionArray = [NSMutableArray array];
    
    if (basicModel.status == BDLActivityStatusLive) { // 直播从 activityModel.pullStreamUrls 获取直播多线路列表
        NSInteger index = 0;
        for (BDLPullStreamUrlModel *pullStreamUrlModel in activityModel.pullStreamUrls) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:pullStreamUrlModel.lineName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf.svc changeCurrentPlayingMediaToIndex:index];
            }];
            [actionArray addObject:action];
            index ++;
        }
    }
    else if (basicModel.status == BDLActivityStatusReplay) { // 点播从 basicModel.replays 获取回放列表
        NSInteger index = 0;
        for (BDLReplayModel *replayModel in basicModel.replays) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:replayModel.name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf.svc changeCurrentPlayingMediaToIndex:index];
            }];
            [actionArray addObject:action];
            index ++;
        }
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"多线路" message:nil preferredStyle:UIAlertControllerStyleAlert];
    for (UIAlertAction *action in actionArray) {
        [alert addAction:action];
    }
    if (actionArray.count > 1) { // 添加 上一个/下一个
        NSUInteger totalCount = actionArray.count;
        UIAlertAction *nextAction = [UIAlertAction actionWithTitle:@"下一个" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSUInteger index = [weakSelf.svc getCurrentMediaIndex];
            NSUInteger nextIndex = index + 1;
            if (nextIndex >= totalCount) {
                nextIndex = 0;
            }
            [weakSelf.svc changeCurrentPlayingMediaToIndex:nextIndex];
        }];
        [alert addAction:nextAction];
        
        UIAlertAction *prevAction = [UIAlertAction actionWithTitle:@"上一个" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSUInteger index = [weakSelf.svc getCurrentMediaIndex];
            NSUInteger prevIndex = 0;
            if (index == 0) {
                prevIndex = totalCount - 1;
            }
            else {
                prevIndex = index - 1;
            }
            [weakSelf.svc changeCurrentPlayingMediaToIndex:prevIndex];
        }];
        [alert addAction:prevAction];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// MARK: - BDLFloatingPlayerDelegate

- (void)floatingPlayerDidSingleTap:(BDLFloatingPlayer *)floatingPlayer {
    if (![floatingPlayer isFloating]) {
        return;
    }
    [self showSelf];
    [self.playerView addBasePlayerView:[self.floatingPlayer removeBasePlayerView]];
    [self.floatingPlayer hide];
    self.floatingPlayer = nil;
}

- (void)floatingPlayerWillClose:(BDLFloatingPlayer *)floatingPlayer {
    if ([self.actionProvider respondsToSelector:@selector(livePullViewControllerWillLeaveLiveRoom:)]) {
        [self.actionProvider livePullViewControllerWillLeaveLiveRoom:self];
    }
}

// MARK: - PlayerViewDelegate

- (void)playerView:(PlayerView *)playerView fullScreenButtonDidTouch:(BOOL)isSelected {
    if (isSelected) {
        self.playerView.basePlayerView.watermarkView.hidden = NO;
        self.fullScreenVC = [[PlayerFullScreenViewController alloc] initWithView:self.playerView];
        
        self.playerContainerView.layer.zPosition = 100;
        [self.playerContainerView setNeedsLayout];
        [self.playerContainerView layoutIfNeeded];
        self.playerView.popupSuperView = self.fullScreenVC.view;
        
        self.playerFrameBeforeFullScreen = [self.playerView convertRect:self.playerView.basePlayerView.frame toView:self.view];
        CGFloat angle = M_PI_2;
        if (UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeRight) {
            angle = -M_PI_2;
        }
        self.fullScreenVC.view.backgroundColor = [UIColor clearColor];
        [UIView animateWithDuration:0.3 animations: ^{
            CGSize portraitSize = [UIScreen mainScreen].bounds.size;
            if (portraitSize.width > portraitSize.height) {
                portraitSize = CGSizeMake(portraitSize.height, portraitSize.width);
            }
            [self.playerContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view.mas_centerX);
                make.centerY.equalTo(self.view.mas_centerY);
                make.width.mas_equalTo(portraitSize.height);
                make.height.mas_equalTo(portraitSize.width);
            }];
            self.playerContainerView.transform = CGAffineTransformRotate(self.playerView.transform, angle);
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self presentViewController:self.fullScreenVC animated:NO completion:^{
                [CATransaction begin];
                [CATransaction setDisableActions:YES];

                [self.playerView updatePlayerWhenLeaveFullScreen];
                self.playerView.basePlayerView.transform = CGAffineTransformIdentity;
                [self.playerView setNeedsLayout];
                [self.playerView layoutIfNeeded];

                [CATransaction commit];
                self.fullScreenVC.view.backgroundColor = [UIColor blackColor];

            }];
        }];
    } else {
        self.playerView.popupSuperView = self.view;
        CGFloat angle = M_PI_2;
        if (UIApplication.sharedApplication.statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
            angle = -M_PI_2;
        }
        [self.playerContainerView addSubview:self.playerView];
        [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.playerContainerView);
        }];
        
        self.playerContainerView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle);
        [self.playerContainerView setNeedsLayout];
        [self.playerContainerView layoutIfNeeded];
        [self.fullScreenVC dismissViewControllerAnimated:NO
                                              completion:^{
            [UIView animateWithDuration:0.3
                             animations:^{
                self.playerContainerView.transform = CGAffineTransformIdentity;
                [self.playerContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.equalTo(self.view);
                    make.height.equalTo(self.playerContainerView.mas_width).multipliedBy(9/16.0);
                    make.top.equalTo(self.commentView.mas_bottom).offset(20);
                }];
                [self.view setNeedsLayout];
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.playerView.basePlayerView.watermarkView.hidden = YES;
                
                self.playerContainerView.layer.zPosition = 0;
                self.fullScreenVC = nil;
                
            }];
        }];
    }
}

// MARK: - lazy

- (id<BDLActivityService>)svc {
    if (!_svc) {
        _svc = [[BDLLiveEngine sharedInstance] getActivityService];
    }
    return _svc;
}

@end
