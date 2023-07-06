//
//  LogManager.m
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

#import "LogManager.h"
#import <UIKit/UIKit.h>
#import <BDLive/BDLive.h>

@interface LogManager ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *clearButton;

@end

@implementation LogManager

+ (instancetype)sharedInstance {
    static LogManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LogManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, size.height / 3.0, size.width * 2 / 3, 400)];
        [[UIApplication sharedApplication].delegate.window addSubview:self.contentView];
        self.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.contentView.hidden = YES;
        self.contentView.bdl_draggingMode = BDLDraggingModePullOver;
        
        self.clearButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.frame) - 40, 0, 40, 20)];
        [self.contentView addSubview:self.clearButton];
        [self.contentView addSubview:self.clearButton];
        [self.clearButton setTitle:@"Clear Log" forState:UIControlStateNormal];
        self.clearButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.clearButton addTarget:self action:@selector(onClearButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame) - 20)];
        [self.contentView addSubview:self.textView];
        self.textView.editable = NO;
        self.textView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.textView.textColor = [UIColor whiteColor];
    }
    return self;
}

- (void)showLogView {
    self.contentView.hidden = NO;
    [self.contentView.superview bringSubviewToFront:self.contentView];
}

- (void)hideLogView {
    self.contentView.hidden = YES;
}

- (void)onClearButtonClick {
    self.textView.attributedText = nil;
}

- (void)log:(NSString *)funcInfo content:(NSString *)content {
    NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] init];
    if (self.textView.attributedText.length > 0) {
        [aStr appendAttributedString:self.textView.attributedText];
        [aStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"----------\n" attributes:@{
            NSForegroundColorAttributeName : [[UIColor whiteColor] colorWithAlphaComponent:0.6]
        }] ];
    }
    
    [aStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@\n", funcInfo, content] attributes:@{
        NSForegroundColorAttributeName : [UIColor whiteColor]
    }]];
    
    self.textView.attributedText = aStr;
}

@end
