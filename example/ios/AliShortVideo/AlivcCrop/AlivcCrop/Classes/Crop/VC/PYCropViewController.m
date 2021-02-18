//
//  PYCropViewController.m
//  AlivcEdit
//
//  Created by jimmy on 2021/2/10.
//

#import "PYCropViewController.h"
#import "AliyunCycleProgressView.h"
#import "AliyunCropViewBottomView.h"
#import "PYCoverPickerAndThumbnailView.h"
#import "AliyunCropThumbnailView.h"
#import <AVFoundation/AVFoundation.h>
#import <AliyunVideoSDKPro/AliyunCrop.h>
#import <AliyunVideoSDKPro/AliyunErrorCode.h>
#import "AliyunPathManager.h"
#import "AVC_ShortVideo_Config.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "NSString+AlivcHelper.h"
#import "AVAsset+VideoInfo.h"

typedef NS_ENUM(NSInteger, AliyunCropPlayerStatus) {
    AliyunCropPlayerStatusPause,             // 结束或暂停
    AliyunCropPlayerStatusPlaying,           // 播放中
    AliyunCropPlayerStatusPlayingBeforeSeek  // 拖动之前是播放状态
};

@interface PYCropViewController ()<
PYCoverPickerAndThumbnailViewDelegate,
AliyunCropViewBottomViewDelegate,
AliyunCropDelegate
>

@property (nonatomic, strong) AliyunCropViewBottomView *bottomView;
@property(nonatomic, strong) PYCoverPickerAndThumbnailView *pickerThumbnailView;
@property(nonatomic, strong) UIImageView *coverView;

@property (nonatomic, strong) AVAsset *avAsset;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, assign) CMTime currentTime;

@property (nonatomic, assign) CGFloat destRatio;
@property (nonatomic, assign) CGFloat orgVideoRatio;
@property (nonatomic, assign) CGSize originalMediaSize;

@property (nonatomic, strong) AliyunCrop *cutPanel;
@property (nonatomic, assign) BOOL shouldStartCut;
@property (nonatomic, assign) BOOL hasError;
@property (nonatomic, assign) BOOL isCancel;
@property (nonatomic, assign) AliyunCropPlayerStatus playerStatus;
@property (nonatomic, assign) AliyunMediaCutMode cutMode;

@end

@implementation PYCropViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _cutMode = _cutInfo.cutMode;
    if (!_cutInfo.phAsset) {
        [self addNotification];
    }
    [self setupSubViews];
    NSURL *sourceURL = [NSURL fileURLWithPath:_cutInfo.sourcePath];
    _avAsset = [AVAsset assetWithURL:sourceURL];
    _originalMediaSize = [_avAsset avAssetNaturalSize];
    _destRatio = _cutInfo.outputSize.width / _cutInfo.outputSize.height;
    _orgVideoRatio = _originalMediaSize.width / _originalMediaSize.height;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
        [self.pickerThumbnailView loadThumbnailData];
    });
    
}

- (void)setupSubViews {
    
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.coverView = [[UIImageView alloc]
                      initWithFrame:CGRectMake(36,
                                               SafeTop+44,
                                               ScreenWidth-72,
                                               536)];
    self.coverView.layer.cornerRadius = 20;
    self.coverView.layer.masksToBounds = YES;
    [self.view addSubview:self.coverView];
    
    if (!_cutInfo.phAsset) {
        self.pickerThumbnailView = [[PYCoverPickerAndThumbnailView alloc] initWithFrame:CGRectMake(36,
                                                                                                   ScreenHeight - SafeBottom - 40 - 70,
                                                                                                   ScreenWidth-72,
                                                                                                   70)
                                                                            withCutInfo: _cutInfo];
        self.pickerThumbnailView.delegate = self;
        [self.view addSubview:self.pickerThumbnailView];
        
        UILabel *pickerTitleLb = [[UILabel alloc] initWithFrame:CGRectMake(36,
                                                                           self.pickerThumbnailView.frame.origin.y - 15 - 16,
                                                                           ScreenWidth-72,
                                                                           16)];
        pickerTitleLb.text = @"请拖拽指针选择视频封面";
        pickerTitleLb.textColor = [UIColor whiteColor];
        pickerTitleLb.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:pickerTitleLb];
    }
    self.bottomView = [[AliyunCropViewBottomView alloc] initWithFrame:CGRectMake(0,
                                                                                 ScreenHeight - 40 - SafeBottom,
                                                                                 ScreenWidth,
                                                                                 40)];
    self.bottomView.delegate = (id<AliyunCropViewBottomViewDelegate>)self;
    [self.bottomView.ratioButton setHidden:YES];
    [self.view addSubview:self.bottomView];
}

