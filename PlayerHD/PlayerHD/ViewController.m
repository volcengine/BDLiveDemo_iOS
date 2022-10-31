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
#import "ContentViewController.h"

@interface ViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *firstHintLabel;
@property (nonatomic, strong) UILabel *secondHintLabel;
@property (nonatomic, strong) UITextField *firstInputTextField;
@property (nonatomic, strong) UITextField *secondInputTextField;

@property (nonatomic, strong) NSMutableArray *buttonArray;

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
        make.top.equalTo(self.view).offset(130);
        make.width.equalTo(@80);
        make.height.equalTo(@40);
    }];
    
    self.secondHintLabel = [[UILabel alloc] init];
    [self.view addSubview:self.secondHintLabel];
    self.secondHintLabel.text = @"Token";
    self.secondHintLabel.textColor = [UIColor systemGrayColor];
    [self.secondHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(14);
        make.top.equalTo(self.firstHintLabel.mas_bottom).offset(40);
        make.width.equalTo(@80);
        make.height.equalTo(@40);
    }];
    
    self.firstInputTextField = [[UITextField alloc] init];
    [self.view addSubview:self.firstInputTextField];
    self.firstInputTextField.text = @"1678089977360392";
    self.firstInputTextField.layer.borderColor = [UIColor systemGrayColor].CGColor;
    self.firstInputTextField.layer.borderWidth = 1;
    self.firstInputTextField.delegate = self;
    [self.firstInputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.firstHintLabel.mas_right).offset(10);
        make.right.equalTo(self.view).offset(-14);
        make.centerY.equalTo(self.firstHintLabel);
        make.height.equalTo(@40);
    }];
    
    self.secondInputTextField = [[UITextField alloc] init];
    [self.view addSubview:self.secondInputTextField];
    self.secondInputTextField.text = @"JQCFns";
    self.secondInputTextField.layer.borderColor = [UIColor systemGrayColor].CGColor;
    self.secondInputTextField.layer.borderWidth = 1;
    self.secondInputTextField.delegate = self;
    [self.secondInputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.secondHintLabel.mas_right).offset(10);
        make.right.equalTo(self.view).offset(-14);
        make.centerY.equalTo(self.secondHintLabel);
        make.height.equalTo(@40);
    }];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.secondInputTextField.mas_bottom).offset(40);
        make.bottom.equalTo(self.view).offset(-100);
    }];
    
    NSDictionary *dict = @{
        @(ContentViewPlayerShowModeMiddleUp) : @"宽边占满+居中偏上",
        @(ContentViewPlayerShowModeTopFix) : @"宽边占满+吸顶",
        @(ContentViewPlayerShowModeMiddleUpWithMargin) : @"宽边离两侧一定距离+居中模式",
        @(ContentViewPlayerShowModeLeft) : @"整体偏左侧",
        @(ContentViewPlayerShowModeTopLeft) : @"靠左位置+吸顶",
        @(ContentViewPlayerShowModeLeftCenter) : @"靠左位置+垂直居中",
    };
    
    CGFloat left = 30;
    UILabel *hintLabel = [[UILabel alloc] init];
    [scrollView addSubview:hintLabel];
    hintLabel.textColor = [UIColor systemGrayColor];
    hintLabel.text = @"竖屏";
    [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(left);
        make.top.equalTo(scrollView).offset(20);
        make.height.equalTo(@40);
    }];
    
    self.buttonArray = [NSMutableArray array];
    UIView *upperView = hintLabel;
    UIButton * (^ createButton)(NSNumber *key, UIView *upperView) = ^(NSNumber *key, UIView *upperView) {
        UIButton *button = [[UIButton alloc] init];
        [scrollView addSubview:button];
        [self.buttonArray addObject:button];
        button.tag = [key integerValue];
        [button setTitle:dict[key] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor systemGrayColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onItemButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(upperView);
            make.top.equalTo(upperView.mas_bottom).offset(10);
            //            make.width.equalTo(@100);
            make.right.equalTo(self.view).offset(- left);
            make.height.equalTo(@40);
            make.bottom.lessThanOrEqualTo(scrollView).offset(-20);
        }];
        return button;
    };
    
    for (NSNumber *key in @[@(ContentViewPlayerShowModeMiddleUp),
                            @(ContentViewPlayerShowModeTopFix),
                            @(ContentViewPlayerShowModeMiddleUpWithMargin),
                            @(ContentViewPlayerShowModeLeft)]) {
        upperView = createButton(key, upperView);
    }
    
    hintLabel = [[UILabel alloc] init];
    [scrollView addSubview:hintLabel];
    hintLabel.textColor = [UIColor systemGrayColor];
    hintLabel.text = @"横屏";
    [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(left);
        make.top.equalTo(upperView.mas_bottom).offset(20);
        make.height.equalTo(@40);
    }];
    
    upperView = hintLabel;
    
    for (NSNumber *key in @[@(ContentViewPlayerShowModeTopLeft),
                            @(ContentViewPlayerShowModeLeftCenter)]) {
        upperView = createButton(key, upperView);
    }
    
    UIButton *startButton = [[UIButton alloc] init];
    [self.view addSubview:startButton];
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(onEntranceButtonClick) forControlEvents:UIControlEventTouchUpInside];
    startButton.backgroundColor = [UIColor systemBlueColor];
    [startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(scrollView.mas_bottom).offset(20);
        make.width.equalTo(@100);
        make.height.equalTo(@40);
    }];
    
    [self onItemButtonClick:self.buttonArray.firstObject];
}

- (void)onItemButtonClick:(UIButton *)button {
    for (UIButton *btn in self.buttonArray) {
        btn.selected = NO;
    }
    button.selected = YES;
}

- (void)onEntranceButtonClick {
    if (self.firstInputTextField.text.length == 0 ||
        self.secondInputTextField.text.length == 0) {
        return;
    }
    BDLActivity *activity = [[BDLActivity alloc] init];
    activity.activityId = @([self.firstInputTextField.text longLongValue]);
    activity.token = self.secondInputTextField.text;
    activity.authMode = BDLActivityAuthModePublic;
    activity.isPortrait = NO;
    
    [[BDLLiveEngine sharedInstance] joinLiveRoomWithActivity:activity success:^{
        UIButton *selectedButton = nil;
        for (UIButton *button in self.buttonArray) {
            if (button.selected) {
                selectedButton = button;
                break;
            }
        }
        if (!selectedButton) {
            return;
        }
        ContentViewController *vc = [[ContentViewController alloc] initWithActivity:activity mode:selectedButton.tag];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:^{
                    
        }];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

//- (BOOL)shouldAutorotate {
//    return NO;
//}
//
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

// MARK: - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

@end
