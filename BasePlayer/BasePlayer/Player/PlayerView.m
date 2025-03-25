//
//  PlayerView.m
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

#import "PlayerView.h"
#import "LogManager.h"

typedef void(^bdld_dispatch_cancelable_block_t)(BOOL cancelled);

static bdld_dispatch_cancelable_block_t bdld_dispatch_after(dispatch_time_t when, dispatch_queue_t queue, dispatch_block_t block) {
    if (nil == block) {
        return nil;
    }
    __block dispatch_block_t originalBlock = [block copy];
    if (nil == originalBlock) {
        return nil;
    }
    __block bdld_dispatch_cancelable_block_t cancelableBlock = [^(BOOL cancelled) {
        if (!cancelled && originalBlock != nil) {
            dispatch_async(queue ?: dispatch_get_main_queue(), originalBlock);
        }
        originalBlock = nil;
        cancelableBlock = nil;
    } copy];
    if (nil == cancelableBlock) {
        return nil;
    }
    dispatch_after(when, queue ?: dispatch_get_main_queue(), ^{
        if (cancelableBlock != nil) {
            cancelableBlock(NO);
            cancelableBlock = nil;
        }
    });
    return cancelableBlock;
}

bdld_dispatch_cancelable_block_t bdld_dispatch_main_after(NSTimeInterval delayInSeconds, dispatch_block_t block) {
    return bdld_dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), block);
}

void bdld_cancel_block(bdld_dispatch_cancelable_block_t block) {
    if (block != nil) {
        block(YES);
    }
}

@interface PlayerView ()
< BDLBasePlayerViewDelegate
, PlayerControlViewDelegate
, PlayerResolutionViewDelegate
, NetworkNotReachableViewDelegate
, NetworkViaWWANViewDelegate
, PlayerReplayViewDelegate
, PlayerSpeedViewDelegate
, UIGestureRecognizerDelegate
>

@property (nonatomic, assign) BDLActivityStatus status;
@property (nonatomic, assign) BDLLanguageType langType;
@property (nonatomic, copy) NSArray<NSNumber *> *langTypes;

@property (nonatomic, assign) BOOL isFetchVodUrlFailed;
@property (nonatomic, assign, readwrite) BOOL isPiPStarted;

@property (nonatomic, assign) BOOL isVod;
@property (nonatomic, copy) NSString *vodId;

// 是否首次播放
@property (nonatomic, assign) BOOL isFirstPlay;
// 中断开始时是否为播放状态
@property (nonatomic, assign) BOOL isPlayingBeforeInterrupted;
// 是否正在InAppPiP状态
@property (nonatomic, assign, readwrite) BOOL isFloating;

// 当前网络状态
@property (nonatomic, assign) BDLNetworkStatus networkStatus;
@property (nonatomic, assign) BOOL networkNotReachable;

// 全屏状态
@property (nonatomic, assign, readwrite) BOOL isFullScreen;
@property (nonatomic, assign) BOOL shouldPlayWhenForeground;
@property (nonatomic, strong) UITapGestureRecognizer *singleGesture;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGesture;

@property (nonatomic, copy) bdld_dispatch_cancelable_block_t hideControlViewBlock;
@property (nonatomic, copy) bdld_dispatch_cancelable_block_t hideWWANViewBlock;

@property (nonatomic, strong) BDLBasePlayerView *basePlayerView;

@property (nonatomic, weak) id<BDLActivityService> svc;

@end

@implementation PlayerView

- (instancetype)init {
    if ([super init]) {
        self.basePlayerView = [[BDLBasePlayerView alloc] init];
        self.basePlayerView.delegate = self;
        if (@available(iOS 14.0, *)) {
            self.basePlayerView.enablePictureInPicture = YES;
        }
        
        id <BDLNetworkService> svc = [[BDLLiveEngine sharedInstance] serviceWithProtocol:@protocol(BDLNetworkService)];
        self.networkStatus = [svc networkStatus];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(onNetworkDidChangeNotification:) name:BDLNetworkDidChangeNotification object:nil];
        [nc addObserver:self selector:@selector(onApplicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [nc addObserver:self selector:@selector(onApplicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        [self setupViews];
        [self setupConstraints];
        [self setupActivity];
    }
    return self;
}

- (void)dealloc {
    [self cancelAutoHideControlView];
    [self cancelAutoHideNetworkViaWWANView];
}

- (void)setupViews {
    self.layer.cornerRadius = 4;
    self.layer.masksToBounds = YES;
    
    self.backgroundColor = [UIColor clearColor]; // NTOE: 这里要显示出来背景颜色
    
    [self addSubview:self.basePlayerView];
    self.basePlayerView.userInteractionEnabled = NO;
    self.basePlayerView.scalingMode = BDLPlayerScalingModeAspectFill;
    
    self.playerMaskView = [[PlayerMaskView alloc] init];
    [self addSubview:self.playerMaskView];
    self.playerMaskView.userInteractionEnabled = NO;
    [self setupControlView];
    
    self.singleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelfSingleTap:)];
    [self addGestureRecognizer:self.singleGesture];
    self.singleGesture.delegate = self;
}

- (void)setupControlView {
    self.controlView = [[PlayerControlView alloc] init];
    self.controlView.delegate = self;
    self.controlView.clipsToBounds = YES; // 如果为NO, 竖屏时候横屏视频动画很奇怪
    self.controlView.hidden = YES;
    
    self.controlView.duration = self.basePlayerView.duration;
    self.controlView.currentTime = self.basePlayerView.currentPlaybackTime;
    if (self.basePlayerView.isPlaying) {
        [self.controlView play];
    }
    if (self.basePlayerView.isLive || self.basePlayerView.isVod) {
        [self basePlayerView:self.basePlayerView supportedVideoResolutionsDidChange:self.basePlayerView.supportedVideoResolutions currentVideoResolution:self.basePlayerView.currentVideoResolution];
    }
    [self addSubview:self.controlView];
    [self updateControlViewConstraints];
}

- (void)updateControlViewConstraints {
    [self.controlView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.basePlayerView);
    }];
}

