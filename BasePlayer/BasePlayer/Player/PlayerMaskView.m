//
//  PlayerMaskView.m
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

#import "PlayerMaskView.h"
#import "BDLActivityService.h"
#import "Utils.h"

#import <SDWebImage/SDWebImage.h>

@interface PlayerMaskView ()

@property (nonatomic, assign) BDLActivityStatus status;
@property (nonatomic, assign) BDLLanguageType langType;
@property (nonatomic, assign) BOOL isMultiLanguageEnabled;
@property (nonatomic, copy) NSArray<NSNumber *> *langTypes;

@property (nonatomic, assign) BOOL isVod;
@property (nonatomic, assign) BOOL isFloating;

@property (nonatomic, copy) NSString *previewPrompt;
@property (nonatomic, copy) NSString *watermarkImageUrl;

@property (nonatomic, weak) id<BDLActivityService> svc;

@end

@implementation PlayerMaskView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
        [self setupConstraints];
        [self setupActivity];
    }
    return self;
}

- (void)setupViews {
    self.watermarkImageView = [[UIImageView alloc] init];
    self.watermarkImageView.layer.cornerRadius = 2;
    self.watermarkImageView.layer.masksToBounds = YES;
    [self addSubview:self.watermarkImageView];
    
    self.tagLabel = [[UILabel alloc] init];
    self.tagLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    self.tagLabel.textColor = [UIColor colorWithWhite:1 alpha:0.5];
    self.tagLabel.textAlignment = NSTextAlignmentCenter;
    self.tagLabel.backgroundColor = [UIColor clearColor];
    self.tagLabel.layer.borderColor = [UIColor colorWithRed:230/255.0 green:232/255.0 blue:235/255.0 alpha:0.2].CGColor;
    self.tagLabel.layer.borderWidth = 1;
    self.tagLabel.layer.cornerRadius = 2;
    self.tagLabel.clipsToBounds = YES;
    self.tagLabel.hidden = YES;
    [self addSubview:self.tagLabel];
    
    self.promptContainerView = [[UIView alloc] init];
    self.promptContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.promptContainerView.layer.cornerRadius = 18;
    self.promptContainerView.clipsToBounds = YES;
    self.promptContainerView.hidden = YES;
    [self addSubview:self.promptContainerView];
    
    self.promptLabel = [[UILabel alloc] init];
    self.promptLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    self.promptLabel.textColor = [UIColor whiteColor];
    self.promptLabel.textAlignment = NSTextAlignmentCenter;
    self.promptLabel.backgroundColor = [UIColor clearColor];
    self.promptLabel.numberOfLines = 0;
    [self.promptContainerView addSubview:self.promptLabel];
}

- (void)setupConstraints {
    [self.watermarkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(10);
        make.right.equalTo(self.mas_right).offset(-10);
        make.size.mas_equalTo(CGSizeMake(37, 22));
    }];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(10);
        make.right.equalTo(self.mas_right).offset(-57);
        make.size.mas_equalTo(CGSizeMake(37, 22));
    }];
    
    [self.promptContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.left.greaterThanOrEqualTo(self).offset(14);
        make.right.lessThanOrEqualTo(self).offset(-14);
        make.centerY.equalTo(self.mas_centerY).offset(74).priority(UILayoutPriorityDefaultLow);
        make.bottom.lessThanOrEqualTo(self).offset(-10).priority(UILayoutPriorityDefaultHigh);
    }];
    [self.promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.promptContainerView).insets(UIEdgeInsetsMake(8, 16, 8, 16));
    }];
}

- (void)setupActivity {
    BDLActivityModel *model = [self.svc getActivityModel];
    BDLBasicModel *basicModel = model.basic;
    
    self.previewPrompt = basicModel.previewPrompt;
    self.watermarkImageUrl = basicModel.watermarkImageUrl;
    self.langType = [self.svc getCurrentLangType];
    self.langTypes = basicModel.languageTypes;
    self.isMultiLanguageEnabled = [basicModel isMultiLanguageEnabled];
    
    [self activityStatusDidChange:basicModel.status];
}

- (void)updatePromptLabel {
    if (![self canShowPromptView]) {
        self.promptContainerView.hidden = YES;
        return;
    }
    BDLActivityModel *model = [self.svc getActivityModel];
    BDLBasicModel *basicModel = model.basic;
    BOOL isPreviewPromptEnabled = [basicModel shouldShowPreviewPrompt];
    
    if (BDLActivityStatusEnd == self.status) {
        self.promptLabel.text = @"直播已结束";
        self.promptContainerView.hidden = NO;
    } else if (BDLActivityStatusPreview == self.status) {
        self.promptLabel.text = [Utils stringFromMultiLangString:self.previewPrompt langTypes:self.langTypes langType:self.langType];
        if (isPreviewPromptEnabled
            && !self.isVod) {
            self.promptContainerView.hidden = NO;
        } else {
            self.promptContainerView.hidden = YES;
        }
    } else {
        self.promptContainerView.hidden = YES;
    }
}

- (void)updateWatermarkImageViewConstraint {
    [self.watermarkImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        if (self.isMultiLanguageEnabled) {
            make.right.equalTo(self.mas_right).offset(-40);
        } else {
            make.right.equalTo(self.mas_right).offset(-10);
        }
    }];
}

