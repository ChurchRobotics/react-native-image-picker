//
//  PYShortVideoBridge.m
//  example
//
//  Created by jimmy on 2021/1/21.
//

#import "PYShortVideoBridge.h"
#import <React/RCTBridge.h>
#import "AppDelegate.h"

#import <AVFoundation/AVFoundation.h>

#import "AlivcMacro.h"
#import "AlivcShortVideoRoute.h"
#import "PYNavigationController.h"
#import "AliVideoClientUser.h"
#import "AlivcShortVideoUploadManager.h"
#import <AlivcEdit/PYOutputVideoInfo.h>

#if __has_include(<AliyunVideoSDKPro/AliyunVideoSDKInfo.h>)
#import <AliyunVideoSDKPro/AliyunVideoSDKInfo.h>
#endif

@implementation PYShortVideoBridge

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(videoShooting:(NSString *)s) {
  dispatch_async(dispatch_get_main_queue(), ^{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *recordParam = [[AlivcShortVideoRoute shared] makeRecordControllerWithWord:s];
    PYNavigationController *nav = [[PYNavigationController alloc] initWithRootViewController:recordParam];
    [nav setNavigationBarHidden:YES];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [appDelegate.window.rootViewController presentViewController:nav animated:YES completion:nil];
  });
  
}

RCT_EXPORT_METHOD(setValueWithInfo:(NSDictionary *)info){
  
}

/*
 videoPath  //视频所在路径
 coverImageUrl //封面图的URL
 videoTitle  //标题
 videoDesc  //描述
 videoTags //视频点播参数，标签
 */
/// 回传数组到RN端
RCT_EXPORT_METHOD(outputVideoInfo:(RCTResponseSenderBlock)callback) {
  if (callback) {
    PYOutputVideoInfo *videoInfo = [PYOutputVideoInfo shared];
    
    NSDictionary *videoParams = @{
      @"videoPath":videoInfo.videoPath,
      @"coverImageUrl":videoInfo.coverImageUrl,
      @"videoTitle":videoInfo.videoTitle
    };
    callback(@[[NSNull null],videoParams]);
  }
}


@end
