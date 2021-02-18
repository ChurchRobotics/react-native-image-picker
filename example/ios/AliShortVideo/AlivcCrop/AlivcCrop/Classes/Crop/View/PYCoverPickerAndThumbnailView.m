//
//  PYCoverPickerAndThumbnailView.m
//  AlivcEdit
//
//  Created by jimmy on 2021/2/10.
//

#import "PYCoverPickerAndThumbnailView.h"
#import "AVAsset+VideoInfo.h"
#import "AVC_ShortVideo_Config.h"
#import <AVFoundation/AVFoundation.h>
#import <AlivcCommon/UIColor+AlivcHelper.h>
#import "AliyunMediaConfig.h"

@interface PYCoverPickerAndThumbnailView ()
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UIImageView *progressView;
@property(nonatomic, strong) NSMutableArray *imagesArray;
@property(nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property(nonatomic, strong) AVAssetImageGenerator *pickGenerator;
@property(nonatomic, assign) CGFloat duration;
@property(nonatomic, assign) BOOL imageCaptured;

@property (nonatomic, strong) AliyunMediaConfig *cutInfo;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIImageView *arrowIconLeft;  //左边箭头
@property (nonatomic, strong) UIImageView *arrowIconLeftMask;

@property (nonatomic, strong) UIImageView *arrowIconRight;//右边箭头
@property (nonatomic, strong) UIImageView *arrowIconRightMask;

@property (nonatomic, strong) UIImageView *imageViewSelected;
@property (nonatomic, strong) UIImageView *topLineView;
@property (nonatomic, strong) UIImageView *underLineView;

@property (nonatomic, assign) NSInteger arrowIconWidth;//左右划的箭头宽度
@end

static const NSInteger thumbnailNumbers = 8;
static const CGFloat collectionViewHeight = 58.0;

@implementation PYCoverPickerAndThumbnailView

- (instancetype)initWithFrame:(CGRect)frame withCutInfo:(AliyunMediaConfig *)cutInfo{
    self = [super initWithFrame:frame];
    if (self) {
        _cutInfo = cutInfo;
        _imagesArray = [NSMutableArray arrayWithCapacity:thumbnailNumbers];
        [self setupCollectionView];
        [self setupSubviews];
    }
    return self;
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *followLayout = [[UICollectionViewFlowLayout alloc] init];
    followLayout.itemSize = CGSizeMake(self.frame.size.width/thumbnailNumbers, collectionViewHeight);
    followLayout.minimumLineSpacing = 0;
    followLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 12, self.frame.size.width, collectionViewHeight) collectionViewLayout:followLayout];
    _collectionView.dataSource = (id<UICollectionViewDataSource>)self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    _collectionView.layer.cornerRadius = 9;
    _collectionView.layer.masksToBounds = YES;
    _collectionView.bounces = NO;
    [self addSubview:_collectionView];
}