- (void)setupConstraints {
    self.isPlayerFullSuper = YES;
    [self.basePlayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.playerMaskView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)refreshConstraints {
    [self updateControlViewConstraints];
    [self remakePromptViewsConstraint];
}

- (void)setupActivity {
    BDLActivityModel *model = [self.svc getActivityModel];
    BDLBasicModel *basicModel = model.basic;
    if (basicModel != nil) {
        [self languageDidChangeEnable:basicModel.isLanguageEnable
                            langTypes:basicModel.languageTypes
                  multiLanguageEnable:[basicModel isMultiLanguageEnabled]];
    }
    [self languageTypeDidChange:[self.svc getCurrentLangType]];
    
    // 因为以下调用内部使用delegate，但此时init未执行完毕，delegate还未赋值，所以延后执行
    dispatch_async(dispatch_get_main_queue(), ^{
        [self activityStatusDidChange:basicModel.status];
    });
}

/// 重置点播的 倍速、分辨率、播放时间，现用于多线路切换时候恢复默认的倍速以及清晰度
- (void)resetVodPlayer {
    if (self.isVod) {
        self.controlView.speed = PlayerSpeed100X;
        CGFloat value = [PlayerSpeedView valueFromSpeed:PlayerSpeed100X];
        self.basePlayerView.playbackSpeed = value;
        self.basePlayerView.currentVideoResolution = BDLVideoResolutionUnknown;
        [self.basePlayerView setVodStartTime:0.0];
    }
}

#pragma mark - BDLBasePlayerView

- (BOOL)isLive {
    if (BDLActivityStatusLive == self.status) {
        return YES;
    }
    return NO;
}

- (BOOL)hasVideo {
    if ([self isLive]
        || self.isVod) {
        return YES;
    }
    return NO;
}

- (BOOL)hasImage {
    return self.basePlayerView.coverImageView.image != nil;
}

- (BOOL)isPortraitImage {
    CGSize imageSize = self.basePlayerView.coverImageView.image.size;
    return imageSize.height > imageSize.width;
}

- (BOOL)shouldAutoPlay {
    return YES;
}

- (BOOL)isPlayCompleted {
    return fabs(self.basePlayerView.duration - self.basePlayerView.currentPlaybackTime) < 0.0001;
}

- (void)play {
    if (![self hasVideo]) {
        return;
    }
    if (!self.basePlayerView.isPlaying) {
        [self.controlView play];
    }
}

- (void)pause {
    if (self.basePlayerView.isPlaying) {
        [self.controlView pause];
    }
}

- (void)stop {
    [self.basePlayerView stop];
}

- (void)addPlayerTimeObserver {
    [self removePlayerTimeObserver];
    self.controlView.currentTime = self.basePlayerView.currentPlaybackTime;
    
    __weak typeof(self) weakSelf = self;
    [self.basePlayerView addPeriodicObserverWithInterval:0.1 queue:dispatch_get_main_queue() usingBlock:^{
        if (![weakSelf.controlView isSliding]
            && weakSelf.basePlayerView.duration > 0
            && !weakSelf.basePlayerView.isSeeking) {
            weakSelf.controlView.currentTime = weakSelf.basePlayerView.currentPlaybackTime;
            [weakSelf.controlView setCacheProgress:weakSelf.basePlayerView.playableDuration / weakSelf.basePlayerView.duration animated:YES];
        }
    }];
}

- (void)removePlayerTimeObserver {
    [self.basePlayerView removePeriodicObserver];
}

- (void)removeBasePlayerView {
    [self removePlayerTimeObserver];
}

- (void)addBasePlayerView:(BDLBasePlayerView *)basePlayerView {
    _basePlayerView = basePlayerView;
    [self insertSubview:self.basePlayerView atIndex:0];
    _basePlayerView.delegate = self;
    [self.basePlayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.basePlayerView.userInteractionEnabled = NO;
    if ([self hasVideo]) {
        [self basePlayerView:self.basePlayerView supportedVideoResolutionsDidChange:self.basePlayerView.supportedVideoResolutions currentVideoResolution:self.basePlayerView.currentVideoResolution];
    }
    [self addPlayerTimeObserver];

    if (self.controlView.isPlaying
        && !self.basePlayerView.isPlaying) {
        [self.controlView pause];
    }
    if (!self.controlView.isPlaying
        && self.basePlayerView.isPlaying) {
        [self.controlView play];
    }

    if (self.basePlayerView.isStalling) {
        [self showLoadingView];
    } else {
        [self hideLoadingView];
        [self hideNetworkNotReachableView];
    }

    switch (self.basePlayerView.playerState) {
        case BDLPlayerStateStopped:
            [self cancelAutoHideControlView];
            [self hideControlView];
            break;
        case BDLPlayerStateError:
            if (self.networkNotReachable) {
                [self showNetworkNotReachableView];
            } else {
                [self showLoadingView];
            }
            break;
        default:
            break;
    }

    if (self.isVod
        && self.controlView.isPlaying) {
        self.controlView.duration = self.basePlayerView.duration;
        self.controlView.currentTime = self.basePlayerView.currentPlaybackTime;
    }
    if (@available(iOS 14.0, *)) {
        BDLActivityStatus status = [self.svc getActivityModel].basic.status;
        if ((status == BDLActivityStatusLive && [self isLivePiPConfigEnabled] != self.basePlayerView.enablePictureInPicture)
            || (status == BDLActivityStatusReplay && [self isVodPiPConfigEnabled] != self.basePlayerView.enablePictureInPicture)
            || (status == BDLActivityStatusPreview && [self isVodPiPConfigEnabled] != self.basePlayerView.enablePictureInPicture)) {
            [self disablePiP];
            [self enablePiP];
        }
    }
}

#pragma mark - BDLBasePlayerViewDelegate

// CoverImage
- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView coverImageViewWillAppear:(UIImageView *)coverImageView {
    LogContent(@"即将显示封面图");
}

- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView coverImageViewDidAppear:(UIImageView *)coverImageView {
    LogContent(@"封面图已经显示了");
}
- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView coverImageViewWillDisappear:(UIImageView *)coverImageView {
    LogContent(@"即将隐藏封面图");
}

- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView coverImageViewDidDisappear:(UIImageView *)coverImageView {
    LogContent(@"封面图已经隐藏了");
}

- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView coverImageUrlDidChange:(nullable NSString *)url isEnabled:(BOOL)isEnabled {
    LogContent([NSString stringWithFormat:@"封面图url改变了，\n url: %@\n isEnabled: %d", url, isEnabled]);
}

- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView coverImageDidChange:(nullable UIImage *)image error:(nullable NSError *)error {
    LogContent(@"封面图改变了");
    [self refreshConstraints];
}

- (void)basePlayerViewPlayerItemDidChange:(BDLBasePlayerView *)basePlayerView isLive:(BOOL)isLive willPlay:(BOOL)willPlay {
    LogContent([NSString stringWithFormat:@"播放内容改变了 isLive: %d willPlay: %d", isLive, willPlay]);
    // NOTE: 这里多次开关预览，会出现进度条不隐藏的情况
    // PlayerControlView收到 previewVideoDidChange: 后会调用 activityStatusDidChange:
    // activityStatusDidChange:会重置controlView，进而导致进度条的autohide为NO，导致进度条不隐藏
    //（其实也调用暂停了，但是因为此时播放器还在vid换url的网络请求中，所以暂停无效）
    // 这里根据播放状态重新显示下进度条
    [self showControlViewIfNeededWithAutoHide:willPlay];
    [self.controlView updatePlayButton:willPlay];
}

- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView videoViewWillAppear:(UIView *)videoView isLive:(BOOL)isLive {
    LogContent([NSString stringWithFormat:@"即将显示播放器页面 isLive: %d", isLive]);
    // 需要取消首次播放loading
    self.isFirstPlay = NO;
    
    if (BDLNetworkStatusReachableViaWWAN == self.networkStatus) {
        // 开启非Wi-Fi网络提示，不检查是否自动播放，弹出网络提示
        [self showNetworkViaWWANView];
    }
    
    [self refreshConstraints];
}

- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView videoViewDidAppear:(UIView *)videoView isLive:(BOOL)isLive {
    LogContent([NSString stringWithFormat:@"播放器页面已经显示 isLive: %d", isLive]);
    [self hideLoadingView];
}

- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView videoViewWillDisappear:(UIView *)videoView {
    LogContent(@"即将隐藏播放器页面");
    [self cancelAutoHideControlView];
    [self hideControlView];
}

- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView videoViewDidDisappear:(UIView *)videoView {
    LogContent(@"播放器页面已经消失了");
}

- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView videoSizeDidChange:(CGSize)videoSize {
    LogContent([NSString stringWithFormat:@"视频尺寸发生了变化 %@", NSStringFromCGSize(videoSize)]);
    self.isPortraitVideo = videoSize.height > videoSize.width;
    [self refreshConstraints];
    [self showControlViewIfNeededWithAutoHide:YES];
}

- (void)basePlayerViewOnFirstVideoFrameRendered:(BDLBasePlayerView *)basePlayerView {
    LogContent(@"视频渲染了第一帧画面");
    [self refreshConstraints];
    [self showControlViewIfNeededWithAutoHide:YES];
}

- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView
supportedVideoResolutionsDidChange:(NSArray<NSNumber *> *)supportedVideoResolutions
currentVideoResolution:(BDLVideoResolution)currentVideoResolution {
    LogContent([NSString stringWithFormat:@"视频支持的分辨率发生了变化 支持分辨率: %@, 当前分辨率: %ld", supportedVideoResolutions, currentVideoResolution]);
    [self.resolutionView updateWithResolutions:supportedVideoResolutions currentResolution:currentVideoResolution];
    
    [self.controlView updateResolutionButtonWithResolutions:supportedVideoResolutions currentResolution:currentVideoResolution];
}

- (void)basePlayerViewStallStart:(BDLBasePlayerView *)basePlayerView {
    LogContent(@"播放器开始卡顿");
    [self showLoadingView];
}

- (void)basePlayerViewStallEnd:(BDLBasePlayerView *)basePlayerView {
    LogContent(@"播放器停止卡顿");
    [self hideLoadingView];
    [self hideNetworkNotReachableView];
    [self hideReplayView];
}

- (void)basePlayerViewWillStartPictureInPicture:(BDLBasePlayerView *)basePlayerView {
    LogContent(@"即将开启画中画");
    self.isPiPStarted = YES;
    self.basePlayerView.watermarkView.hidden = NO;
}

- (void)basePlayerViewDidStartPictureInPicture:(BDLBasePlayerView *)basePlayerView {
    LogContent(@"已经开启了画中画");
    self.isPiPStarted = YES;
}

- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView failedToStartPictureInPictureWithError:(NSError *)error {
    LogContent([NSString stringWithFormat:@"开启画中画失败 %@", error.localizedDescription]);
    self.isPiPStarted = NO;
    if (!self.isFullScreen
        && !self.isFloating) {
        self.basePlayerView.watermarkView.hidden = YES;
    }
}

- (void)basePlayerViewWillStopPictureInPicture:(BDLBasePlayerView *)basePlayerView {
    LogContent(@"即将停止画中画");
    self.isPiPStarted = NO;
    if (!self.isFullScreen) {
        self.basePlayerView.watermarkView.hidden = YES;
    }
}

- (void)basePlayerViewDidStopPictureInPicture:(BDLBasePlayerView *)basePlayerView {
    LogContent(@"已经停止画中画");
    self.isPiPStarted = NO;
    // 已经关闭画中画
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        //NSLog(@"pip DidStop in background, pause");
        // 手动关闭，暂停播放
        if (self.basePlayerView.isPlaying) {
            self.shouldPlayWhenForeground = YES;
            [self pause];
        }
    }
}

- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView liveLoadStateDidChange:(BDLPlayerLoadState)loadState {
    LogContent([NSString stringWithFormat:@"直播加载状态发生了变化 %ld", (long)loadState]);
    switch (loadState) {
            // 这里设置弱网速, loadState 会在TVLPlayerLoadStateUnknown和TVLPlayerLoadStateError 之间切换,这里showLoadingView一下
        case TVLPlayerLoadStateUnknown:
        case TVLPlayerLoadStateError: // 网络错误后重试触发
            // 网络错误最终会走到这里
            if (self.networkNotReachable) {
                [self showNetworkNotReachableView];
            } else {
                [self showLoadingView];
            }
            break;
        default:
            break;
    }
}

- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView livePlayerItemStatusDidChange:(TVLPlayerItemStatus)itemStatus {
    LogContent([NSString stringWithFormat:@"直播播放状态发生了变化 %ld", (long)itemStatus]);
    switch (itemStatus) {
        case TVLPlayerItemStatusCompleted:
            if (self.networkNotReachable) {
                [self showLoadingView];
            }
            break;
        case TVLPlayerItemStatusReadyToPlay:
            // 隐藏loading,防止边播声音边loading
            // (直播进入画中画,关闭画中画,一段时间打开APP,会出现边播声音边loading)
            // https://meego.feishu.cn/bytelive/issue/detail/4456176
            [self hideLoadingView];
            break;
        default:
            break;
    }
}

- (void)basePlayerViewWillFetchVodUrl:(BDLBasePlayerView *)basePlayerView {
    LogContent(@"播放器将要获取点播的播放url");
    [self showLoadingView];
}

- (void)basePlayerViewDidFetchVodUrl:(BDLBasePlayerView *)basePlayerView error:(nullable NSError *)error {
    LogContent([NSString stringWithFormat:@"播放器已经获取点播的播放url error: %@", error.localizedDescription]);
    self.isFetchVodUrlFailed = error != nil;
    [self hideLoadingView];
    if (self.isFetchVodUrlFailed) {
        [self hideControlView];
        [self showNetworkNotReachableView];
    }
}

- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView vodDidFinishWithError:(nullable NSError *)error {
    LogContent([NSString stringWithFormat:@"点播播放完成 error: %@", error.localizedDescription]);
    if (nil == error
        || error.code == -499894) { // 499894 | 其它http4xx错误           | 建议更换视频网址
        BDLActivityModel *activityModel = [self.svc getActivityModel];
        BOOL nextSuccess = NO;
        if (activityModel.basic.replays.count > 1) {
            nextSuccess = [self.svc nextReplayVideo];
        }
        if ([self shouldShowReplayView] && !nextSuccess) {
            [self.controlView updatePlayButton:NO];
            [self hideControlView];
            [self showReplayView];
        }
        return;
    }
    // 非暂停状态下才处理
    if (self.controlView.centerPlayButton.hidden) {
        [self showNetworkNotReachableView];
        [self hideControlView];
    }
}

- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView vodLoadStateDidChange:(TTVideoEngineLoadState)loadState {
    LogContent([NSString stringWithFormat:@"点播加载状态变化 %ld", loadState]);
    switch (loadState) {
        case TTVideoEngineLoadStateUnknown:
            // 网络错误最终会走到这里
            if (self.networkNotReachable) {
                [self showNetworkNotReachableView];
            }
            break;
        default:
            break;
    }
}

- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView vodPlaybackStateDidChange:(TTVideoEnginePlaybackState)playbackState {
    LogContent([NSString stringWithFormat:@"点播播放状态变化 %ld", playbackState]);
    switch (playbackState) {
        case TTVideoEnginePlaybackStateStopped:
            break;
        case TTVideoEnginePlaybackStatePlaying:
            // 卡顿时暂停再次播放，根据 stall 记录加上 loading
            if (self.basePlayerView.isStalling) {
                [self showLoadingView];
            } else {
                [self hideLoadingView];
                [self hideNetworkNotReachableView];
                [self hideReplayView];
            }
            self.controlView.duration = self.basePlayerView.duration;
            break;
        case TTVideoEnginePlaybackStatePaused:
            // 切换网络时会触发pause&play，若显示非wifi提示直接返回
            [self hideLoadingView];
            [self hideNetworkNotReachableView];
            [self hideReplayView];
            break;
        case TTVideoEnginePlaybackStateError:
            break;
        default:
            break;
    }
}

- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView vodRetryForError:(NSError *)error {
    LogContent([NSString stringWithFormat:@"点播 重试 %@", error.localizedDescription]);
    // 网络不可用后重试失败触发
    if (self.networkNotReachable) {
        [self showNetworkNotReachableView];
    }
}

- (void)basePlayerView:(BDLBasePlayerView *)basePlayerView onVodAutoContinuePlayback:(NSTimeInterval)playbackTime {
    LogContent([NSString stringWithFormat:@"点播 断点续播 时间：%f", playbackTime]);
    if (self.isFloating) {
        return;
    }
    if (self.langType == BDLLanguageTypeChinese
        && (NSInteger)playbackTime > 0) {// 可能会记录0-1的值, 如果toast出来, 就"已为您是定位至00:00"
        [self showContinuePlaybackToastWithTime:playbackTime hideAfterDelay:2];
    }
}

/// MARK: - Continue playback

- (void)showContinuePlaybackToastWithTime:(NSTimeInterval)playbackTime hideAfterDelay:(NSTimeInterval)delay {
    [self hideContinuePlaybackToast];
    ContinuePlaybackToastView *toastView = [[ContinuePlaybackToastView alloc] initWithPlaybackTime:playbackTime];
    
    if (toastView && !toastView.hidden) {
        [self addSubview:toastView];
        self.continuePlaybackToastView = toastView;
        [toastView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).inset(18);
            make.bottom.equalTo(self.controlView.controlBarView.mas_top).offset(-5);
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideContinuePlaybackToast];
        });
    }
}

