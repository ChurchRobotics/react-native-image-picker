//
//  PYOutputVideoInfo.h
//  example
//
//  Created by jimmy on 2021/2/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PYOutputVideoInfo : NSObject

@property(nonatomic, strong, readonly) NSString *videoPath;
@property(nonatomic, strong, readonly) NSString *coverImageUrl;
@property(nonatomic, strong, readonly) NSString *videoTitle;
@property(nonatomic, assign, readonly) CGSize videoSize;

+ (instancetype)shared;
/// 设置视频输出信息
/// @param imagePath 图片地址
/// @param videoTitle 视频标题
/// @param videoSize 视频大小
/// @param videoPath 视频路径
- (void)setCoverImagePath:(NSString *)imagePath
               videoTitle:(NSString *)videoTitle
                videoSize:(CGSize)videoSize
                videoPath:(NSString *)videoPath;

@end

NS_ASSUME_NONNULL_END
