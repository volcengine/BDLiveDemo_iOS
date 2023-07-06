#import <Masonry/Masonry.h>

#import "PlayerFullScreenViewController.h"

@interface PlayerFullScreenViewController () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIView *fullScreenView;

@end

@implementation PlayerFullScreenViewController

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        self.fullScreenView = view;
        self.transitioningDelegate = self;
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view addSubview:self.fullScreenView];
    [self.fullScreenView mas_remakeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}

#pragma mark - UIViewControllerRotation

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeRight) {
        return UIInterfaceOrientationLandscapeLeft;
    }
    return UIInterfaceOrientationLandscapeRight;
}

@end
