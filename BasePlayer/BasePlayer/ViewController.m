//
//  ViewController.m
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

#import "ViewController.h"
#import <BDLive/BDLive.h>
#import "LivePullViewController.h"

@interface ViewController () <LivePullViewControllerActionProvider>

@property (nonatomic, strong) UILabel *firstHintLabel;
@property (nonatomic, strong) UILabel *secondHintLabel;
@property (nonatomic, strong) UITextField *firstInputTextField;
@property (nonatomic, strong) UITextField *secondInputTextField;

@property (nonatomic, strong) UIButton *startButton;

@property (nonatomic, strong) LivePullViewController *livePullViewController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.firstHintLabel = [[UILabel alloc] init];
    [self.view addSubview:self.firstHintLabel];
    self.firstHintLabel.text = @"ActivityId:";
    self.firstHintLabel.textColor = [UIColor systemGrayColor];
    [self.firstHintLabel setAdjustsFontSizeToFitWidth:80];
    [self.firstHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(14);
        make.top.equalTo(self.view).offset(200);
        make.width.equalTo(@80);
    }];
    
    self.secondHintLabel = [[UILabel alloc] init];
    [self.view addSubview:self.secondHintLabel];
    self.secondHintLabel.text = @"SecretKey:";
    self.secondHintLabel.textColor = [UIColor systemGrayColor];
    [self.secondHintLabel setAdjustsFontSizeToFitWidth:80];
    [self.secondHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(14);
        make.top.equalTo(self.firstHintLabel.mas_bottom).offset(40);
        make.width.equalTo(@80);
    }];
    
    self.firstInputTextField = [[UITextField alloc] init];
    [self.view addSubview:self.firstInputTextField];
    self.firstInputTextField.layer.borderColor = [UIColor systemGrayColor].CGColor;
    self.firstInputTextField.layer.borderWidth = 1;
    self.firstInputTextField.text = @"1794755538574419";
    [self.firstInputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.firstHintLabel.mas_right).offset(10);
        make.right.equalTo(self.view).offset(-14);
        make.centerY.equalTo(self.firstHintLabel);
        make.height.equalTo(@40);
    }];
    
    self.secondInputTextField = [[UITextField alloc] init];
    [self.view addSubview:self.secondInputTextField];
    self.secondInputTextField.layer.borderColor = [UIColor systemGrayColor].CGColor;
    self.secondInputTextField.layer.borderWidth = 1;
    self.secondInputTextField.text = @"UoMdEG";
    [self.secondInputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.secondHintLabel.mas_right).offset(10);
        make.right.equalTo(self.view).offset(-14);
        make.centerY.equalTo(self.secondHintLabel);
        make.height.equalTo(@40);
    }];
    
    self.startButton = [[UIButton alloc] init];
    [self.view addSubview:self.startButton];
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.startButton setTitle:@"Loading" forState:UIControlStateSelected];
    [self.startButton addTarget:self action:@selector(onStartButton:) forControlEvents:UIControlEventTouchUpInside];
    self.startButton.backgroundColor = [UIColor grayColor];
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.secondInputTextField.mas_bottom).offset(40);
        make.width.equalTo(@100);
        make.height.equalTo(@44);
    }];
}

- (void)joinLiveRoom {
    if (self.firstInputTextField.text.length == 0 || self.secondInputTextField.text.length == 0) {
        self.startButton.selected = NO;
        return;
    }
    BDLActivity *activity = [[BDLActivity alloc] init];
    activity.activityId = @([self.firstInputTextField.text integerValue]);
    activity.token = self.secondInputTextField.text;
    activity.authMode = BDLActivityAuthModePublic;
    activity.isPortrait = NO;
    [[BDLLiveEngine sharedInstance] joinLiveRoomWithActivity:activity success:^{
        self.startButton.selected = NO;
        
        self.livePullViewController = [[LivePullViewController alloc] init];
        self.livePullViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        self.livePullViewController.actionProvider = self;
        [self presentViewController:self.livePullViewController animated:YES completion:nil];
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
        self.startButton.selected = NO;
    }];
}

- (IBAction)onStartButton:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    sender.selected = YES;
    [self joinLiveRoom];
}

// MARK: - LivePullViewControllerActionProvider

- (void)showLivePullViewController:(LivePullViewController *)livePullVC {
    [self presentViewController:livePullVC animated:YES completion:nil];
}

- (void)hideLivePullViewController:(LivePullViewController *)livePullVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)livePullViewControllerWillLeaveLiveRoom:(BDLLivePullViewController *)livePullVC {
    self.livePullViewController = nil;
}

@end
