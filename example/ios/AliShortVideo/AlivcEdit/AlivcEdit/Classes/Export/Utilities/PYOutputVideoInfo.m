//
//  PYOutputVideoInfo.m
//  example
//
//  Created by jimmy on 2021/2/3.
//

#import "PYOutputVideoInfo.h"

@interface PYOutputVideoInfo ()
@property(nonatomic, strong) NSString *videoPath;
@property(nonatomic, strong) NSString *coverImageUrl;
@property(nonatomic, strong) NSString *videoTitle;
@property(nonatomic, assign) CGSize videoSize;
@end

@implementation PYOutputVideoInfo

static PYOutputVideoInfo *_instance = nil;
+ (instancetype)shared {
  if (_instance == nil) {
    _instance = [[PYOutputVideoInfo alloc]init];
  }
  return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
  if (_instance == nil) {
    _instance = [super allocWithZone:zone];
  }
  return _instance;
}

- (id)copy {
  return self;
}

- (id)mutableCopy {
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
  return self;
}


- (void)setCoverImagePath:(NSString *)imagePath
               videoTitle:(NSString *)videoTitle
                videoSize:(CGSize)videoSize
                videoPath:(NSString *)videoPath;
{
  self.coverImageUrl = imagePath;
  self.videoTitle = videoTitle;
  self.videoSize = videoSize;
  self.videoPath = videoPath;
}

@end
