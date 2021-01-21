//
//  AlivcBottomMenuFilterView.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/5/6.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcBottomMenuSpecialFilterView.h"
#import "AliyunEffectSpecialFilterCell.h"
#import "AliyunEffectInfo.h"
#import "AliyunDBHelper.h"
#import "AVC_ShortVideo_Config.h"
#import "AliyunEffectResourceModel.h"
#import "AliyunEffectMvGroup.h"
#import "NSString+AlivcHelper.h"

@interface AlivcBottomMenuSpecialFilterView ()
/**
 显示view
 */
@property (nonatomic, strong) UICollectionView *collectionView;

/**
 数据模型数组
 */
@property (nonatomic, strong) NSMutableArray *dataArray;

/**
 FMDB的封装类
 */
@property (nonatomic, strong) AliyunDBHelper *dbHelper;

/**
 数据类型
 */
@property (nonatomic, assign) NSInteger effectType;

/**
 选中滤镜的序号
 */
@property (nonatomic, assign) NSInteger selectIndex;

@property (nonatomic, copy)DidSelectEffectFilterBlock selectFilterBlock;

@end

@implementation AlivcBottomMenuSpecialFilterView

- (instancetype)initWithFrame:(CGRect)frame withItems:(NSArray<AlivcBottomMenuHeaderViewItem *> *)items{
    self = [super initWithFrame:frame withItems:items];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _dbHelper = [[AliyunDBHelper alloc] init];
        _dataArray = [[NSMutableArray alloc] init];
        _selectIndex = -1;
        [self addSubViews];
    }
    return self;
}

/**
 添加子控件
 */
- (void)addSubViews {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(50, 70);
    layout.sectionInset = UIEdgeInsetsMake(5, 20, 20, 22);
    layout.minimumInteritemSpacing = 20;
    layout.minimumLineSpacing = 20;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, (CGRectGetHeight(self.contentView.frame)-90)/2, ScreenWidth, 90) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"AlivcRecord.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"AliyunEffectSpecialFilterCell" bundle:bundle] forCellWithReuseIdentifier:@"AliyunEffectSpecialFilterCell"];
    
    _collectionView.dataSource = (id<UICollectionViewDataSource>)self;
    _collectionView.delegate = (id<UICollectionViewDelegate>)self;
    [self.contentView addSubview:_collectionView];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self reloadDataWithEffectType:AliyunEffectTypeSpecialFilter];
    });
}

- (void)reloadDataWithEffectType:(NSInteger)eType {
    _effectType = eType;
    [_dataArray removeAllObjects];
    if (_selectIndex == -1) {
        _selectIndex = 0; //默认是不选中
    }
    __weak typeof(self)weakSelf = self;
    [_dbHelper queryResourceWithEffecInfoType:eType success:^(NSArray *infoModelArray) {
        for (AliyunEffectInfo *info in infoModelArray) {
            [weakSelf.dataArray addObject:info];
            if (weakSelf.selectedEffect) {
                if (info.eid == weakSelf.selectedEffect.eid) {
                    weakSelf.selectIndex = [infoModelArray indexOfObject:info] + 1;
                }
            }
        }
        
        AliyunEffectInfo *effctMore = [[AliyunEffectInfo alloc] init];
        effctMore.name = [@"无效果" localString];
        effctMore.eid = -1;
        effctMore.effectType = AliyunEffectTypeSpecialFilter;
        effctMore.icon = @"shortVideo_clear";
        [weakSelf.dataArray insertObject:effctMore atIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
        });
    } failure:^(NSError *error) {
        
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    

    AliyunEffectSpecialFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunEffectSpecialFilterCell" forIndexPath:indexPath];
    
    AliyunEffectInfo *effectInfo = _dataArray[indexPath.row];
    [cell cellModel:effectInfo];
    
        if (indexPath.row == _selectIndex) {
            [cell setSelected:YES];
            NSLog(@"滤镜测试%@：选中：%ld",effectInfo.name,_selectIndex);
        }else{
            [cell setSelected:NO];
            NSLog(@"滤镜测试%@：不选中：%ld",effectInfo.name,indexPath.row);
        }
//    }
    if (_effectType == AliyunEffectTypeSpecialFilter) {
        if (indexPath.row == 0) {
            cell.imageView.contentMode = UIViewContentModeCenter;
            cell.imageView.backgroundColor = rgba(255, 255, 255, 0.2);
            cell.imageView.image = [AlivcImage imageNamed:@"shortVideo_clear"];
            cell.nameLabel.text = NSLocalizedString(@"无效果", nil);
        }else{
            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
            cell.imageView.backgroundColor = [UIColor clearColor];
        }
    }
    [cell setExclusiveTouch:YES];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_effectType == AliyunEffectTypeSpecialFilter) {
        AliyunEffectSpecialFilterCell *lastSelectCell = (AliyunEffectSpecialFilterCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectIndex inSection:0]];
                NSLog(@"滤镜测试：不选中：%ld",_selectIndex);
        [lastSelectCell setSelected:NO];
    }
    
    AliyunEffectInfo *currentEffect = _dataArray[indexPath.row];
    if (_effectType == AliyunEffectTypeSpecialFilter) {
        if (_selectFilterBlock) {
            _selectFilterBlock(currentEffect);
        }
        _selectIndex = indexPath.row;
    }
}

-(void)registerDidSelectEffectFilterBlock:(DidSelectEffectFilterBlock)block{
    _selectFilterBlock = block;
}


@end