- (void)setupSubviews {
    
    //还剩多少时间
    _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, ScreenWidth - 200, 12)];
    _durationLabel.center = CGPointMake(self.frame.size.width/2, 0);
    _durationLabel.textColor = RGBToColor(240, 84, 135);
    _durationLabel.textAlignment = 1;
    _durationLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:_durationLabel];
    
    _arrowIconWidth = self.frame.size.width / thumbnailNumbers * 0.4;
    _arrowIconLeft = [[UIImageView alloc] initWithImage:[AliyunImage imageNamed:@"cut_bar_left"]];
    _arrowIconLeft.frame = CGRectMake(0, 12, _arrowIconWidth, collectionViewHeight);
    _arrowIconLeft.userInteractionEnabled = YES;
    
    _arrowIconRight = [[UIImageView alloc] initWithImage:[AliyunImage imageNamed:@"cut_bar_right"]];
    _arrowIconRight.frame = CGRectMake(self.frame.size.width - _arrowIconWidth, 12, _arrowIconWidth, collectionViewHeight);
    _arrowIconRight.userInteractionEnabled = YES;
    
    //上下线框
    _topLineView = [[UIImageView alloc]initWithFrame:CGRectMake(_arrowIconWidth - 3 , 12, self.frame.size.width - _arrowIconWidth *2 + 6, 3)];
    _topLineView.backgroundColor =[UIColor colorWithRed:101/255.0 green:31/255.0 blue:255/255.0 alpha:1.0];
    
    _underLineView = [[UIImageView alloc]initWithFrame:CGRectMake(_arrowIconWidth - 3, _arrowIconLeft.frame.size.height + 12 - 3  , self.frame.size.width - _arrowIconWidth *2 + 6, 3)];
    _underLineView.backgroundColor = [UIColor colorWithRed:101/255.0 green:31/255.0 blue:255/255.0 alpha:1.0];
    
    [self addSubview:_topLineView];
    [self addSubview:_underLineView];
    
    [self addSubview:_arrowIconLeft];
    [self addSubview:_arrowIconRight];
    
    
    _arrowIconLeftMask = [[UIImageView alloc]initWithFrame:CGRectMake(0, 12, 0, _arrowIconLeft.frame.size.height)];
    _arrowIconRightMask = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_arrowIconRight.frame), 12, 0, _arrowIconLeft.frame.size.height)];
    
    _arrowIconLeftMask.backgroundColor = [AliyunIConfig config].backgroundColor;
    _arrowIconLeftMask.alpha = 0.8;
    _arrowIconRightMask.backgroundColor = [AliyunIConfig config].backgroundColor;
    _arrowIconRightMask.alpha = 0.8;
    
    [self addSubview:_arrowIconLeftMask];
    [self addSubview:_arrowIconRightMask];
    
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    view.backgroundColor = [UIColor clearColor];
    [self addSubview:view];
    _progressView = [UIImageView new];
    _progressView.backgroundColor = [UIColor whiteColor];
    _progressView.layer.cornerRadius = 2;
    _progressView.layer.masksToBounds = YES;
    _progressView.frame = CGRectMake(self.frame.size.width/2-2, 12, 4, self.frame.size.height-12);
    
    [view addSubview:_progressView];
}

- (void)parseAsset {
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:_cutInfo.outputPath]];
    _duration = [asset avAssetVideoTrackDuration];
}

- (void)loadThumbnailData {
    [self parseAsset];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.durationLabel.text = [NSString stringWithFormat:@"%.2f",self.duration];
    });
    _selectedImage = [self coverImageAtTime:CMTimeMake(0.1 * 1000, 1000)];
    [_delegate pickViewDidUpdateImage:_selectedImage];
    
    CMTime startTime = kCMTimeZero;
    NSMutableArray *array = [NSMutableArray array];
    CMTime addTime = CMTimeMake(_duration * 1000 / (thumbnailNumbers-1), 1000);
    
    CMTime endTime = CMTimeMake(_duration * 1000, 1000);
    
    while (CMTIME_COMPARE_INLINE(startTime, <, endTime)) {
        [array addObject:[NSValue valueWithCMTime:startTime]];
        startTime = CMTimeAdd(startTime, addTime);
    }
    // 第一帧取第0.1s   规避有些视频并不是从第0s开始的
    array[0] = [NSValue valueWithCMTime:CMTimeMake(0.1 * 1000, 1000)];
    __weak typeof(self)weakSelf = self;
    __block int index = 0;
    [self.imageGenerator
     generateCGImagesAsynchronouslyForTimes:array
     completionHandler:^(
                         CMTime requestedTime, CGImageRef _Nullable image,
                         CMTime actualTime,
                         AVAssetImageGeneratorResult result,
                         NSError *_Nullable error) {
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *img = [[UIImage alloc] initWithCGImage:image];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.imagesArray addObject:img];
                NSIndexPath *indexPath =
                [NSIndexPath indexPathForItem:index
                                    inSection:0];
                [weakSelf.collectionView
                 insertItemsAtIndexPaths:@[ indexPath ]];
                index++;
            });
        }
    }];
    
    CMTime time = [self makeTimeByPercent:0.5];
    dispatch_async(dispatch_get_global_queue(0, 0),^{
        self.selectedImage = [self coverImageAtTime:time];
        [self.delegate pickViewDidUpdateImage:self.selectedImage];
    });
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return _imagesArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:
(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"cell"
                                              forIndexPath:indexPath];
    UIImage *image = _imagesArray[indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = cell.contentView.bounds;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [cell.contentView addSubview:imageView];
    return cell;
}

