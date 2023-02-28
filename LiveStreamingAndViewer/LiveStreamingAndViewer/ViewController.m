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

#import <BDLive/BDLLiveStreaming.h>
#import <BDLive/BDLLiveEngine.h>
#import <Masonry/Masonry.h>

@interface ViewController () <BDLLiveStreamingControllerDelegate>

@property (nonatomic, strong) UILabel *firstHintLabel;
@property (nonatomic, strong) UILabel *secondHintLabel;
@property (nonatomic, strong) UITextField *firstInputTextField;
@property (nonatomic, strong) UITextField *secondInputTextField;

@property (nonatomic, strong) UISegmentedControl *typeControl;
@property (nonatomic, strong) UISegmentedControl *viewerDirectionControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.typeControl = [[UISegmentedControl alloc] initWithItems:@[@"LiveStreaming", @"Viewer"]];
    [self.view addSubview:self.typeControl];
    [self.typeControl addTarget:self action:@selector(onTypeSegmentControlClick) forControlEvents:UIControlEventValueChanged];
    [self.typeControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(130);
        make.width.equalTo(@200);
    }];
    
    self.firstHintLabel = [[UILabel alloc] init];
    [self.view addSubview:self.firstHintLabel];
    self.firstHintLabel.text = @"ActivityId:";
    self.firstHintLabel.textColor = [UIColor systemGrayColor];
    [self.firstHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(14);
        make.top.equalTo(self.typeControl.mas_bottom).offset(50);
        make.width.equalTo(@80);
    }];
    
    self.secondHintLabel = [[UILabel alloc] init];
    [self.view addSubview:self.secondHintLabel];
    self.secondHintLabel.text = @"secretKey";
    self.secondHintLabel.textColor = [UIColor systemGrayColor];
    [self.secondHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(14);
        make.top.equalTo(self.firstHintLabel.mas_bottom).offset(40);
        make.width.equalTo(@80);
    }];
    
    self.firstInputTextField = [[UITextField alloc] init];
    [self.view addSubview:self.firstInputTextField];
    self.firstInputTextField.layer.borderColor = [UIColor systemGrayColor].CGColor;
    self.firstInputTextField.layer.borderWidth = 1;
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
    [self.secondInputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.secondHintLabel.mas_right).offset(10);
        make.right.equalTo(self.view).offset(-14);
        make.centerY.equalTo(self.secondHintLabel);
        make.height.equalTo(@40);
    }];
    
    self.viewerDirectionControl = [[UISegmentedControl alloc] initWithItems:@[@"horizontal", @"portrait"]];
    [self.view addSubview:self.viewerDirectionControl];
    [self.viewerDirectionControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.secondHintLabel.mas_bottom).offset(40);
        make.width.equalTo(@200);
    }];
    
    UIButton *startButton = [[UIButton alloc] init];
    [self.view addSubview:startButton];
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(onEntranceButtonClick) forControlEvents:UIControlEventTouchUpInside];
    startButton.backgroundColor = [UIColor systemBlueColor];
    [startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(40);
        make.width.equalTo(@100);
        make.height.equalTo(@40);
    }];
    
    self.typeControl.selectedSegmentIndex = 0;
    self.viewerDirectionControl.selectedSegmentIndex = 0;
    [self onTypeSegmentControlClick];
}

- (void)onEntranceButtonClick {
    if (self.firstInputTextField.text.length == 0 ||
        self.secondInputTextField.text.length == 0) {
        return;
    }
    if (self.typeControl.selectedSegmentIndex == 0) { // LiveStreaming
        [[BDLLiveStreaming sharedInstance] joinLiveStreamingWithActivityId:@([self.firstInputTextField.text longLongValue]) secretKey:self.secondInputTextField.text success:^{
            BDLLiveStreamingController *liveStreamingVC = [[BDLLiveStreaming sharedInstance] getLiveStreamingController];
            liveStreamingVC.modalPresentationStyle = UIModalPresentationFullScreen;
            liveStreamingVC.delegate = self;
            [self presentViewController:liveStreamingVC animated:YES completion:^{
                
            }];
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"join fail: %@", error.localizedDescription);
        }];
    }
    else { // Viewer
        BDLActivity *activity = [[BDLActivity alloc] init];
        activity.activityId = @([self.firstInputTextField.text longLongValue]);
        activity.token = self.secondInputTextField.text;
        activity.authMode = BDLActivityAuthModePublic;
        activity.isPortrait = self.viewerDirectionControl.selectedSegmentIndex == 1;

        [[BDLLiveEngine sharedInstance] joinLiveRoomWithActivity:activity];
    }
}

- (void)onTypeSegmentControlClick {
    if (self.typeControl.selectedSegmentIndex == 0) {
        self.viewerDirectionControl.hidden = YES;
        self.secondHintLabel.text = @"SecretKey";
        self.firstInputTextField.text = @"";
        self.secondInputTextField.text = @"";
    }
    else {
        self.viewerDirectionControl.hidden = NO;
        self.secondHintLabel.text = @"Token";
        self.firstInputTextField.text = @"1678089977360392";
        self.secondInputTextField.text = @"JQCFns";
    }
}

// MARK: - delegate

- (void)liveStreamingControllerCloseButtonDidClick:(BDLLiveStreamingController *)controller {
    [controller dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
