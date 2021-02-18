//
//  PYCropViewController.h
//  AlivcEdit
//
//  Created by jimmy on 2021/2/10.
//

#import <UIKit/UIKit.h>
#import "AliyunMediaConfig.h"
#import "AliyunCropViewControllerDelegate.h"

@interface PYCropViewController : UIViewController
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
@property (nonatomic, strong) void(^finishHandler)(UIImage *image);
@end