- (AVAssetImageGenerator *)imageGenerator {
    if (!_imageGenerator) {
        AVURLAsset *asset =
        [AVURLAsset assetWithURL:[NSURL fileURLWithPath:_cutInfo.outputPath]];
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        _imageGenerator.appliesPreferredTrackTransform = YES;
        _imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        _imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        _imageGenerator.maximumSize = CGSizeMake(100, 100);
    }
    return _imageGenerator;
}

- (AVAssetImageGenerator *)pickGenerator {
    if (!_imageGenerator) {
        AVURLAsset *asset =
        [AVURLAsset assetWithURL:[NSURL fileURLWithPath:_cutInfo.outputPath]];
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        _imageGenerator.appliesPreferredTrackTransform = YES;
        _imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        _imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        _imageGenerator.maximumSize = _cutInfo.outputSize;
    }
    return _imageGenerator;
}

- (UIImage *)coverImageAtTime:(CMTime)time {
    CGImageRef image = [self.pickGenerator copyCGImageAtTime:time
                                                  actualTime:NULL
                                                       error:nil];
    UIImage *picture = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return picture;
}

#pragma mark - touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGRect adjustLeftRespondRect = _arrowIconLeft.frame;
    CGRect adjustRightRespondRect = _arrowIconRight.frame;
    CGRect adjustProgressRect = CGRectMake(_progressView.frame.origin.x-10,
                                           _progressView.frame.origin.y,
                                           _progressView.frame.size.width+20,
                                           _progressView.frame.size.height);
    
    if (CGRectContainsPoint(adjustLeftRespondRect, point)) {
        _imageViewSelected = _arrowIconLeft;
    }
    else if (CGRectContainsPoint(adjustRightRespondRect, point)) {
        _imageViewSelected = _arrowIconRight;
    }
    else if (CGRectContainsPoint(adjustProgressRect, point)) {
        _imageViewSelected = _progressView;
        //可滑动范围
        CGFloat percent = point.x / self.frame.size.width;
        
        [self updateProgressByPercent:percent];
        
        self.progressView.center = CGPointMake(point.x,self.frame.size.height/2+6);
    }
    else {
        _imageViewSelected = nil;
    }
}

