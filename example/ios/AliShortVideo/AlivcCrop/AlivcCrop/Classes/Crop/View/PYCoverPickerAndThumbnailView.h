//
//  PYCoverPickerAndThumbnailView.h
//  AlivcEdit
//
//  Created by jimmy on 2021/2/10.
//

#import <UIKit/UIKit.h>

@protocol PYCoverPickerAndThumbnailViewDelegate<NSObject>
- (void)pickViewDidUpdateImage:(UIImage *)image;

- (void)cutBarDidMovedToTime:(CGFloat)time;

- (void)cutBarTouchesDidEnd;
@end

@class AVAsset;
@class AliyunMediaConfig;
@interface PYCoverPickerAndThumbnailView : UIView

@property (nonatomic, weak) id<PYCoverPickerAndThumbnailViewDelegate> delegate;

@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) AVAsset *avAsset;

/**
 初始化方法

 @param frame frame
 @param cutInfo 视频资源
 @return 实例化对象
 */
- (instancetype)initWithFrame:(CGRect)frame withCutInfo:(AliyunMediaConfig *)cutInfo;

/**
 加载缩略图资源
 */
- (void)loadThumbnailData;


@end


