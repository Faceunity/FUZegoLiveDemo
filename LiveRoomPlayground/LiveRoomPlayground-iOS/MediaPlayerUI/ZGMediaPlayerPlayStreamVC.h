//
//  ZGMediaPlayerPlayStreamVC.h
//  LiveRoomPlayground-iOS
//
//  Created by jeffreypeng on 2019/8/23.
//  Copyright © 2019 Zego. All rights reserved.
//
#ifdef _Module_MediaPlayer

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGMediaPlayerPlayStreamVC : UIViewController

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *streamID;

+ (instancetype)instanceFromStoryboard;

@end

NS_ASSUME_NONNULL_END
#endif
