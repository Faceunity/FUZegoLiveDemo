# FUZegoLiveDemo 快速集成文档

FUZegoLiveDemo 是集成了 Faceunity 面部跟踪和虚拟道具功能 和 [LiveRoomPlayground](https://doc-zh.zego.im/zh/3142.html) 功能的 Demo。

本文是 FaceUnity SDK 快速对接 Zego 互动视频 的导读说明，关于 `FaceUnity SDK` 的详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo)


## 快速集成方法

### 一、导入 SDK

将  FaceUnity  文件夹全部拖入工程中，NamaSDK所需依赖库为 `OpenGLES.framework`、`Accelerate.framework`、`CoreMedia.framework`、`AVFoundation.framework`、`libc++.tbd`、`CoreML.framework`

- 备注: 运行在iOS11以下系统时,需要手动添加`CoreML.framework`,并在**TARGETS -> Build Phases-> Link Binary With Libraries**将`CoreML.framework`手动修改为可选**Optional**

### FaceUnity 模块简介

```objc
+ Abstract          // 美颜参数数据源业务文件夹
    + FUProvider    // 美颜参数数据源提供者
    + ViewModel     // 模型视图参数传递者
-FUManager          //nama 业务类
-authpack.h         //权限文件  
+FUAPIDemoBar     //美颜工具条,可自定义
+items            //美妆贴纸 xx.bundel文件

```


### 二、加入展示 FaceUnity SDK 美颜贴纸效果的  UI

1、在 ZGExternalVideoFilterPublishViewController.m  中添加头文件
```C
/** faceu */
#import "FUManager.h"
#import "FUTestRecorder.h"
#import "UIViewController+FaceUnityUIExtension.h"
```
2、在 `viewDidLoad` 方法中初始化FU `setupFaceUnity` 会初始化FUSDK,和添加美颜工具条,具体实现可查看 `UIViewController+FaceUnityUIExtension.m`
```objc
[self setupFaceUnity];
```

### 三、获取视频数据回调

- 参照官网和源码查看添加视频滤镜 [视频外部滤镜](https://doc-zh.zego.im/zh/1774.html)

- 根据测试性能所得,有两种外部滤镜性能不错
    - ZGVideoFilterNV12Demo 异步 NV12 类型外部滤镜实现
    - ZGVideoFilterSyncDemo 同步类型外部滤镜实现
    
- ZGVideoFilterNV12Demo 数据处理

```C
// SDK 回调。App 在此接口中获取 SDK 采集到的视频帧数据，并进行处理
- (void)queueInputBuffer:(CVPixelBufferRef)pixel_buffer timestamp:(unsigned long long)timestamp_100n {
    // * 采集到的图像数据通过这个传进来，这个点需要异步处理
    dispatch_async(queue_, ^ {
        int imageWidth = (int)CVPixelBufferGetWidth(pixel_buffer);
        int imageHeight = (int)CVPixelBufferGetHeight(pixel_buffer);
        int imageStride = (int)CVPixelBufferGetBytesPerRowOfPlane(pixel_buffer, 0);
        
        CVPixelBufferRef dst = [self->buffer_pool_ dequeueInputBuffer:imageWidth height:imageHeight stride:imageStride];
        
        if (dst) {
            // 自定义前处理：此处使用 FaceUnity 作为外部滤镜 420f
            [[FUTestRecorder shareRecorder] processFrameWithLog];
            CVPixelBufferRef output = [[FUManager shareManager] renderItemsToPixelBuffer:pixel_buffer];
            
            if ([ZGImageUtils copyPixelBufferFrom:output to:dst]) {
                // * 把从 buffer pool 中得到的 CVPixelBuffer 实例传进来
                [self->buffer_pool_ queueInputBuffer:dst timestamp:timestamp_100n];
            }
        }
        
        self.pendingCount = self.pendingCount - 1;
        CVPixelBufferRelease(pixel_buffer);
    });
}

```

- ZGVideoFilterSyncDemo 数据处理

```objc
- (void)onProcess:(CVPixelBufferRef)pixel_buffer withTimeStatmp:(unsigned long long)timestamp_100 {
    // * 采集到的图像数据通过这个传进来，同步处理完返回处理结果
    
    // 自定义前处理：此处使用 FaceUnity 作为外部滤镜6 BGRA
    [[FUTestRecorder shareRecorder] processFrameWithLog];

    CVPixelBufferRef output = [[FUManager shareManager] renderItemsToPixelBuffer:pixel_buffer];
    
    [delegate_ onProcess:output withTimeStatmp:timestamp_100];
}
```
### 四、销毁道具

1 视图控制器生命周期结束时,销毁道具
```C
[[FUManager shareManager] destoryItems];
```

2 切换摄像头需要调用,切换摄像头
```C
[[FUManager shareManager] onCameraChange];
```

### 关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo)


