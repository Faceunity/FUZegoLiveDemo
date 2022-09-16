//
//  ZGExternalVideoFilterPublishViewController.m
//  LiveRoomPlayground-iOS
//
//  Created by Paaatrick on 2019/7/22.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_ExternalVideoFilter

#import "ZGExternalVideoFilterPublishViewController.h"
#import "ZGExternalVideoFilterDemo.h"

/** faceu */
#import "FUDemoManager.h"


@interface ZGExternalVideoFilterPublishViewController () <ZGExternalVideoFilterDemoProtocol>


@property (nonatomic, strong) ZGExternalVideoFilterDemo *demo;

@property (weak, nonatomic) IBOutlet UILabel *publishQualityLabel;
@property (weak, nonatomic) IBOutlet UISwitch *previewMirrorSwitch;

@property (nonatomic, assign) BOOL enablePreviewMirror;
@property(nonatomic, strong) FUDemoManager *demoManager;

@end

@implementation ZGExternalVideoFilterPublishViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:(UIBarButtonItemStyleDone) target:self action:@selector(backClick)];
    
    self.demo = [[ZGExternalVideoFilterDemo alloc] init];
    self.demo.delegate = self;
    self.demo.isuseFU = self.isuseFU;
    
    // 先加载外部滤镜工厂
    [self.demo initFilterFactoryType:self.selectedFilterBufferType];
    
    // 然后初始化 ZegoLiveRoom SDK
    [self.demo initSDKWithRoomID:self.roomID streamID:self.streamID isAnchor:YES];
    
    // 初始化美颜
    if (self.isuseFU) {
        
        // FaceUnity UI
        CGFloat safeAreaBottom = 0;
        if (@available(iOS 11.0, *)) {
            safeAreaBottom = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
        }
        self.demoManager = [[FUDemoManager alloc] initWithTargetController:self originY:CGRectGetHeight(self.view.frame) - FUBottomBarHeight - safeAreaBottom - 88];
    }
    
    
     //预览镜像
    self.enablePreviewMirror = YES;
    self.previewMirrorSwitch.on = self.enablePreviewMirror;
    
    [self.demo loginRoom];
    [self.demo startPreview];
    [self.demo enablePreviewMirror:self.enablePreviewMirror];
    [self.demo startPublish];
}


- (void)backClick{
    
    [self.demo stopPreview];
    [self.demo stopPublish];
    [self.demo logoutRoom];
    self.demo = nil;

    if (self.isuseFU) {
    
        [[FUManager shareManager] destoryItems];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)onSwitchPreviewMirror:(UISwitch *)sender {
    self.enablePreviewMirror = sender.on;
    [self.demo enablePreviewMirror:self.enablePreviewMirror];
}


#pragma mark - ZGExternalVideoFilterDemoProtocol
- (nonnull UIView *)getPlaybackView {
    return self.view;
}

- (void)onExternalVideoFilterPublishStateUpdate:(NSString *)state {
    self.title = state;
}

- (void)onExternalVideoFilterPublishQualityUpdate:(NSString *)state {
    self.publishQualityLabel.text = state;
}

@end

#endif
