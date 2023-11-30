//   
//   ViewController.m
//   BDLive
// 
//   BDLive SDK License
//   
//   Copyright 2023 Beijing Volcano Engine Technology Ltd. All Rights Reserved.
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
#import "ProductViewController.h"
#import "WebViewController.h"

#import <BDLive/BDLive.h>

@interface ViewController () <BDLLivePullViewControllerDelegate, BDLLivePullViewControllerActionProvider, BDLFloatingPlayerDelegate, BDLLoginProvider>

@property (nonatomic, strong) BDLActivity *activity;
@property (nonatomic, weak) BDLLivePullViewController *livePullViewController;
@property (nonatomic, strong) BDLFloatingPlayer *floatingPlayer;
@property (nonatomic, strong) WebViewController *webViewController;
@property (nonatomic, strong) ProductViewController *productViewController;
@property (nonatomic, assign) BOOL visible;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BDLActivity *activity = [[BDLActivity alloc] init];
    activity.activityId = @(1794755538574419);
    activity.token = @"UoMdEG";
    activity.isPortrait = YES;
    activity.authMode = BDLActivityAuthModePublic;
    self.activity = activity;
    
    [[BDLLiveEngine sharedInstance] setLoginProvider:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.visible = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.visible = NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    // 在 viewDidAppear的时候设置visible为YES，在viewDidDisappear的时候设置visible为NO
    if (!self.visible) { // 不可见的时候保持竖屏，避免侧滑返回异常
        return UIInterfaceOrientationMaskPortrait;
    }
    // 这里以前置页面支持除 UpsideDown 外所有方向为例
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    if (size.width > size.height) { // 横屏
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    else {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
    if (@available(iOS 13, *)) {
        // 这里用self.view.window, ViewController不可见时会返回nil
        orientation = self.navigationController.view.window.windowScene.interfaceOrientation;
    }
    else {
        orientation = UIApplication.sharedApplication.statusBarOrientation;
    }
    if (self.livePullViewController.isFloating) {
        self.livePullViewController.floatingPlayerOrientation = orientation;
    }
    if (self.floatingPlayer) {
        [self.floatingPlayer setUIOrientation:orientation];
    }
}

// MARK: - Full Live Room

- (IBAction)joinRoomAction:(UIButton *)sender {
    if (self.livePullViewController) {
        // 进入完整直播间后, 又返回, 此时显示inAppPiP浮窗, 相当于点击浮窗进入完整直播间
        [self.livePullViewController defaultFloatingPlayerTapAction];
    }
    else if (self.floatingPlayer) {
        // 进入商品VC后展示inAppPiP, 是floatingPlayer正在播放
        [self.floatingPlayer hide];
        // 传递BasePlayerView以便持续播放
        [self getAndShowLivePullVCWithBasePlayer:[self.floatingPlayer removeBasePlayerView]];
        self.floatingPlayer = nil;
    }
    else {
        [self joinAndShowFullLiveRoom];
    }
}

- (void)joinAndShowFullLiveRoom {
    @weakify(self);
    [[BDLLiveEngine sharedInstance] joinLiveRoomWithActivity:self.activity success:^{
        @strongify(self);
        [self getAndShowLivePullVCWithBasePlayer:nil];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"Join live room fail %@", error);
    }];
}

- (void)getAndShowLivePullVCWithBasePlayer:(BDLBasePlayerView * _Nullable)basePlayerView {
    BDLLivePullViewController *livepPullVC = [[BDLLiveEngine sharedInstance] getLivePullViewControllerWithBasePlayerView:basePlayerView];
    livepPullVC.delegate = self;
    livepPullVC.actionProvider = self;
    self.livePullViewController = livepPullVC;
    [self configLivePullViewController:livepPullVC];
    [self showLivePullVC:livepPullVC];
}

- (void)configLivePullViewController:(BDLLivePullViewController *)livepPullVC {
    @weakify(self)
    void (^customizeCommentView)(BDLCommentView *view) = ^(BDLCommentView *view) {
        view.urlClickBlock = ^(__kindof BDLCommentBaseView * _Nonnull commentView, BDLCommentModel * _Nonnull comment, NSURL * _Nonnull url) {
            @strongify(self);
            [self showWebViewControllerWithURL:url];
        };
    };
    // 竖屏评论区
    livepPullVC.config.customizeCommentView = ^(BDLLivePullViewController * _Nonnull viewController, BDLCommentView * _Nonnull view) {
        customizeCommentView(view);
    };
    // 点击置顶评论中的URL
    livepPullVC.config.customizeAlertController = ^__kindof UIViewController * _Nonnull(BDLLivePullViewController * _Nonnull viewController, BDLAlertController * _Nonnull controller) {
        @weakify(controller);
        controller.urlClickBlock = ^(NSURL * _Nonnull url) {
            @strongify(self);
            @strongify(controller);
            [controller dismissAlertControllerAnimated:YES completion:^{
                [self showWebViewControllerWithURL:url];
            }];
        };
        return controller;
    };
    livepPullVC.config.customizeMenuBarView = ^(BDLLivePullViewController * _Nonnull viewController, BDLMenuBarView * _Nonnull view) {
        view.cardViewTappedBlock = ^(NSString * _Nullable urlStr, BOOL enableFloating) {
            // 在这里实现打开商品页面的逻辑
            @strongify(self);
            [self showProductViewController];
        };
        // 横屏评论区
        view.customizeCommentView = ^(BDLMenuBarView * _Nonnull view, BDLCommentView * _Nonnull commentView) {
            customizeCommentView(commentView);
        };

        // 自定义商品卡片高度
        if (view.filterOption & BDLMenuFilterOptionCard) {
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                // 这里更新高度为屏幕高度的3/4
                make.height.mas_equalTo(CGRectGetHeight(UIScreen.mainScreen.bounds) * 3 / 4);
            }];
        }
    };
    livepPullVC.config.shouldShowInAppPipIfAvailable = ^BOOL(BDLLivePullViewController * _Nonnull viewController, BDLActivityStatus status, BOOL isClose) {
        return YES;
    };
    livepPullVC.config.autoCloseFloatingPlayerWhenAppear = YES;
    livepPullVC.onFloatingPlayerCloseTapped = ^BOOL(BDLLivePullViewController * _Nonnull viewController, BDLFloatingPlayer * _Nonnull floatingPlayer) {
        if (viewController.navigationController) {
            // 如果 完整直播间 在 navigationController 里面，则只关闭浮窗
            [viewController hideFloatingPlayerIfAvailable:NO];
            return NO;
        }
        else {
            // 走默认关闭逻辑，即关闭浮窗并退出直播间
            return YES;
        }
    };
    
    // 自定义完整直播间关闭按钮为返回左箭头icon
    livepPullVC.config.customizeCloseButton = ^__kindof UIButton * _Nullable(BDLLivePullViewController * _Nonnull viewController, UIButton * _Nonnull button) {
        // 这里自定义边框并增加圆角
        button.clipsToBounds = YES;
        button.layer.cornerRadius = 3;
        button.layer.borderWidth = 2;
        button.layer.borderColor = UIColor.grayColor.CGColor;
        // 这里自定义了返回按钮icon
        [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        // 这里给返回按钮增加外边距, 使得返回按钮更好点击
        button.contentEdgeInsets = UIEdgeInsetsMake(9, 9, 9, 9);
        return button;
    };
    
    // 自定义完整直播间的约束
    livepPullVC.config.customizeViewConstraints = ^(BDLLivePullViewController * _Nonnull viewController) {
        @strongify(self);
        // 这里只在竖屏模式下自定义返回按钮位置
        if (viewController.isPortrait) {
            // 这里重设一下关闭按钮的约束
            [viewController.closeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(viewController.accountView);
                make.left.mas_equalTo(0);
                make.size.mas_equalTo(40);
            }];
        
            // 这里调整一下主播头像的位置, 避免和返回按钮重合
            [viewController.accountView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(50);
            }];
        }
    };
    
    // 自定义完整直播间中的浮窗
    livepPullVC.config.customFloatingController = ^(BDLLivePullViewController * _Nonnull viewController, BDLFloatingController * _Nonnull floatingController) {
        floatingController.openUrlBlock = ^(BDLFloatingController * _Nonnull floatingController, NSURL * _Nonnull url, BOOL isFloatingEnable) {
            // 在这里实现打开商品页面的逻辑
            @strongify(self);
            [self showWebViewControllerWithURL:url];
        };
        // 自定义互动工具浮窗 这个view涉及拖动，所以设置了view.frame调整其位置，而非自动布局。
        floatingController.customizeInteractiveToolContainerView = ^__kindof UIStackView * _Nullable(BDLFloatingController * _Nonnull floatingController, UIStackView * _Nonnull view) {
            CGRect frame = view.frame;
            frame.origin.y += 50;
            view.frame = frame;
            return view;
        };
    };

    // 配置视频为拉伸充满, 取消注释下面代码