- (void)hideContinuePlaybackToast {
    if (self.continuePlaybackToastView) {
        [self.continuePlaybackToastView removeFromSuperview];
        self.continuePlaybackToastView = nil;
    }
}

- (void)basePlayerViewDidSingleTap:(BDLBasePlayerView *)basePlayerView {
    LogContent(@"单击了播放器");
    [self showControlViewIfNeededWithAutoHide:YES];
}

- (void)basePlayerViewDidDoubleTap:(BDLBasePlayerView *)basePlayerView {
    LogContent(@"双击了播放器");
}

- (void)onFullScreenButtonClick:(UIButton *)button {
    [self.controlView onFullScreen];
}

#pragma mark - PlayerMaskViewDelegate

- (void)onSelfSingleTap:(UITapGestureRecognizer *)playerMaskView {
    if (!self.isFloating) {
        if (self.controlView.hidden) {
            [self showControlViewIfNeededWithAutoHide:YES];
        }
        else if (self.isVod
                 || !self.isPortraitVideo
                 || self.isFullScreen) { // 点击暂停/播放
            if (self.controlView.isPlaying){
                [self pause];
            }
            else {
                [self play];
            }
        }
    }

    if ([self.delegate respondsToSelector:@selector(playerViewDidSingleTap:)]) {
        [self.delegate playerViewDidSingleTap:self];
    }
}

