//
//  ZGVideoFilterSyncDemo.m
//  LiveRoomPlayground-iOS
//
//  Created by Paaatrick on 2019/7/30.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_ExternalVideoFilter

#import "ZGVideoFilterSyncDemo.h"
#import "ZGApiManager.h"

#if TARGET_OS_OSX
#import "FUManager-mac.h"
#elif TARGET_OS_IOS
#import "FUDemoManager.h"
#import "FUTestRecorder.h"

#endif

@implementation ZGVideoFilterSyncDemo {
    id<ZegoVideoFilterClient> client_;
    id<ZegoVideoFilterDelegate> delegate_;
}

#pragma mark -- ZegoVideoFilter Delgate

// 初始化外部滤镜使用的资源
- (void)zego_allocateAndStart:(id<ZegoVideoFilterClient>) client {
    client_ = client;
    if ([client_ conformsToProtocol:@protocol(ZegoVideoFilterDelegate)]) {
        delegate_ = (id<ZegoVideoFilterDelegate>)client;
    }
}

// 停止并释放外部滤镜占用的资源
- (void)zego_stopAndDeAllocate {
    [client_ destroy];
    client_ = nil;
    delegate_ = nil;
}

- (ZegoVideoBufferType)supportBufferType {
    // * 返回滤镜的类型：此滤镜为同步滤镜
    return ZegoVideoBufferTypeSyncPixelBuffer;
}

#pragma mark -- ZegoVideoFilterDelegate Delegate

- (void)onProcess:(CVPixelBufferRef)pixel_buffer withTimeStatmp:(unsigned long long)timestamp_100 {
    
    // 自定义前处理：此处使用 FaceUnity 作为外部滤镜
//    CVPixelBufferRef output = [[FUManager shareManager] renderItemsToPixelBuffer:pixel_buffer];
    
    [[FUDemoManager shared] checkAITrackedResult];
    if ([FUDemoManager shared].shouldRender) {
        [[FUTestRecorder shareRecorder] processFrameWithLog];
        [FUDemoManager updateBeautyBlurEffect];
        FURenderInput *input = [[FURenderInput alloc] init];
        input.renderConfig.imageOrientation = FUImageOrientationUP;
        input.renderConfig.isFromFrontCamera = YES;
        input.renderConfig.stickerFlipH = YES;
        input.pixelBuffer = pixel_buffer;
        //开启重力感应，内部会自动计算正确方向，设置fuSetDefaultRotationMode，无须外面设置
        input.renderConfig.gravityEnable = YES;
        FURenderOutput *output = [[FURenderKit shareRenderKit] renderWithInput:input];
        if(output){
            pixel_buffer = output.pixelBuffer;
        }
    }
    
    
    [delegate_ onProcess:pixel_buffer withTimeStatmp:timestamp_100];
}

@end


#endif
