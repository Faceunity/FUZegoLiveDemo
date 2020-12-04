# FUZegoLiveDemo 快速集成文档

FUZegoLiveDemo 是集成了 Faceunity 面部跟踪和虚拟道具功能 和 [LiveRoomPlayground](https://doc-zh.zego.im/zh/3142.html) 功能的 Demo。

本文是 FaceUnity SDK 快速对接 Zego 互动视频 的导读说明，关于 `FaceUnity SDK` 的详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)


## 快速集成方法

### 一、接入 FaceUnitySDK

- 目前项目使用 `Pods` 管理, Nama 最新版本7.2.0,详情查看`Podfile`文件
    
- 添加依赖库 `OpenGLES.framework`、`Accelerate.framework`、`CoreMedia.framework`、`AVFoundation.framework`、`libc++.tbd`、`CoreML.framework`

- 备注: 上述NamaSDK 依赖库使用 Pods 管理 会自动添加依赖,运行在iOS11以下系统时,需要手动添加`CoreML.framework`,并在**TARGETS -> Build Phases-> Link Binary With Libraries**将`CoreML.framework`手动修改为可选**Optional**

- 美颜UI以及业务管理类 参见 LiveRoomPlayground-iOS/ExternalVideoFilterUI/FaceUnityUI
    
    - FUAPIDemoBar 美颜工具条
    - items 美妆贴纸资源
    - 其他的业务类

### 二、加入展示 FaceUnity SDK 美颜贴纸效果的  UI

在 ZGExternalVideoFilterPublishViewController.m  中添加头文件，并创建页面属性

```C
/**faceU */
#import "FUManager.h"
#import "FUAPIDemoBar.h"

@property (nonatomic, strong) FUAPIDemoBar *demoBar;

```

2、遵循FaceUnity美颜 demoBar 的代理方法 `FUAPIDemoBarDelegate`, 实现代理方法

#### 切换贴纸

```C
// 切换贴纸
-(void)bottomDidChange:(int)index{
    if (index < 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeBeautify];
    }
    if (index == 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeStrick];
    }
    
    if (index == 4) {
        [[FUManager shareManager] setRenderType:FUDataTypeMakeup];
    }
    if (index == 5) {
        [[FUManager shareManager] setRenderType:FUDataTypebody];
    }
}

```

#### 更新美颜参数

```C
// 更新美颜参数    
- (void)filterValueChange:(FUBeautyParam *)param{
    [[FUManager shareManager] filterValueChange:param];
}
```

### 三、在 `viewDidLoad:` 调用 `setupFaceUnity` 方法 初始化SDK,并将`demoBar`添加到页面上

```C
    [[FUManager shareManager] loadFilter];
    [FUManager shareManager].isRender = YES;
    [FUManager shareManager].flipx = NO;
    [FUManager shareManager].trackFlipx = NO;
    
    // 设置屏幕底部的 FaceUnity 美颜控制条
    _demoBar = [[FUAPIDemoBar alloc] init];
    _demoBar.mDelegate = self;
    [self.view addSubview:_demoBar];
    [_demoBar mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(195);
    }];

```

### 四、获取视频数据回调

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
### 五、销毁道具

1 视图控制器生命周期结束时,销毁道具
```C
[[FUManager shareManager] destoryItems];
```

2 切换摄像头需要调用,切换摄像头
```C
[[FUManager shareManager] onCameraChange];
```

### 关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)