- (void)onSelfDoubleTap:(UITapGestureRecognizer *)tap {
    if (self.isFloating && self.controlView.isPlaying && self.isVod) {
        [self pause];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == self
        || touch.view == self.controlView
        || (self.isFloating && touch.view.superview == self.replayView)) { // 重播显示时候显示小窗，点击空白处要回到播放器
        return YES;
    }
    return NO;
}

#pragma mark - ControlView

- (void)showControlViewIfNeededWithAutoHide:(BOOL)autoHide {
    BOOL isAppear = [self.controlView showIfNeeded];
    if (autoHide) {
        [self autoHideControlView];
    } else {
        [self cancelAutoHideControlView];
    }
    [self addPlayerTimeObserver];
    [self controlViewIsAppear:isAppear];
}

- (void)hideControlView {
    [self removePlayerTimeObserver];
    [self.controlView hide];
    [self controlViewIsAppear:NO];
}

- (void)autoHideControlView {
    [self cancelAutoHideControlView];
    __weak typeof(self) weakSelf = self;
    self.hideControlViewBlock = bdld_dispatch_main_after(3.0, ^{
        [weakSelf hideControlView];
    });
}

- (void)cancelAutoHideControlView {
    if (self.hideControlViewBlock != nil) {
        bdld_cancel_block(self.hideControlViewBlock);
        self.hideControlViewBlock = nil;
    }
}

