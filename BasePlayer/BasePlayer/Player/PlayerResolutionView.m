//   
//   PlayerResolutionView.m
//   BDLive
// 
//   Copyright © 2022 Beijing Volcano Engine Technology Co., Ltd. All rights reserved.
//   


#import <Masonry/Masonry.h>
#import "PlayerResolutionView.h"
#import "BDLActivityService.h"
#import "Utils.h"

@interface PlayerResolutionView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *buttonsContainer;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, copy) NSArray<NSNumber *> *resolutionArray;
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;

@property (nonatomic, assign) BDLVideoResolution resolution;
@property (nonatomic, assign) BDLVideoResolution oldResolution;

@end

@implementation PlayerResolutionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
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
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.titleLabel];
    
    self.buttonsContainer = [[UIView alloc] init];
    self.buttonsContainer.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.buttonsContainer];
    
    self.lineView = [[UIView alloc] init];
    [self.contentView addSubview:self.lineView];
    self.lineView.backgroundColor = [Utils colorWithHexString:@"#343434"];
    
    self.cancelButton = [[UIButton alloc] init];
    [self.contentView addSubview:self.cancelButton];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.cancelButton addTarget:self action:@selector(onCancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setTitleColor:[Utils colorWithHexString:@"#A6A6A7"] forState:UIControlStateNormal];
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
    
    [self.buttonsContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(20);
    }];
    
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.cancelButton];
    
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.buttonsContainer.mas_bottom).offset(24);
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
    
    [self updateButtonsConstraints];
}

- (void)setupFullScreenConstraints {
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.width.equalTo(@268);
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.contentView).offset(20);
        make.right.lessThanOrEqualTo(self.contentView);
    }];
    
    [self.buttonsContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
    }];
    
    [self.lineView removeFromSuperview];
    [self.cancelButton removeFromSuperview];
    [self updateButtonsConstraints];
}

- (void)updateButtons {
    [self.buttonsContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSUInteger loopCount = self.resolutionArray.count;
    self.buttons = [[NSMutableArray alloc] initWithCapacity:loopCount];
    for (NSUInteger i = 0; i < loopCount; ++i) {
        UIButton *btn = [[UIButton alloc] init];
        [btn addTarget:self action:@selector(onResolutionButton:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 4;
        btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        btn.backgroundColor = [Utils colorWithHexString:@"#2C2D30"];
        [btn setTitleColor:[Utils colorWithHexString:@"#757577"] forState:UIControlStateNormal];
        [btn setTitleColor:[Utils colorWithHexString:@"#4086FF"] forState:UIControlStateSelected];
        btn.tag = [self.resolutionArray[i] integerValue];
        [self.buttonsContainer addSubview:btn];
        [self.buttons addObject:btn];
    }
    [self updateButtonsConstraints];
    [self refreshViews];
}

- (void)updateButtonsConstraints {
    UIButton *prevButton = nil;
    NSUInteger i = 0;
    for (UIButton *btn in self.buttons) {
        [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (self.fullScreen) {
                if (prevButton) {
                    make.top.equalTo(prevButton.mas_bottom).offset(16);
                }
                else {
                    make.top.equalTo(self.buttonsContainer);
                }
                make.left.right.equalTo(self.buttonsContainer);
            }
            else {
                if (i % 2 == 0) {
                    make.left.equalTo(self.buttonsContainer);
                }
                else {
                    make.left.equalTo(prevButton.mas_right).offset(20);
                }
                make.top.equalTo(self.buttonsContainer).offset((36 + 16) * (i / 2));
            }
            make.width.equalTo(@160);
            make.height.equalTo(@36);
            make.bottom.right.lessThanOrEqualTo(self.buttonsContainer);
        }];
        prevButton = btn;
        i ++;
    }
}

- (void)setFullScreen:(BOOL)fullScreen {
    if (_fullScreen == fullScreen) {
        return;
    }
    _fullScreen = fullScreen;
    if (fullScreen) {
        self.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        for (UIButton *button in self.buttons) {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[Utils colorWithHexString:@"#94C2FF"] forState:UIControlStateSelected];
        }
        [self setupFullScreenConstraints];
    }
    else {
        self.contentView.backgroundColor = [Utils colorWithHexString:@"#202124"];
        for (UIButton *button in self.buttons) {
            [button setTitleColor:[Utils colorWithHexString:@"#757577"] forState:UIControlStateNormal];
            [button setTitleColor:[Utils colorWithHexString:@"#4086FF"] forState:UIControlStateSelected];
        }
        [self setupConstraints];
    }
}

- (void)refreshViews {
    self.titleLabel.text = @"清晰度选择";
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    for (NSUInteger i = 0; i < self.buttons.count; i++) {
        UIButton *btn = self.buttons[i];
        NSString *title = @"unknown";
        switch (btn.tag) {
            case BDLVideoResolutionLD:
                title = @"流畅";
                break;
            case BDLVideoResolutionSD:
                title = @"标清";
                break;
            case BDLVideoResolutionHD:
                title = @"高清";
                break;
            case BDLVideoResolutionUHD:
                title = @"超清";
                break;
            case BDLVideoResolutionBD:
                title = @"蓝光";
                break;
            case BDLVideoResolutionOrigin:
                title = @"原画";
                break;
            case BDLVideoResolutionAuto:
                title = @"智能";
                break;
            default:
                break;
        }
        [btn setTitle:title forState:UIControlStateNormal];
    }
}

- (void)selectWithResolution:(BDLVideoResolution)resolution {
    self.resolution = resolution;
    for (NSUInteger i = 0; i < self.buttons.count; ++i) {
        UIButton *btn = self.buttons[i];
        if ([self.resolutionArray[i] integerValue] == resolution) {
            btn.selected = YES;
            btn.backgroundColor = [[Utils colorWithHexString:@"#4086FF"] colorWithAlphaComponent:0.2];
        } else {
            btn.selected = NO;
            btn.backgroundColor = [Utils colorWithHexString:@"#2C2D30"];
        }
    }
}

- (void)onResolutionButton:(UIButton *)sender {
    BDLVideoResolution resolution = sender.tag;
    self.oldResolution = self.resolution;
    [self selectWithResolution:resolution];
    [self hideWithCompletion:nil];
    
    if (self.resolutionArray && [self.delegate respondsToSelector:@selector(resolutionView:resolutionDidChange:)]) {
        [self.delegate resolutionView:self resolutionDidChange:resolution];
    }
}

- (void)onCancelButtonClick:(UIButton *)btn {
    [self hideWithCompletion:nil];
}

- (void)updateWithResolutions:(NSArray<NSNumber *> *)resolutions currentResolution:(BDLVideoResolution)currentResolution {
    self.resolutionArray = resolutions;
    [self updateButtons];
    [self selectWithResolution:currentResolution];
}

- (void)changeResolutionSuccess:(BOOL)success completeResolution:(BDLVideoResolution)completeResolution {
    if (success) {
        if (self.resolution != completeResolution) {
            //NSLog(@"bdl change resolution ok, but resolution=%@ not equal with completeResolution=%@ !", @(self.resolution), @(completeResolution));
        }
    } else {
        //NSLog(@"bdl change resolution failed, %@--->%@", @(self.resolution), @(self.oldResolution));
        [self selectWithResolution:self.oldResolution];
    }
}

@end