- (void)updateWatermarkImageViewWithUrl:(NSString *)url {
    [self.watermarkImageView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [self updateWatermarkImageViewConstraint];
    }];
}

- (void)updateWatermarkImageView {
    if (![self canShowPromptView]) {
        self.watermarkImageView.hidden = YES;
        return;
    }
    [self updateWatermarkImageViewWithUrl:self.watermarkImageUrl];
    if (self.watermarkImageUrl.length > 0) {
        self.watermarkImageView.hidden = YES;
    } else {
        self.watermarkImageView.hidden = NO;
    }
    [self updateTagLabelConstraints];
}

- (void)updateTagLabel {
    if (![self canShowPromptView]) {
        self.tagLabel.hidden = YES;
        return;
    }
    switch (self.status) {
        case BDLActivityStatusLive:
            self.tagLabel.hidden = YES;
            break;
        case BDLActivityStatusPreview:
            self.tagLabel.text = @"预告";
            self.tagLabel.hidden = NO;
            break;
        case BDLActivityStatusReplay:
            self.tagLabel.hidden = YES;
            break;
        case BDLActivityStatusEnd:
            self.tagLabel.text = @"结束";
            self.tagLabel.hidden = NO;
            break;
        default:
            self.tagLabel.hidden = YES;
            break;
    }
    [self updateTagLabelConstraints];
}

- (void)updateTagLabelConstraints {
    [self.tagLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        if (self.isMultiLanguageEnabled) {
            if ([self.watermarkImageView isHidden]) {
                make.right.equalTo(self.mas_right).offset(-40);
            } else {
                make.right.equalTo(self.mas_right).offset(-87);
            }
        } else {
            if ([self.watermarkImageView isHidden]) {
                make.right.equalTo(self.mas_right).offset(-10);
            } else {
                make.right.equalTo(self.mas_right).offset(-57);
            }
        }
        if (BDLLanguageTypeEnglish == self.langType
            && BDLActivityStatusPreview == self.status) {
            make.size.mas_equalTo(CGSizeMake(45, 22));
        } else {
            make.size.mas_equalTo(CGSizeMake(37, 22));
        }
    }];
}

- (void)refreshViews {
    [self updatePromptLabel];
    [self updateWatermarkImageView];
    [self updateTagLabel];
}

- (BOOL)startFloating {
    if (self.isFloating) {
        return YES;
    }
    self.isFloating = YES;
    [self refreshViews];
    return YES;
}

- (void)stopFloating {
    self.isFloating = NO;
    [self refreshViews];
}

- (BOOL)canShowPromptView {
    if (self.isFloating) {
        return NO;
    }
    return YES;
}

#pragma mark - BDLBasicService

- (void)activityStatusDidChange:(BDLActivityStatus)status {
    self.status = status;
    
    BDLActivityModel *model = [self.svc getActivityModel];
    BDLBasicModel *basic = model.basic;
    switch (status) {
        case BDLActivityStatusLive:
            self.isVod = NO;
            break;
        case BDLActivityStatusPreview:
            [self previewVideoDidChange:basic.previewVideoUrl isEnabled:basic.isPreviewVideoEnable];
            break;
        case BDLActivityStatusReplay:
            [self replaysDidChange:basic.replays currentSelectedIndex:[self.svc getCurrentMediaIndex]];
            break;
        case BDLActivityStatusEnd:
            self.isVod = NO;
            break;
        default:
            self.isVod = NO;
            break;
    }
    
    [self refreshViews];
}

- (void)previewPromptDidChange:(NSString *)previewPrompt isEnabled:(BOOL)isEnabled {
    self.previewPrompt = previewPrompt;
    
    [self updatePromptLabel];
}

- (void)vodVideoIdDidChange:(NSString *)vid {
    if (vid.length > 0) {
        self.isVod = YES;
    } else {
        self.isVod = NO;
    }
    [self updatePromptLabel];
}

- (void)previewVideoDidChange:(NSString *)url isEnabled:(BOOL)isEnabled {
    if (self.status != BDLActivityStatusPreview) {
        return;
    }
    [self vodVideoIdDidChange:url];
}

- (void)replaysDidChange:(NSArray<BDLReplayModel *> *)replays currentSelectedIndex:(NSUInteger)currentSelectedIndex {
    if (self.status != BDLActivityStatusReplay
        || replays.count <= currentSelectedIndex) {
        return;
    }
    
    NSString *vid = replays[currentSelectedIndex].vid;
    [self vodVideoIdDidChange:vid];
}

- (void)watermarkImageDidChange:(NSString *)url isEnabled:(BOOL)isEnabled {
    self.watermarkImageUrl = url;
    [self updateWatermarkImageView];
}

#pragma mark - BDLLanguageService

- (void)languageDidChangeEnable:(BOOL)isLanguageEnabled
                      langTypes:(NSArray<NSNumber *> *)langTypes
            multiLanguageEnable:(BOOL)isMultiLanguageEnabled {
    self.langTypes = langTypes;
    self.isMultiLanguageEnabled = isMultiLanguageEnabled;
    [self refreshViews];
}

- (void)languageTypeDidChange:(BDLLanguageType)langType {
    self.langType = langType;
    [self refreshViews];
}

- (void)activity:(BDLActivityModel *)activity countdownDidChange:(NSInteger)countdown isEnabled:(BOOL)isEnabled {
    [self updatePromptLabel];
}

@end
