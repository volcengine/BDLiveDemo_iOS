//   
//   PlayerSpeedView.m
//   BDLive
// 
//   Copyright © 2022 Beijing Volcano Engine Technology Co., Ltd. All rights reserved.
//   


#import <Masonry/Masonry.h>

#import "PlayerSpeedView.h"
#import "BDLActivityService.h"
#import "Utils.h"

@interface PlayerSpeedView ()

@property (nonatomic, strong, nullable) UILabel *titleLabel;
@property (nonatomic, strong) UIView *buttonContainerView;
@property (nonatomic, strong, nullable) UIButton *cancelButton;
@property (nonatomic, strong, nullable) UIView *lineView;

@property (nonatomic, copy) NSArray<UIButton *> *buttonArray;

@property (nonatomic, assign) BDLLanguageType langType;

@property (nonatomic, assign) BOOL isFullScreen;

@end

@implementation PlayerSpeedView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupViews {
    self.contentView.backgroundColor = [Utils colorWithHexString:@"#202124"];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
    self.titleLabel.textColor = [Utils colorWithHexString:@"#A6A6A7"];
    [self.contentView addSubview:self.titleLabel];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [Utils colorWithHexString:@"#343434"];
    [self.contentView addSubview:self.lineView];
    
    self.buttonContainerView = [[UIView alloc] init];
    [self.contentView addSubview:self.buttonContainerView];
    
    NSMutableArray<UIButton *> *buttons = [[NSMutableArray alloc] initWithCapacity:6];
    NSArray *titles = @[@"2.0X", @"1.5X", @"1.25X", @"1.0X", @"0.75X", @"0.5X"];
    for (NSUInteger i = 0; i < titles.count; ++i) {
        UIButton *btn = [[UIButton alloc] init];
        [self.buttonContainerView addSubview:btn];
        btn.tag = i;
        [btn setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onSpeedButton:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 4;
        btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
        btn.backgroundColor = [Utils colorWithHexString:@"#2C2D30"];
        [btn setTitleColor:[Utils colorWithHexString:@"#757577"] forState:UIControlStateNormal];
        [btn setTitleColor:[Utils colorWithHexString:@"#4086FF"] forState:UIControlStateSelected];
        [buttons addObject:btn];
    }
    self.buttonArray = buttons;
    
    self.cancelButton = [[UIButton alloc] init];
    self.cancelButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    [self.cancelButton setTitleColor:[Utils colorWithHexString:@"#A6A6A7"] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(onCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.cancelButton];
}

- (void)setupConstraints {
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(16);
        make.height.equalTo(@22);
    }];
    
    [self.buttonContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(20);
    }];
    
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.cancelButton];
    
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.buttonContainerView.mas_bottom).offset(24);
        make.height.equalTo(@1);
    }];
    
    [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.height.equalTo(@54);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.contentView.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.contentView);
        }
        make.top.equalTo(self.lineView.mas_bottom);
    }];
    
    NSUInteger i = 0;
    UIButton *prevButton = nil;
    for (UIButton *btn in self.buttonArray) {
        [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (i % 3 == 0) {
                make.left.equalTo(self.buttonContainerView);
                if (prevButton) {
                    make.top.equalTo(prevButton.mas_bottom).offset(18);
                }
                else {
                    make.top.equalTo(self.buttonContainerView);
                }
            }
            else {
                make.left.equalTo(prevButton.mas_right).offset(20);
                make.top.equalTo(prevButton);
            }
            make.width.equalTo(@90);
            make.height.equalTo(@44);
            make.bottom.right.lessThanOrEqualTo(self.buttonContainerView);
        }];
        prevButton = btn;
        i ++;
    }
}

- (void)setupFullScreenConstraints {
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.width.equalTo(@268);
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.top.equalTo(self.contentView).offset(20);
        make.height.equalTo(@22);
    }];
    
    [self.buttonContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
    }];
    
    [self.lineView removeFromSuperview];
    [self.cancelButton removeFromSuperview];
    
    NSUInteger i = 0;
    UIButton *prevButton = nil;
    for (UIButton *btn in self.buttonArray) {
        [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (i % 3 == 0) {
                make.left.equalTo(self.buttonContainerView);
                if (prevButton) {
                    make.top.equalTo(prevButton.mas_bottom).offset(16);
                }
                else {
                    make.top.equalTo(self.buttonContainerView);
                }
            }
            else {
                make.left.equalTo(prevButton.mas_right).offset(16);
                make.top.equalTo(prevButton);
            }
            make.width.equalTo(@64);
            make.height.equalTo(@44);
            make.bottom.right.lessThanOrEqualTo(self.buttonContainerView);
        }];
        prevButton = btn;
        i ++;
    }
}

- (void)onCancelButton:(UIButton *)sender {
    [self hideWithCompletion:nil];
}

- (void)setFullScreen:(BOOL)fullScreen {
    if (_fullScreen == fullScreen) {
        return;
    }
    _fullScreen = fullScreen;
    if (fullScreen) {
        self.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        for (UIButton *button in self.buttonArray) {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[Utils colorWithHexString:@"#94C2FF"] forState:UIControlStateSelected];
        }
        [self setupFullScreenConstraints];
        
    }
    else {
        self.contentView.backgroundColor = [Utils colorWithHexString:@"#202124"];
        for (UIButton *button in self.buttonArray) {
            [button setTitleColor:[Utils colorWithHexString:@"#757577"] forState:UIControlStateNormal];
            [button setTitleColor:[Utils colorWithHexString:@"#4086FF"] forState:UIControlStateSelected];
        }
        [self setupConstraints];
    }
}

- (void)onSpeedButton:(UIButton *)sender {
    PlayerSpeed speed = sender.tag;
    [self selectSpeedButtonWithIndex:sender.tag];
    
    [self hideWithCompletion:nil];
    
    if ([self.delegate respondsToSelector:@selector(speedView:speedDidChange:)]) {
        [self.delegate speedView:self speedDidChange:speed];
    }
}

- (void)selectSpeedButtonWithIndex:(NSUInteger)index {
    for (NSUInteger i = 0; i < self.buttonArray.count; ++i) {
        UIButton *btn = self.buttonArray[i];
        if (i == index) {
            btn.selected = YES;
            btn.backgroundColor = [[Utils colorWithHexString:@"#4086FF"] colorWithAlphaComponent:0.2];
        } else {
            btn.selected = NO;
            btn.backgroundColor = [Utils colorWithHexString:@"#2C2D30"];
        }
    }
}

- (void)setSpeed:(PlayerSpeed)speed {
    _speed = speed;
    [self selectSpeedButtonWithIndex:speed];
}

- (void)showWithSpeed:(PlayerSpeed)speed fullScreen:(BOOL)isFullScreen {
    self.isFullScreen = isFullScreen;
    NSUInteger index = PlayerSpeed050X - speed;
    [self selectSpeedButtonWithIndex:index];
}

+ (CGFloat)valueFromSpeed:(PlayerSpeed)speed {
    CGFloat value = 1.0;
    switch (speed) {
        case PlayerSpeed200X: value = 2.0;  break;
        case PlayerSpeed150X: value = 1.5;  break;
        case PlayerSpeed125X: value = 1.25; break;
        case PlayerSpeed100X: value = 1.0;  break;
        case PlayerSpeed075X: value = 0.75; break;
        case PlayerSpeed050X: value = 0.5;  break;
        default: break;
    }
    return value;
}

@end
