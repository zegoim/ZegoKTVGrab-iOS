//
//  ZGKTVGuestCellVM.h
//  GoChat
//
//  Created by Vic on 2021/10/25.
//  Copyright © 2021 zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBEnums.h"
#import "GBSeatInfo.h"

@class GBSeatCellVM;
@class GBNetQualityModel;

NS_ASSUME_NONNULL_BEGIN

/**
 * 用于给 SeatCell 提供视图数据
 */
@interface GBSeatCellVM : NSObject

/**
 * 根据麦位序号进行初始化
 */
- (instancetype)initWithIndex:(NSUInteger)index;

/**
 * 麦位数据信息
 */
@property (nonatomic, strong) GBSeatInfo *seatInfo;

/**
 * 连麦人头像
 */
@property (nonatomic, copy) NSString *avatarURLString;

/**
 * 连麦人名字
 */
@property (nonatomic, copy) NSString *displayName;

/**
 * 麦位序号
 */
@property (nonatomic, assign) NSUInteger index;

/**
 * 连麦人的网络监测信息, 如果为空, 则不显示实时数据和网络状况
 */
@property (nonatomic, strong) GBNetQualityModel *netQuality;

/**
 * 用户网络质量
 */
@property (nonatomic, assign) GBNetQuality qualityLevel;

/**
 * 声浪等级
 */
@property (nonatomic, assign) CGFloat soundLevel;

/**
 * 麦位是否有人
 */
@property (nonatomic, assign) BOOL empty;

/**
 * 是否开麦
 */
@property (nonatomic, assign) BOOL mute;

/**
 * 是否展示测试数据
 */
@property (nonatomic, assign) BOOL showTestData;

@end

NS_ASSUME_NONNULL_END