- (void)controlViewIsAppear:(BOOL)isAppear {
   
}

#pragma mark - PlayerControlViewDelegate

- (void)controlView:(PlayerControlView *)controlView playButtonDidTouch:(BOOL)isSelected {
    if (isSelected) {
        // 开始播放
        [self.basePlayerView play];
        [self autoHideControlView];
        
        if (self.isFirstPlay) {
            [self showLoadingView];
            self.isFirstPlay = NO;
        }
        
        // 直播中卡顿时暂停再次播放，根据 stall 记录加上 loading
        if ([self isLive] && self.basePlayerView.isStalling) {
            [self showLoadingView];
        }
    } else {
        // 暂停播放
        [self.basePlayerView pause];
        // 暂停时隐藏加载界面, 避免暂停按钮和播放按钮同时存在
        [self hideLoadingView];
        [self showControlViewIfNeededWithAutoHide:NO];
        if ([self isLive] && self.basePlayerView.isStalling) {
            [self hidePromptViews];
        }
    }
}

- (void)controlViewSliderBeganDrag {
    [self showControlViewIfNeededWithAutoHide:NO];
}

- (void)controlViewSliderEndDrag {
    [self seekVideoAndAutoHideControlViewIfNeeded];
}

- (void)controlViewSliderViewDidTap {
    [self seekVideoAndAutoHideControlViewIfNeeded];
}

- (void)seekVideoAndAutoHideControlViewIfNeeded {
    NSTimeInterval ti = self.controlView.sliderView.progress * self.basePlayerView.duration;
    [self.basePlayerView seek:ti completion:^(BOOL success) {
    }];
    if (self.basePlayerView.isPlaying) { // 播放时候隐藏进度条
        [self autoHideControlView];
    }
}

- (void)controlView:(PlayerControlView *)controlView progressDidChange:(CGFloat)progress {
}

- (void)controlViewRefreshButtonDidTouch:(PlayerControlView *)controlView {
    [self pause];
    [self showLoadingView];
    [self play];
}

- (void)controlViewResolutionButtonDidTouch:(PlayerControlView *)controlView {
    [self showResolutionView];
}

- (void)controlViewSpeedButtonDidTouch:(PlayerControlView *)controlView {
//    [self cancelAutoHideControlView];
    [self showSpeedView];
}

- (void)controlView:(PlayerControlView *)controlView fullScreenButtonDidTouch:(BOOL)isSelected {
    [[LogManager sharedInstance] log:@"控制栏点击" content:isSelected ? @"点击了全屏按钮" : @"点击了退出全屏"];
//    return;
    if (isSelected) {
        [self.playerMaskView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
            } else {
                make.left.right.equalTo(self);
            }
            make.top.bottom.equalTo(self);
        }];
    } else { // 退出全屏
        [self setupConstraints];
        if (![self.controlView canShow]) {
            [self.controlView hide];
        }
    }
    self.isFullScreen = isSelected;

    [self hideResolutionView];

    if ([self.delegate respondsToSelector:@selector(playerView:fullScreenButtonDidTouch:)]) {
        [self.delegate playerView:self fullScreenButtonDidTouch:isSelected];
    }
}

- (void)updatePlayerWhenLeaveFullScreen {
    [self insertSubview:self.basePlayerView atIndex:0];
    [self updateControlViewConstraints];
}

#pragma mark - PlayerResolutionView

- (PlayerResolutionView *)resolutionView {
    if (!_resolutionView) {
        _resolutionView = [[PlayerResolutionView alloc] init];
        _resolutionView.delegate = self;
        _resolutionView.onBackgroundTapCallback = ^(BDLPopupBaseView * _Nonnull view) {
            [view hideWithCompletion:^(BDLPopupBaseView * _Nonnull view) {
                
            }];
        };
    }
    return _resolutionView;
}

- (void)showResolutionView {
    if (![self canShowPromptView]) {
        return;
    }
    if (!self.popupSuperView) {
        return;
    }
    self.resolutionView.fullScreen = self.isFullScreen;
    if (self.isFullScreen) {
        [self.resolutionView rightShowInView:self.popupSuperView completion:nil];
    }
    else {
        [self.resolutionView bottomShowInView:self.popupSuperView completion:nil];
    }
    
}

- (void)hideResolutionView {
    [_resolutionView removeFromSuperview];
}

#pragma mark - PlayerSpeedView

- (PlayerSpeedView *)speedView {
    if (!_speedView) {
        _speedView = [[PlayerSpeedView alloc] init];
        _speedView.delegate = self;
        _speedView.onBackgroundTapCallback = ^(BDLPopupBaseView * _Nonnull view) {
            [view hideWithCompletion:nil];
        };
    }
    return _speedView;
}

