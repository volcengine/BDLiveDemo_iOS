//
//  ViewController.m
// 
//   BDLive SDK License
//   
//   Copyright 2024 Beijing Volcano Engine Technology Ltd. All Rights Reserved.
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

#import <BDLive/BDLLiveEngine.h>
#import <Masonry/Masonry.h>

NSString *const kBDLDidLeaveLiveRoom = @"kBDLDidLeaveLiveRoom";

@interface PlayerView : UIView <BDLBasePlayerViewDelegate>

@property (nonatomic, strong) NSNumber *activityId;
@property (nonatomic, copy) NSString *token;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) BDLBasePlayerView *basePlayerView;

/// 标记一下，防止同一直播间多次进入
@property (nonatomic, assign) BOOL currentIsPlaying;

@end

@implementation PlayerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
        [self addNotifications];
    }
    return self;
}

- (void)setupViews {
    self.imageView = [[UIImageView alloc] init];
    [self addSubview:self.imageView];
    self.imageView.image = [UIImage imageNamed:@"cover"];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.equalTo(self.mas_width).multipliedBy(16.0 / 9);
    }];
    
    UIButton *playButton = [[UIButton alloc] init];
    [self addSubview:playButton];
    [playButton setTitle:@"播放" forState:UIControlStateNormal];
    playButton.showsTouchWhenHighlighted = YES;
    playButton.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255) / 255.0 green:arc4random_uniform(255) / 255.0 blue:arc4random_uniform(255) / 255.0 alpha:1];;
    [playButton addTarget:self action:@selector(onPlayButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.equalTo(@40);
        make.bottom.equalTo(self);
    }];
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidLeaveLiveRoom:) name:kBDLDidLeaveLiveRoom object:nil];
}

- (void)onDidLeaveLiveRoom:(NSNotification *)noti {
    [self stopBasePlayerView];
}

- (void)initBasePlayerView {
    // 造一个新的播放器，待第一帧渲染成功后，替换已有的播放器
    self.basePlayerView = [[BDLBasePlayerView alloc] init];
    self.basePlayerView.hidden = YES;
    [self.basePlayerView play];
    self.basePlayerView.delegate = self;
}

- (void)showBasePlayerView:(BDLBasePlayerView *)basePlayerView {
    if (self.basePlayerView.superview) {
        return;
    }
    [self addSubview:self.basePlayerView];
    basePlayerView.hidden = NO;
    
    [self.basePlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.imageView);
    }];
}

- (void)stopBasePlayerView {
    self.currentIsPlaying = NO;
    [self.basePlayerView stop];
    // 如果需要保留视频最后一帧，可以不移除 self.basePlayerView，待下次播放的时候移除
    [self.basePlayerView removeFromSuperview];
    self.basePlayerView = nil;
}

- (void)onPlayButtonClick {
    if (self.currentIsPlaying) {
        return;
    }
    self.currentIsPlaying = NO;
    BDLActivity *activity = [[BDLActivity alloc] init];
    activity.activityId = self.activityId;
    activity.token = self.token;
    activity.isPortrait = YES;
    activity.authMode = BDLActivityAuthModePublic;
    // joinLiveRoomWithActivity 内部会先退出现有直播间，这里发通知，通知外部停止播放
    [[NSNotificationCenter defaultCenter] postNotificationName:kBDLDidLeaveLiveRoom object:nil];
    BOOL ret = [[BDLLiveEngine sharedInstance] joinLiveRoomWithActivity:activity success:^{
        self.currentIsPlaying = YES;
        [self initBasePlayerView];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"joinLiveRoomWithActivity fail %@", error);
    }];
    if (!ret) {
        NSLog(@"joinLiveRoomWithActivity fail");
    }
}

- (void)basePlayerViewOnFirstVideoFrameRendered:(BDLBasePlayerView *)basePlayerView {
    // 这里第一帧开始渲染的时候才显示，防止中途画面跳动
    [self showBasePlayerView:basePlayerView];
}

@end

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
}

- (void)setupViews {
    CGFloat w = (CGRectGetWidth(self.view.bounds) - 120) / 2;
    CGFloat h = w / 9 * 16 + 80;
    PlayerView *leftPlayerView = [[PlayerView alloc] init];
    [self.view addSubview:leftPlayerView];
    leftPlayerView.activityId = @(1794755538574419);
    leftPlayerView.token = @"UoMdEG";
    [leftPlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(40);
        make.left.equalTo(self.view).offset(40);
        make.height.equalTo(@(h));
        make.width.equalTo(@(w));
    }];
    
    PlayerView *rightPlayerView = [[PlayerView alloc] init];
    [self.view addSubview:rightPlayerView];
    rightPlayerView.activityId = @(1795080455821372);
    rightPlayerView.token = @"cJUBHH";
    [rightPlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(40);
        make.right.equalTo(self.view).offset(-40);
        make.height.equalTo(@(h));
        make.width.equalTo(@(w));
    }];
}

@end
