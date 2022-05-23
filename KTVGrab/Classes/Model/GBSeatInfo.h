//
//  GBSeatInfo.h
//  KTVGrab
//
//  Created by Vic on 2022/4/11.
//

#import <Foundation/Foundation.h>

@class GBNetQualityModel;

NS_ASSUME_NONNULL_BEGIN

/**
 * 麦位数据模型
 */
@interface GBSeatInfo : NSObject

/**
 * 用户名
 */
@property (nonatomic,  copy ) NSString *userName;

/**
 * 头像地址
 */
@property (nonatomic,  copy ) NSString *avatarURLString;

/**
 * 麦位序号
 */
@property (nonatomic, assign) NSUInteger seatIndex;

/**
 * 音浪值
 */
@property (nonatomic, assign) CGFloat soundLevel;

/**
 * 是否静音
 */
@property (nonatomic, assign) BOOL mute;

/**
 * 是否有流存在
 */
@property (nonatomic, assign) BOOL hasStream;

/**
 * 实时网络数据
 */
@property (nonatomic, strong) GBNetQualityModel *netQuality;

/**
 * 网络测速情况
 */
@property (nonatomic, assign) GBNetQuality qualityLevel;

@end

NS_ASSUME_NONNULL_END
