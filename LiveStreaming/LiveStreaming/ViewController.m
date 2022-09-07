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

#import <Masonry/Masonry.h>

@interface ViewController () <BDLLiveStreamingControllerDelegate>

@property (nonatomic, strong) UILabel *firstHintLabel;
@property (nonatomic, strong) UILabel *secondHintLabel;
@property (nonatomic, strong) UITextField *firstInputTextField;
@property (nonatomic, strong) UITextField *secondInputTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.firstHintLabel = [[UILabel alloc] init];
    [self.view addSubview:self.firstHintLabel];
    self.firstHintLabel.text = @"ActivityId:";
    self.firstHintLabel.textColor = [UIColor systemGrayColor];
    [self.firstHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(14);
        make.top.equalTo(self.view).offset(200);
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
    
    UIButton *startButton = [[UIButton alloc] init];
    [self.view addSubview:startButton];
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(onEntranceButtonClick) forControlEvents:UIControlEventTouchUpInside];
    startButton.backgroundColor = [UIColor systemBlueColor];
    [startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-40);
        make.width.equalTo(@100);
        make.height.equalTo(@40);
    }];
    
    self.firstInputTextField.text = @"1743097783603240";
    self.secondInputTextField.text = @"5HNQmN+8MeWSvfViCWALWoezCmja10oVCoE1B7jVIujRnBUU378QFXNNnP8nzNx7";
}

- (void)onEntranceButtonClick {
    if (self.firstInputTextField.text.length == 0 ||
        self.secondInputTextField.text.length == 0) {
        return;
    }
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


// MARK: - delegate

- (void)liveStreamingControllerCloseButtonDidClick:(BDLLiveStreamingController *)controller {
    [controller dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
