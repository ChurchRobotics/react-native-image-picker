//
//  AliyunTimelineTimeFilterItem.m
//  qusdk
//
//  Created by Vienta on 2018/2/26.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunTimelineTimeFilterItem.h"
#import "UIColor+AlivcHelper.h"

@implementation AliyunTimelineTimeFilterItem
- (instancetype)init
{
    self = [super init];
    if (self) {
        _displayColor = [UIColor colorWithHexString:@"0x651fff" alpha:0.4];
        
    }
    return self;
}
@end
