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

#if __has_include(<AliyunVideoSDKPro/AliyunVideoSDKInfo.h>)
#import <AliyunVideoSDKPro/AliyunVideoSDKInfo.h>
#endif

@implementation PYShortVideoBridge

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(videoShooting:(NSString *)s) {
  dispatch_async(dispatch_get_main_queue(), ^{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *recordParam = [[AlivcShortVideoRoute shared] makeRecordControllerWithWord:s];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:recordParam];
    [nav setNavigationBarHidden:YES];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [appDelegate.window.rootViewController presentViewController:nav animated:YES completion:nil];
  });
  
}

@end