- (void)didStopCut {
    _isCancel = YES;
    self.pickerThumbnailView.userInteractionEnabled = YES;
    self.bottomView.cropButton.enabled = YES;
    self.bottomView.ratioButton.enabled = YES;
    [_cutPanel cancel];
}


#pragma mark - pick view delegate

- (void)pickViewDidUpdateImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.coverView.image = image;
    });
}
- (void)cutBarDidMovedToTime:(CGFloat)time {
    if (_playerItem.status == AVPlayerItemStatusReadyToPlay) {
        [_avPlayer seekToTime:CMTimeMake(time * 1000, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        if (_playerStatus == AliyunCropPlayerStatusPlaying) {
            _playerStatus = AliyunCropPlayerStatusPlayingBeforeSeek;
        }
    }
}

- (void)cutBarTouchesDidEnd {
    _playerItem.forwardPlaybackEndTime = CMTimeMake(_cutInfo.endTime * 1000, 1000);
    if (_playerStatus == AliyunCropPlayerStatusPlayingBeforeSeek) {
//        [self playVideo];
    }
}


#pragma mark - AliyunCropViewBottomViewDelegate
//叉号按钮
- (void)onClickBackButton
{
    if ([self.delegate respondsToSelector:@selector(cropViewControllerExit)]) {
        [self.delegate cropViewControllerExit];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//中间那个按钮
- (void)onClickRatioButton
{
    
}
//对号按钮
- (void)onClickCropButton
{
    if (!_cutInfo.phAsset) {
        [self didStartClip];
    }
}


- (void)didStartClip {
    
    self.pickerThumbnailView.userInteractionEnabled = NO;
    
    if (_cutPanel) {
        [_cutPanel cancel];
    }
    _cutPanel = [[AliyunCrop alloc] init];
    _cutPanel.delegate = (id<AliyunCropDelegate>)self;
    _cutPanel.inputPath = _cutInfo.sourcePath;
    NSString *root = [AliyunPathManager compositionRootDir];
    NSString *path = [[root stringByAppendingPathComponent:[AliyunPathManager randomString]] stringByAppendingPathExtension:@"mp4"];
    _cutInfo.outputPath = path;
    _cutPanel.outputPath = path;
    
    _cutPanel.outputSize = _cutInfo.outputSize;
    _cutPanel.fps = _cutInfo.fps;
    _cutPanel.gop = _cutInfo.gop;
    _cutPanel.videoQuality = (AliyunVideoQuality)_cutInfo.videoQuality;
    
    
    if (_cutInfo.cutMode == 1||!self.fakeCrop) {
        //改变了裁剪模式和设置真裁剪
        if (_cutInfo.cutMode == 1) {
            _cutPanel.rect = [self evenRect:[self configureReservationRect]];
        }
        //只有画幅变了才是真裁剪 其他都是假裁剪
        if(!self.fakeCrop) {
            _cutPanel.cropMode = (AliyunCropCutMode)_cutInfo.cutMode;

            _cutPanel.startTime = _cutInfo.startTime;
            _cutPanel.endTime = _cutInfo.endTime;
            _cutPanel.gop = _cutInfo.gop;
            _cutPanel.fps = _cutInfo.fps;
            _cutPanel.videoQuality = (AliyunVideoQuality)_cutInfo.videoQuality;
            if (_cutInfo.encodeMode == AliyunEncodeModeHardH264) {
                _cutPanel.encodeMode = 1;
            }else if (_cutInfo.encodeMode == AliyunEncodeModeSoftFFmpeg) {
                _cutPanel.encodeMode = 0;
            }
            NSLog(@"裁剪编码方式：%d",_cutPanel.encodeMode);
            _cutPanel.fillBackgroundColor = _cutInfo.backgroundColor;
            _cutPanel.useHW = _cutInfo.gpuCrop;

            NSLog(@"TestLog, %@:%@", @"log_crop_start_time", @([NSDate date].timeIntervalSince1970));

            int res =[_cutPanel startCrop];
            if (res == ALIVC_SVIDEO_ERROR_MEDIA_NOT_SUPPORTED_VIDEO){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showWarningMessage:[@"当前视频格式不支持" localString] inView:[UIApplication sharedApplication].keyWindow];
                });
            }else if (res == ALIVC_SVIDEO_ERROR_MEDIA_NOT_SUPPORTED_AUDIO){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showWarningMessage:[@"当前视频格式不支持" localString] inView:[UIApplication sharedApplication].keyWindow];
                });
            }else if (res <0){
                _isCancel =NO;
                [self cropOnError:res];
            }
            _isCancel = NO;
            return;
        }
    }
    if ([self.delegate respondsToSelector:@selector(cropViewControllerFakeFinish:viewController:)]) {
        [self.delegate cropViewControllerFakeFinish:self.cutInfo viewController:self];
    }
}