- (void)showSpeedView {
    if (!self.popupSuperView) {
        return;
    }
    self.speedView.speed = self.controlView.speed;
    self.speedView.fullScreen = self.isFullScreen;
    if (self.isFullScreen) {
        [self.speedView rightShowInView:self.popupSuperView completion:nil];
    }
    else {
        [self.speedView bottomShowInView:self.popupSuperView completion:nil];
    }
}

- (void)hideSpeedView {
    if (nil == _speedView.superview) {
        return;
    }
    [_speedView hideWithCompletion:nil];
}

#pragma mark - PlayerSpeedViewDelegate

- (void)speedView:(PlayerSpeedView *)speedView speedDidChange:(PlayerSpeed)speed {
    self.controlView.speed = speed;
    CGFloat value = [PlayerSpeedView valueFromSpeed:speed];
    self.basePlayerView.playbackSpeed = value;
    
    LogContent([NSString stringWithFormat:@"已开启%@倍速播放", @(value)]);
}

#pragma mark - PlayerResolutionViewDelegate

- (void)resolutionView:(PlayerResolutionView *)resolutionView resolutionDidChange:(BDLVideoResolution)resolution {
    self.basePlayerView.currentVideoResolution = resolution;
    BOOL success = self.basePlayerView.currentVideoResolution == resolution;
    [self.resolutionView changeResolutionSuccess:success completeResolution:self.basePlayerView.currentVideoResolution];
    [self.controlView changeResolutionSuccess:success completeResolution:self.basePlayerView.currentVideoResolution];
    // 暂停时切换分辨率, 播放器会开始播放, 但controlView还会保持暂停状态, 这里改成播放状态
    [self.controlView updatePlayButton:YES];
}

#pragma mark - PromptView

- (BOOL)canShowPromptView {
    if (self.isFloating) {
        return NO;
    }
    return YES;
}

- (void)hidePromptViews {
    [self hideLoadingView];
    [self hideNetworkNotReachableView];
    [self hideNetworkViaWWANView];
    [self hideReplayView];
}

- (void)remakePromptViewsConstraint {
    [self.loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.basePlayerView.videoView != nil) {
            make.center.equalTo(self.basePlayerView);
        } else {
            make.center.equalTo(self);
        }
    }];
    [self.networkNotReachableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.basePlayerView != nil) {
            make.center.equalTo(self.basePlayerView);
        } else {
            make.center.equalTo(self);
        }
    }];
    [self.networkViaWWANView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.basePlayerView.videoView != nil) {
            make.center.equalTo(self.basePlayerView);
        } else {
            make.center.equalTo(self);
        }
    }];
    
    [self.replayView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.basePlayerView.videoView != nil) {
            make.edges.equalTo(self.basePlayerView);
        } else {
            make.edges.equalTo(self);
        }
    }];

    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - LoadingView

- (LoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[LoadingView alloc] init];
        
        self.loadingView.imageView.image = [UIImage imageNamed:@"loading2"];
        [self.loadingView.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
        [self insertSubview:self.loadingView belowSubview:self.playerMaskView];
    }
    return _loadingView;
}

- (void)showLoadingView {
    if (!self.controlView.centerPlayButton.hidden) {
        return;
    }
    [self hidePromptViews];
    [self insertSubview:self.loadingView belowSubview:self.playerMaskView];
    [self.loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.basePlayerView.videoView != nil && self.basePlayerView.superview == self) {
            make.center.equalTo(self.basePlayerView);
        } else {
            make.center.equalTo(self);
        }
    }];
    [self.loadingView showAnimation];
    self.loadingView.hidden = NO;
}

- (void)hideLoadingView {
    [self.loadingView hideAnimation];
    self.loadingView.hidden = YES;
}

#pragma mark - NetworkNotReachableView

- (NetworkNotReachableView *)networkNotReachableView {
    if (!_networkNotReachableView) {
        _networkNotReachableView = [[NetworkNotReachableView alloc] init];
        _networkNotReachableView.delegate = self;
        _networkNotReachableView.hidden = YES;
        [self addSubview:_networkNotReachableView];
        [_networkNotReachableView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (self.basePlayerView != nil) {
                make.center.equalTo(self.basePlayerView);
            } else {
                make.center.equalTo(self);
            }
        }];
    }
    return _networkNotReachableView;
}

- (void)showNetworkNotReachableView {
    if (![self canShowPromptView]) {
        return;
    }
    if (!self.controlView.centerPlayButton.hidden) {
        return;
    }
    [self hidePromptViews];
    self.networkNotReachableView.hidden = NO;
}

- (void)hideNetworkNotReachableView {
    self.networkNotReachableView.hidden = YES;
}

#pragma mark - NetworkNotReachableViewDelegate

- (void)networkNotReachableView:(NetworkNotReachableView *)notReachableview retryButtonDidTouch:(UIButton *)button {
    [self pause];
    [self play];
    [self showLoadingView];
}

#pragma mark - NetworkViaWWANView

- (NetworkViaWWANView *)networkViaWWANView {
    if (!_networkViaWWANView) {
        _networkViaWWANView = [[NetworkViaWWANView alloc] init];
        _networkViaWWANView.delegate = self;
        _networkViaWWANView.hidden = YES;
        [self addSubview:_networkViaWWANView];
        [_networkViaWWANView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (self.basePlayerView.videoView != nil) {
                make.center.equalTo(self.basePlayerView);
            } else {
                make.center.equalTo(self);
            }
        }];
    }
    return _networkViaWWANView;
}

- (BOOL)canShowWWANPromptView {
    if (![self canShowPromptView]) {
        return NO;
    }
    return YES;
}

- (void)showNetworkViaWWANView {
    if (!self.controlView.centerPlayButton.hidden) {
        return;
    }
    [self hidePromptViews];
    self.networkViaWWANView.hidden = NO;
    
    [self cancelAutoHideNetworkViaWWANView];
    __weak typeof(self) weakSelf = self;
    self.hideWWANViewBlock = bdld_dispatch_main_after(3.0, ^{
        [weakSelf hideNetworkViaWWANView];
    });
}

- (void)hideNetworkViaWWANView {
    self.networkViaWWANView.hidden = YES;
}

- (void)cancelAutoHideNetworkViaWWANView {
    if (self.hideWWANViewBlock != nil) {
        bdld_cancel_block(self.hideWWANViewBlock);
        self.hideWWANViewBlock = nil;
    }
}

#pragma mark - NetworkViaWWANViewDelegate

