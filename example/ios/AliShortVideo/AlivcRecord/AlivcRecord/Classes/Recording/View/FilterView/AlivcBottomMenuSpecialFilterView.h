//
//  AlivcBottomMenuSpecialFilterView.h
//  AliyunVideoClient_Entrance
//
//  Created by 孙震 on 2019/9/10.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlivcBottomMenuView.h"
#import "AliyunEffectFilterInfo.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^DidSelectEffectFilterBlock)(AliyunEffectFilterInfo *filterInfo);


@interface AlivcBottomMenuSpecialFilterView : AlivcBottomMenuView
/**
 选中的滤镜数据模型
 */
@property (nonatomic, strong) AliyunEffectInfo *selectedEffect;

/**
 注册选中滤镜的回调事件
 
 @param block 选中滤镜的回调
 */
-(void)registerDidSelectEffectFilterBlock:(DidSelectEffectFilterBlock)block;
@end

NS_ASSUME_NONNULL_END