//裁剪必须为偶数
- (CGRect)evenRect:(CGRect)rect {
    return CGRectMake((int)rect.origin.x / 2 * 2, (int)rect.origin.y / 2 * 2, (int)rect.size.width / 2 * 2, (int)rect.size.height / 2 * 2);
}


- (CGRect)configureReservationRect {
    CGFloat x = 0, y = 0, w = 0, h = 0;
    if (_orgVideoRatio > _destRatio) {
        h = _originalMediaSize.height;
        w = h * _destRatio;
    } else {
        w = _originalMediaSize.width;
        h = _originalMediaSize.width / _destRatio;
    }
    if (!y) {
        y = 0;
    }
    return CGRectMake(x, y, _originalMediaSize.width, _originalMediaSize.height);
}


#pragma mark - AliyunCropDelegate

- (void)cropTaskOnProgress:(float)progress {
    NSLog(@"~~~~~裁剪进度:%@", @(progress));
    if (_isCancel) {
        return;
    }
}

- (void)cropOnError:(int)error {
    NSLog(@"~~~~~~~crop error:%@", @(error));
    //裁剪退后台，sdk会报-314或者-310.这个是正常的，不需要弹窗
    if (_isCancel || error == ALIVC_SVIDEO_ERROR_TRANSCODE_BACKGROUND) {
        _isCancel = NO;
    } else {
        _hasError = YES;
        
        [MBProgressHUD showWarningMessage:NSLocalizedString(@"裁剪失败", nil) inView:self.view];
        self.pickerThumbnailView.userInteractionEnabled = YES;
        self.bottomView.cropButton.userInteractionEnabled = YES;
        self.bottomView.ratioButton.userInteractionEnabled = YES;
        
    }
    _bottomView.cropButton.enabled =YES;
}

- (void)cropTaskOnComplete {
    NSLog(@"TestLog, %@:%@", @"log_crop_complete_time", @([NSDate date].timeIntervalSince1970));
    if (_isCancel) {
        _isCancel = NO;
    } else {
        if (_hasError) {
            _hasError = NO;
            return;
        }
        _cutInfo.endTime = _cutInfo.endTime - _cutInfo.startTime;
        _cutInfo.startTime = 0;
        
        if ([self.delegate respondsToSelector:@selector(cropViewControllerFinish:coverImage:viewController:)]) {
            [self.delegate cropViewControllerFinish:self.cutInfo coverImage:self.coverView.image viewController:self];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }
    _bottomView.cropButton.enabled =YES;
}

- (void)cropTaskOnCancel {
    _bottomView.cropButton.enabled =YES;
    _bottomView.ratioButton.enabled = YES;
    NSLog(@"cancel");
}

#pragma mark - Notification

- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    
    _avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_avPlayer.currentItem];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:CMTimeMake(_cutInfo.startTime * 1000, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    _playerStatus = AliyunCropPlayerStatusPlaying;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    NSLog(@"applicationDidEnterBackground");
    [self didStopCut];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
//    [self playVideo];
}

#pragma mark - 设备自动旋转
// 支持设备自动旋转
- (BOOL)shouldAutorotate
{
    return YES;
}

// 支持竖屏显示
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