- (void)networkViaWWANViewDidTouch:(NetworkViaWWANView *)wwanView {
    [self hideNetworkViaWWANView];
}

#pragma mark - ReplayView

- (PlayerReplayView *)replayView {
    if (!_replayView) {
        _replayView = [[PlayerReplayView alloc] init];
        _replayView.hidden = YES;
        _replayView.delegate = self;
        [self addSubview:_replayView];
    }
    return _replayView;
}

- (void)showReplayView {
    if (![self canShowPromptView]) {
        return;
    }
    [self hidePromptViews];
    self.replayView.hidden = NO;
}

- (void)hideReplayView {
    self.replayView.hidden = YES;
}

- (BOOL)shouldShowReplayView {
    BOOL previewAutoReplay = YES;
    BOOL playbackAutoReplay = YES;
    
    if ([self isVod]
        && BDLPlayerStateStopped == self.basePlayerView.playerState
        && ((BDLActivityStatusPreview == self.status && !previewAutoReplay)
            || (BDLActivityStatusReplay == self.status && !playbackAutoReplay))) {
        return YES;
    }
    return NO;
}

#pragma mark - PlayerReplayViewDelegate

- (void)replayViewDidTouch:(PlayerReplayView *)replayView {
    // Portrait
    [self stop];
    [self.basePlayerView setVodStartTime:0]; // 这里不设置为0.那么关闭自动重播，播放完成显示重播按钮后重新进入直播间，重播按钮不生效
    [self.basePlayerView resetCurrentContinuePlaybackTime];
    [self play];
}

- (void)playerReplayView:(PlayerReplayView *)replayView replayButtonDidTouch:(UIButton *)button {
    // Landscape
    [self stop];
    [self.basePlayerView setVodStartTime:0]; // 这里不设置为0.那么关闭自动重播，播放完成显示重播按钮后重新进入直播间，重播按钮不生效
    [self.basePlayerView resetCurrentContinuePlaybackTime];
    [self play];
}

#pragma mark - PiP

- (void)enablePiP {
    if (@available(iOS 14.0, *)) {
        if (self.isFloating) {
            return;
        }
        if ([self shouldEnableLivePiP] || [self shouldEnableVodPiP]) {
            self.basePlayerView.enablePictureInPicture = YES;
        }
    }
}

- (void)disablePiP {
    if (@available(iOS 14.0, *)) {
        self.basePlayerView.enablePictureInPicture = NO;
    }
}

- (BOOL)isLivePiPConfigEnabled {
    if (@available(iOS 14.0, *)) {
        return YES;
    }
    return NO;
}

