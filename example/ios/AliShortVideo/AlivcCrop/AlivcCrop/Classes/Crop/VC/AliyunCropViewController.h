//
//  AliyunCropViewController.h
//  AliyunVideo
//
//  Created by dangshuai on 17/1/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunMediaConfig.h"
#import "AliyunCropViewControllerDelegate.h"


@interface AliyunCropViewController : UIViewController

/**
 视频配置
 */
@property (nonatomic, strong) AliyunMediaConfig *cutInfo;

/**
 代理
 */
@property (nonatomic, weak) id<AliyunCropViewControllerDelegate> delegate;

/**
 假裁剪，获取裁剪时间段，不真正裁剪视频
 */
@property (nonatomic, assign) BOOL fakeCrop;
@end



