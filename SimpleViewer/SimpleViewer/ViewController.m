//   
//   ViewController.m
//   BDLive
// 
//   BDLive SDK License
//   
//   Copyright 2022 Beijing Volcano Engine Technology Ltd. All Rights Reserved.
//   
//   The BDLive SDK was developed by Beijing Volcanoengine Technology Ltd. (hereinafter “Volcano Engine”). Any copyright or patent right is owned by and proprietary material of the Volcano Engine. 
//   
//   BDLive SDK is available under the VolcLive product and licensed under the commercial license.  Customers can contact service@volcengine.com for commercial licensing options.  Here is also a link to subscription services agreement: https://www.volcengine.com/docs/6256/68938.
//   
//   Without Volcanoengine's prior written permission, any use of BDLive SDK, in particular any use for commercial purposes, is prohibited. This includes, without limitation, incorporation in a commercial product, use in a commercial service, or production of other artefacts for commercial purposes. 
//   
//   Without Volcanoengine's prior written permission, the BDLive SDK may not be reproduced, modified and/or made available in any form to any third party. 
//   


#import "ViewController.h"

#import <BDLive/BDLive.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *activityIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *tokenTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *portraitSegmentControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.activityIDTextField.text = @"1678089977360392";
    self.tokenTextField.text = @"JQCFns";
}

- (IBAction)joinRoomAction:(UIButton *)sender {
    NSNumber *activityId = @(self.activityIDTextField.text.integerValue);
    NSString *token = self.tokenTextField.text;
    BOOL isPortrait = self.portraitSegmentControl.selectedSegmentIndex == 1;

    BDLActivity *activity = [[BDLActivity alloc] init];
    activity.activityId = activityId;
    activity.token = token;
    activity.isPortrait = isPortrait;
    activity.authMode = BDLActivityAuthModePublic;

    [[BDLLiveEngine sharedInstance] joinLiveRoomWithActivity:activity];
}

@end