//    BDLLiveRoomConfiguration *config = [[BDLLiveEngine sharedInstance] liveRoomConfiguration];
//    config.playerConfig.common.scalingMode = BDLPlayerScalingModeFill;
    // 配置视频为拉伸充满, 取消注释上面代码

}

- (void)showLivePullVC:(BDLLivePullViewController *)vc {
    if (vc.navigationController) {
        [self.navigationController popToViewController:vc animated:YES];
        return;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

// MARK: - BDLLivePullViewControllerDelegate

- (void)hideLivePullViewController:(BDLLivePullViewController *)livePullVC {
    if (self.navigationController.viewControllers.lastObject == self.livePullViewController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)showLivePullViewController:(BDLLivePullViewController *)livePullVC {
    [self showLivePullVC:livePullVC];
}

- (void)livePullViewControllerWillAppear:(BDLLivePullViewController *)livePullVC {
    self.navigationController.navigationBar.hidden = YES;
}

- (void)livePullViewControllerWillDisappear:(BDLLivePullViewController *)livePullVC {
    self.navigationController.navigationBar.hidden = NO;
}

- (void)livePullViewControllerWillLeaveLiveRoom:(BDLLivePullViewController *)livePullVC {
    self.livePullViewController = nil;
}

// MARK: - Floating Player

- (void)joinAndShowFloatingPlayer {
    @weakify(self);
    [[BDLLiveEngine sharedInstance] joinLiveRoomWithActivity:self.activity success:^{
        @strongify(self);
        [self showFloatingPlayerWithBasePlayerView:nil];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"Join floating player fail %@", error);
    }];
}

- (void)showFloatingPlayerWithBasePlayerView:(BDLBasePlayerView  * _Nullable)basePlayerView {
    if (basePlayerView) {
        self.floatingPlayer = [[BDLFloatingPlayer alloc] initWithPortrait:self.activity.isPortrait basePlayerView:basePlayerView];
    }
    else {
        self.floatingPlayer = [[BDLFloatingPlayer alloc] initWithPortrait:self.activity.isPortrait];
    }
    self.floatingPlayer.delegate = self;
    [self.floatingPlayer showWithCloseButton:YES];
}

// MARK: - BDLFloatingPlayerDelegate

- (void)floatingPlayerDidSingleTap:(BDLFloatingPlayer *)floatingPlayer {
    // Join Full Live Room
    [self.floatingPlayer hide];
    [self getAndShowLivePullVCWithBasePlayer:[self.floatingPlayer removeBasePlayerView]];
    self.floatingPlayer = nil;
}

- (void)floatingPlayerWillClose:(BDLFloatingPlayer *)floatingPlayer {
    // Leave Live Room
    self.floatingPlayer = nil;
    if (!self.livePullViewController) {
        [[BDLLiveEngine sharedInstance] leaveLiveRoom];
    }
}

// MARK: - Product

- (ProductViewController *)productViewController {
    if (!_productViewController) {
        _productViewController = [[ProductViewController alloc] init];
    }
    return _productViewController;
}

- (WebViewController *)webViewController {
    if (!_webViewController) {
        _webViewController = [[WebViewController alloc] init];
    }
    return _webViewController;
}

- (void)showProductViewController {
    if ([self.navigationController.viewControllers containsObject:self.productViewController]) {
        [self.navigationController popToViewController:self.productViewController animated:YES];
        return;
    }
    [self.navigationController pushViewController:self.productViewController animated:YES];
}

- (void)showWebViewControllerWithURL:(NSURL * _Nullable)url {
    if (!url) {
        return;
    }
    [self.webViewController loadURL:url];
    if ([self.navigationController.viewControllers containsObject:self.webViewController]) {
        [self.navigationController popToViewController:self.webViewController animated:YES];
        return;
    }
    [self.navigationController pushViewController:self.webViewController animated:YES];
}

- (IBAction)viewProductAction:(UIButton *)sender {
    [self showProductViewController];
    if (!self.livePullViewController
        && !self.floatingPlayer) {
        // 如果有完整直播间或浮窗播放器, 此时已经在inAppPiP了
        [self joinAndShowFloatingPlayer];
    }
}

// MARK: - BDLLoginProvider

// 如果要体验自定义登录, 取消注释下面的代码
//- (void)loginWithActivity:(BDLActivity *)activity completion:(void (^)(NSString * _Nullable))completion {
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter the token" message:nil preferredStyle:UIAlertControllerStyleAlert];
//    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        textField.placeholder = @"Token";
//    }];
//    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        completion(nil);
//    }]];
//    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        NSString *token = alert.textFields.firstObject.text;
//        completion(token);
//    }]];
//    [self.navigationController presentViewController:alert animated:YES completion:nil];
//}
//
//- (void)loginComplete:(BDLActivity *)activity error:(NSError *)error {
//    if (error) {
//        NSLog(@"Login error:%@", error.localizedDescription);
//    }
//    else {
//        NSLog(@"Login success");
//    }
//}
// 如果要体验自定义登录, 取消注释上面的代码

@end
