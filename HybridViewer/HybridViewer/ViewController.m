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
#import <BDLive/BDLLiveEngine.h>
#import <BDLive/BDLLivePullViewController+BDLConfig.h>

@interface ViewController () <BDLLivePullViewControllerDelegate>

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
        [self configLivePullVC:vc];
        [self showLivePullVC:vc];
    } failure:^(NSError * _Nonnull error) {
        self.stateLabel.text = [NSString stringWithFormat:@"Join live room fail %@", error];
    }];
    
}

- (void)configLivePullVC:(BDLLivePullViewController *)vc {
    vc.config.customizePageAdView = ^__kindof BDLBaseView * _Nullable(BDLLivePullViewController * _Nonnull viewController, BDLPageAdView * _Nonnull view) {
        if (viewController.isPortrait) {
            return view;
        }
        // hide adView when landscape
        return nil;
    };
    
    vc.config.customizeViewConstraints = ^(BDLLivePullViewController * _Nonnull viewController) {
        UIView *testView = [[UIView alloc] init];
        if (viewController.isPortrait) {
            if (viewController.upperAdView) {
                [viewController.view insertSubview:testView belowSubview:viewController.upperAdView];
            }
            else {
                [viewController.view addSubview:testView];
            }
        }
        else {
            if (viewController.upperAdView) {
                [viewController.contentView insertSubview:testView belowSubview:viewController.upperAdView];
            }
            else {
                [viewController.contentView addSubview:testView];
            }
        }
        testView.backgroundColor = [UIColor redColor];
        
        if (viewController.isPortrait) {
            [testView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(viewController.commentView.mas_top).offset(-10);
                make.left.right.equalTo(viewController.view).inset(14);
                make.height.equalTo(@60);
            }];
        }
        else {
            if (!viewController.pageAdView) {
                return;
            }
            [testView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(viewController.pageAdView);
            }];
        }
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
