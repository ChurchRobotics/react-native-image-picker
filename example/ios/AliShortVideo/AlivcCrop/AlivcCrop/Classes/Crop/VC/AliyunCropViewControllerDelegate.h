//
//  AliyunCropViewControllerDelegate.h
//  AlivcCrop
//
//  Created by jimmy on 2021/2/18.
//

#import <UIKit/UIKit.h>
#import "AliyunMediaConfig.h"

@protocol AliyunCropViewControllerDelegate <NSObject>

/**
 退出了裁剪界面
 */
- (void)cropViewControllerExit;

/**
 裁剪完成

 @param mediaInfo 裁剪配置
 @param controller 裁剪的试图控制器
 */
- (void)cropViewControllerFinish:(AliyunMediaConfig *)mediaInfo viewController:(UIViewController *)controller;

- (void)cropViewControllerFinish:(AliyunMediaConfig *)mediaInfo coverImage:(UIImage *)image viewController:(UIViewController *)controller;

- (void)cropViewControllerFakeFinish:(AliyunMediaConfig *)mediaInfo viewController:(UIViewController *)controller;
@end
