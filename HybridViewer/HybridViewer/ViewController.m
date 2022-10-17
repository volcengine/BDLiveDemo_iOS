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

@interface ViewController () <BDLLivePullViewControllerDelegate>

@property (nonatomic, weak) BDLLivePullViewController *livePullViewController;
@property (nonatomic, weak) IBOutlet UITextField *activityIdTF;
@property (nonatomic, weak) IBOutlet UITextField *tokenTF;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic, weak) IBOutlet UILabel *stateLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)onGoHybridVC:(UIButton *)btn {
    [self.view endEditing:YES];
    long long activityId = [self.activityIdTF.text longLongValue];
    NSString *token = self.tokenTF.text;
    
    if (activityId <= 0
        || token.length == 0) {
        self.stateLabel.text = @"activityId or token invalid";
        return;
    }
    self.stateLabel.text = nil;
    
    BDLActivity *activity = [[BDLActivity alloc] init];
    activity.activityId = @(activityId);
    activity.token = token;
    activity.authMode = BDLActivityAuthModePublic;
    activity.isPortrait = self.segmentControl.selectedSegmentIndex == 1;
    
    [[BDLLiveEngine sharedInstance] joinLiveRoomWithActivity:activity success:^{
        BDLLivePullViewController *vc = [[BDLLiveEngine sharedInstance] getLivePullViewController];
        self.livePullViewController = vc;
        [self configLivePullVC:vc];
        [self showLivePullVC:vc];
    } failure:^(NSError * _Nonnull error) {
        self.stateLabel.text = [NSString stringWithFormat:@"Join live room fail %@", error];
    }];
    
}

- (void)onShareButtonClick:(UIButton *)button {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"自定义分享实现" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
    }]];
    [self.livePullViewController presentViewController:alert animated:YES completion:^{
            
    }];
}

- (void)onTopButtonClick:(UIButton *)button {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"点击了顶部View" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
    }]];
    [self.livePullViewController presentViewController:alert animated:YES completion:^{
            
    }];
}

- (void)configLivePullVC:(BDLLivePullViewController *)vc {
    // 自定义关闭按钮
    vc.config.customizeCloseButton = ^__kindof UIButton * _Nullable(BDLLivePullViewController * _Nonnull viewController, UIButton * _Nonnull button) {
        if (!viewController.isPortrait) {
            // 修改图片
            [button setImage:[UIImage imageNamed:@"leftArrow"] forState:UIControlStateNormal];
        }
        return button;
    };
    
    // 隐藏标题
    vc.config.customizeTitleLabel = ^__kindof UILabel * _Nullable(BDLLivePullViewController * _Nonnull viewController, UILabel * _Nonnull label) {
        return nil;
    };
    
    // 隐藏企业账号的view
    vc.config.customizeAccountView = ^__kindof BDLBaseView * _Nullable(BDLLivePullViewController * _Nonnull viewController, BDLBusinessAccountView * _Nonnull view) {
        return nil;
    };
    
    // 自定义分享按钮，需要在控制台配置分享按钮为显示 （营销互动/分享海报/直播分享）
    vc.config.customizeShareButton = ^__kindof UIButton * _Nullable(BDLLivePullViewController * _Nonnull viewController, UIButton * _Nonnull button) {
        // 修改图片
        // [button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        // 修改背景颜色
        button.backgroundColor = [UIColor grayColor];
    
        // 移除默认的分享实现
         NSArray *actionArray = [button actionsForTarget:viewController forControlEvent:UIControlEventTouchUpInside];
         for (NSString *action in actionArray) {
             [button removeTarget:viewController action:NSSelectorFromString(action) forControlEvents:UIControlEventTouchUpInside];
         }
        // 添加自定义分享的实现
        [button addTarget:self action:@selector(onShareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        return button;
    };
    
    // 自定义页中广告
    vc.config.customizePageAdView = ^__kindof BDLBaseView * _Nullable(BDLLivePullViewController * _Nonnull viewController, BDLPageAdView * _Nonnull view) {
        // 隐藏横屏时候的页中广告
        if (viewController.isPortrait) {
            return view;
        }
        return nil;
    };

    // 自定义布局/添加自己的view
    // NOTE: 因为有视频全屏/非全屏的切换，这里不支持自定义 playerContainerView/playerView 的位置
    vc.config.customizeViewConstraints = ^(BDLLivePullViewController * _Nonnull viewController) {
        // 只在横屏模式下自定义，竖屏不做处理
        if (viewController.isPortrait) {
            return;
        }
        // 顶部居中添加view
        UIButton *topButton = [[UIButton alloc] init];
        topButton.layer.cornerRadius = 15;
        topButton.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.5];
        [topButton addTarget:self action:@selector(onTopButtonClick:) forControlEvents:UIControlEventTouchUpInside];

        // 视频下方添加自定义view
        UIView *middleView = [[UIView alloc] init];
        middleView.backgroundColor = [UIColor redColor];
        middleView.alpha = 0.2;
        
        // 置于浮窗广告之下，避免浮窗广告被自定义view遮挡
        if (viewController.upperAdView) {
            [viewController.contentView insertSubview:topButton belowSubview:viewController.upperAdView];
            [viewController.contentView insertSubview:middleView belowSubview:viewController.upperAdView];
        }
        else {
            [viewController.contentView addSubview:topButton];
            [viewController.contentView addSubview:middleView];
        }
       
        [topButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@200);
            make.height.equalTo(@30);
            make.centerY.equalTo(viewController.closeButton);
            make.centerX.equalTo(viewController.view);
        }];
    
        [middleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(viewController.playerContainerView.mas_bottom).offset(10);
            make.left.right.equalTo(viewController.contentView);
            make.height.equalTo(@30);
        }];
        
        // 调整 直播间描述的位置
        [viewController.liveDescriptionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(middleView.mas_bottom).offset(10);
            make.left.right.equalTo(viewController.contentView);
            make.height.equalTo(@17);
        }];
    };
}

- (void)showLivePullVC:(BDLLivePullViewController *)vc {
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.delegate = self;
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)hideLivePullVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BDLLivePullViewControllerDelegate

- (void)livePullViewControllerCloseButtonDidClick:(BDLLivePullViewController *)livePullVC isFloating:(BOOL)isFloating {
    [self hideLivePullVC];
}

- (void)livePullViewController:(BDLLivePullViewController *)livePullVC floatingPlayerViewDidTap:(BDLPlayerView *)playerView {
    [self showLivePullVC:livePullVC];
}

- (void)livePullViewControllerWillLeaveLiveRoom:(BDLLivePullViewController *)livePullVC {
}

@end