//根据滑动的百分比来更新封面
- (void)updateProgressByPercent:(CGFloat)percent
{
    CMTime time = [self makeTimeByPercent:percent];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.selectedImage = [self coverImageAtTime:time];
        [self.delegate pickViewDidUpdateImage:self.selectedImage];
        self.imageCaptured = YES;
    });
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_imageViewSelected) return;
    
    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    CGPoint previousPoint = [touch previousLocationInView:self];
    CGFloat offset = currentPoint.x - previousPoint.x;
    CGFloat time = offset/(self.frame.size.width - 2 * _arrowIconWidth) * _duration;
    
    if (_imageViewSelected == _arrowIconLeft) {
        _progressView.hidden = YES;
        CGFloat left = _cutInfo.startTime + time;
        CGFloat totalTime = _cutInfo.endTime != 0 ? _cutInfo.endTime : _duration;
        if (0 < left && left < totalTime - _cutInfo.minDuration) {
            CGRect frame = _arrowIconLeft.frame;
            frame.origin.x += offset;
            _arrowIconLeft.frame = frame;
            
            CGRect maskFrame = _arrowIconLeftMask.frame;
            maskFrame.size.width = frame.origin.x;
            _arrowIconLeftMask.frame = maskFrame;
            
            _cutInfo.startTime = left;
            _durationLabel.text = [NSString stringWithFormat:@"%.2f",totalTime - _cutInfo.startTime];
            if ([_delegate respondsToSelector:@selector(cutBarDidMovedToTime:)]) {
                [_delegate cutBarDidMovedToTime:left];
            }
            [self updateLineViewFrame];
        }
    } else if (_imageViewSelected == _arrowIconRight) {
        _progressView.hidden = YES;
        CGFloat totalTime = _cutInfo.endTime != 0 ? _cutInfo.endTime : _duration;
        CGFloat right = totalTime + time;
        if (_cutInfo.startTime + _cutInfo.minDuration <= right && right <= _duration) {
            _cutInfo.endTime = right;
            CGRect frame = _arrowIconRight.frame;
            frame.origin.x += offset;
            _arrowIconRight.frame = frame;
            
            CGRect maskFrame = _arrowIconRightMask.frame;
            maskFrame.origin.x = frame.origin.x + frame.size.width;
            maskFrame.size.width = self.frame.size.width - maskFrame.origin.x;
            _arrowIconRightMask.frame = maskFrame;
            _durationLabel.text = [NSString stringWithFormat:@"%.2f", _cutInfo.endTime - _cutInfo.startTime];
            if ([_delegate respondsToSelector:@selector(cutBarDidMovedToTime:)]) {
                [_delegate cutBarDidMovedToTime:right];
            }
        } else {
            _durationLabel.text = @"2.00";
        }
        [self updateLineViewFrame];
    }
    else if (_imageViewSelected == _progressView) {
        CGFloat percent = currentPoint.x / self.frame.size.width;
        CGFloat px = currentPoint.x;
        CGFloat leftBoundry = _arrowIconLeft.frame.origin.x + _arrowIconWidth;
        CGFloat rightBoundry = _arrowIconRight.frame.origin.x;
        if (px < leftBoundry) {
            px = leftBoundry;
            percent = leftBoundry/self.frame.size.width;
        } else if (px > rightBoundry) {
            px = rightBoundry;
            percent = rightBoundry/self.frame.size.width;
        }
        CMTime generatorTime = [self makeTimeByPercent:percent];
        if (_imageCaptured) {
            _imageCaptured = NO;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                self.selectedImage = [self coverImageAtTime:generatorTime];
                [self.delegate pickViewDidUpdateImage:self.selectedImage];
                self.imageCaptured = YES;
            });
        }
        self.progressView.center = CGPointMake(px,self.frame.size.height/2+6);
    }
    
}

- (void)updateLineViewFrame
{
    CGRect upFrame = _topLineView.frame;
    CGRect downFrame = _underLineView.frame;
    
    upFrame.origin.x = CGRectGetMaxX(_arrowIconLeft.frame) - 3;
    downFrame.origin.x = upFrame.origin.x;
    
    upFrame.size.width = CGRectGetMinX(_arrowIconRight.frame) - CGRectGetMaxX(_arrowIconLeft.frame) + 6;
    downFrame.size.width = upFrame.size.width;
    _topLineView.frame = upFrame;
    _underLineView.frame = downFrame;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_imageViewSelected == _progressView) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        CGFloat percent = point.x / self.frame.size.width;
        if (point.x < _arrowIconWidth) {
            percent = _arrowIconWidth/self.frame.size.width;
        }
        CMTime time = [self makeTimeByPercent:percent];
        dispatch_async(dispatch_get_global_queue(0, 0),^{
            self.selectedImage = [self coverImageAtTime:time];
            [self.delegate pickViewDidUpdateImage:self.selectedImage];
        });
    } else {
        CGRect upFrame = _topLineView.frame;
        CGFloat oriX = upFrame.origin.x + upFrame.size.width/2.0;
        _progressView.frame = CGRectMake(oriX-2, 12, 4, self.frame.size.height-12);
        CGFloat percent = oriX / self.frame.size.width;
        CMTime time = [self makeTimeByPercent:percent];
        dispatch_async(dispatch_get_global_queue(0, 0),^{
            self.selectedImage = [self coverImageAtTime:time];
            [self.delegate pickViewDidUpdateImage:self.selectedImage];
        });
        _progressView.hidden = NO;
        if ([_delegate respondsToSelector:@selector(cutBarTouchesDidEnd)]) {
            [_delegate cutBarTouchesDidEnd];
        }
    }
    _imageViewSelected = nil;
}

- (CMTime)makeTimeByPercent:(CGFloat)percent
{
    if (percent < 0) {
        percent = 0;
    } else if (percent > 1) {
        percent = 1;
    }
    CMTime time = CMTimeMake(percent * _duration * 1000, 1000);
    return time;
}

@end