- (BOOL)isVodPiPConfigEnabled {
    if (@available(iOS 14.0, *)) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldEnableLivePiP {
    if ([self isLive]
        && [self isLivePiPConfigEnabled]) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldEnableVodPiP {
    if ([self isVod]
        && [self isVodPiPConfigEnabled]) {
        return YES;
    }
    return NO;
}

#pragma mark - Floating

- (BOOL)liveCanFloating {
    if (BDLActivityStatusLive == self.status) {
        return YES;
    }
    return NO;
}

- (BOOL)previewCanFloating {
    if (self.status != BDLActivityStatusPreview) {
        return NO;
    }
    if (![self isVod]) {
        return NO;
    }
    if (CGSizeEqualToSize(self.basePlayerView.videoSize, CGSizeZero)) {
        return NO;
    }
    if (self.basePlayerView.isPlaying) {
        return YES;
    }
    return YES;
}

- (BOOL)replayCanFloating {
    if (self.status != BDLActivityStatusReplay) {
        return NO;
    }
    if (![self isVod]) {
        return NO;
    }
    if (CGSizeEqualToSize(self.basePlayerView.videoSize, CGSizeZero)) {
        return NO;
    }
    if (self.basePlayerView.isPlaying) {
        return YES;
    }
    return YES;
}

- (BOOL)canFloating {
    if (!self.networkNotReachable
        && ([self liveCanFloating]
            || [self previewCanFloating]
            || [self replayCanFloating])) {
        return YES;
    }
    return NO;
}

#pragma mark - FullScreen

- (void)enterFullScreen {
    if (self.isFullScreen) {
        return;
    }
    [self.controlView.fullScreenButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)leaveFullScreen {
    if (!self.isFullScreen) {
        return;
    }
    [self.controlView.fullScreenButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - BDLLanguageService

- (void)languageDidChangeEnable:(BOOL)isLanguageEnabled
                      langTypes:(NSArray<NSNumber *> *)langTypes
            multiLanguageEnable:(BOOL)isMultiLanguageEnabled {
    self.langTypes = langTypes;
}

- (void)languageTypeDidChange:(BDLLanguageType)langType {
    self.langType = langType;
}

#pragma mark - BDLBasicService

- (void)activityStatusDidChange:(BDLActivityStatus)status {
    //NSLog(@"playerView %p activityStatusDidChange status=%@", self, @(status));
    BDLActivityStatus oldStatus = self.status;
    BOOL oldIsVod = [self isVod];
    self.status = status;
    
    [self hideControlView];
    self.controlView.duration = 0.0;
    self.controlView.currentTime = 0.0;
    
    [self hidePromptViews];
    [self hideResolutionView];
    [self hideSpeedView];
    self.isPortraitVideo = NO;
    
    if (@available(iOS 14.0, *)) {
        if ((status == BDLActivityStatusLive && [self isLivePiPConfigEnabled] != self.basePlayerView.enablePictureInPicture)
            || (status == BDLActivityStatusReplay && [self isVodPiPConfigEnabled] != self.basePlayerView.enablePictureInPicture)
            || (status == BDLActivityStatusPreview && [self isVodPiPConfigEnabled] != self.basePlayerView.enablePictureInPicture)) {
            [self disablePiP];
            [self enablePiP];
        }
    }
    
    BDLBasicModel *basic = [self.svc getActivityModel].basic;
    switch (status) {
        case BDLActivityStatusLive:
            self.isVod = NO;
            if ([self shouldAutoPlay]) {
                [self showControlViewIfNeededWithAutoHide:YES];
            } else {
                [self showControlViewIfNeededWithAutoHide:NO];
            }
            break;
        case BDLActivityStatusPreview:
            if (basic.previewVideoUrl) {
                [self showControlViewIfNeededWithAutoHide:YES];
            }
            [self previewVideoDidChange:basic.previewVideoUrl isEnabled:basic.isPreviewVideoEnable];
            self.basePlayerView.looping = YES;
            
            if (![self shouldAutoPlay]) {
                [self showControlViewIfNeededWithAutoHide:NO];
            }
            break;
        case BDLActivityStatusReplay:
            [self replaysDidChange:basic.replays currentSelectedIndex:[self.svc getCurrentMediaIndex]];
            self.basePlayerView.looping = YES;
            
            if ([self shouldAutoPlay]) {
                [self showControlViewIfNeededWithAutoHide:YES];
            } else {
                [self showControlViewIfNeededWithAutoHide:NO];
            }
            break;
        case BDLActivityStatusEnd:
            self.isVod = NO;
            [self hideControlView];
            if (self.isFullScreen) {
                [self leaveFullScreen];
            }
            break;
        default:
            self.isVod = NO;
            break;
    }
    
    [self refreshConstraints];
    
    // 设置首次播放标志位
    self.isFirstPlay = YES;
    

    if ((BDLActivityStatusLive == oldStatus
         || oldIsVod)
        && status != BDLActivityStatusLive
        && ![self isVod]) {
        // 从直播或点播状态切到非直播也非点播状态，触发播放结束事件
        if ([self.delegate respondsToSelector:@selector(playerView:didFinishPlayingWithIsLive:)]) {
            [self.delegate playerView:self didFinishPlayingWithIsLive:BDLActivityStatusLive == oldStatus];
        }
    }
}

- (void)vodVideoIdDidChange:(NSString *)vid {
    if (vid) {
        self.isVod = YES;
        if (![self.vodId isEqualToString:vid]) { // 视频变了，
            [self resetVodPlayer];
            self.vodId = vid;
        }
    } else {
        self.isVod = NO;
    }
}

- (void)previewVideoDidChange:(NSString *)url isEnabled:(BOOL)isEnabled {
    //NSLog(@"playerView %p previewVideoDidChange isEnabled=%d", self, isEnabled);
    if (self.status != BDLActivityStatusPreview) {
        return;
    }
    BOOL oldIsVod = [self isVod];
    [self vodVideoIdDidChange:url];
    
    if ([self shouldAutoPlay]) {
        [self showControlViewIfNeededWithAutoHide:YES];
    }
    if (!url) {
        // 没有预告片时，隐藏其它提示界面，显示预告文案
        [self hidePromptViews];
    }
    if (oldIsVod && !self.isVod) {
        // 预告视频从有到无，通知播放完成
        if ([self.delegate respondsToSelector:@selector(playerView:didFinishPlayingWithIsLive:)]) {
            [self.delegate playerView:self didFinishPlayingWithIsLive:NO];
        }
    }
}

- (void)replaysDidChange:(NSArray<BDLReplayModel *> *)replays currentSelectedIndex:(NSUInteger)currentSelectedIndex{
    if (self.status != BDLActivityStatusReplay
        || replays.count <= currentSelectedIndex) {
        return;
    }
    NSString *vid = replays[currentSelectedIndex].vid;
    [self vodVideoIdDidChange:vid];
}

#pragma mark - Notification

- (void)onApplicationDidEnterBackgroundNotification:(NSNotification *)ntf {
    //NSLog(@"onApplicationDidEnterBackgroundNotification");
    if (BDLActivityStatusLive == self.status) {
        // 直播状态优先考虑是否开启小窗，不开启小窗与关闭后台音频播放时暂停播放
        if (![self isLivePiPConfigEnabled]) {
            [self pause];
        }
    } else if (BDLActivityStatusPreview == self.status || BDLActivityStatusReplay == self.status) {
        if (![self isVodPiPConfigEnabled]) {
            [self pause];
        }
    }
}

- (BOOL)shouldAutoPlayWhenEnterForeground {
    return YES;
}

- (void)onApplicationWillEnterForegroundNotification:(NSNotification *)ntf {
    //NSLog(@"onApplicationWillEnterForegroundNotification");
    if ([self shouldAutoPlayWhenEnterForeground]
        || self.shouldPlayWhenForeground) {
        // 从后台切回前台时，当是直播状态时默认会触发播放
        [self play];
        self.shouldPlayWhenForeground = NO;
    }
}

- (void)onNetworkDidChangeNotification:(NSNotification *)ntf {
    self.networkStatus = [ntf.userInfo[BDLNetworkNotificationStatusKey] integerValue];
    switch (self.networkStatus) {
        case BDLNetworkStatusUnknown:
            break;
        case BDLNetworkStatusNotReachable:
            // 断网后设置标志，等待缓冲播放完再弹出提示
            self.networkNotReachable = YES;
            // 断网后关闭画中画能力
            [self disablePiP];
            break;
        case BDLNetworkStatusReachableViaWWAN:
            // 断网后重连，开启画中画能力
            if (self.networkNotReachable) {
                [self enablePiP];
            }
            self.networkNotReachable = NO;
            if (BDLActivityStatusUnknown == self.status
                || self.isFetchVodUrlFailed
                || !self.basePlayerView.isFirstVideoFrameRendered) {
                break;
            }
            
            [self hidePromptViews];
            [self showNetworkViaWWANView];
            
            // 点播时，断网过久重新连接后需要再次调用 play
            if (!self.basePlayerView.isPlaying
                && self.status != BDLActivityStatusLive
                && self.controlView.playButton.selected) {
                [self pause];
                [self play];
            }
            break;
        case BDLNetworkStatusReachableViaWiFi:
            // 断网后重连，开启画中画能力
            if (self.networkNotReachable) {
                [self enablePiP];
            }
            self.networkNotReachable = NO;
            if (BDLActivityStatusUnknown == self.status) {
                break;
            }
            [self hidePromptViews];
            
            // 点播时，断网过久重新连接后需要再次调用 play
            if (!self.basePlayerView.isPlaying
                && self.status != BDLActivityStatusLive
                && self.controlView.playButton.selected) {
                [self pause];
                [self play];
            }
            break;
        default:
            break;
    }
}

// MARK: - lazy

- (id<BDLActivityService>)svc {
    if (!_svc) {
        _svc = [[BDLLiveEngine sharedInstance] getActivityService];
    }
    return _svc;
}

@end
