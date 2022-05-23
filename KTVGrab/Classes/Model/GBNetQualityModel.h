//
//  GBNetQualityModel.h
//  KTVGrab
//
//  Created by Vic on 2022/4/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GBNetQualityModel : NSObject

/**
 * 音频码率
 */
@property (nonatomic, assign) CGFloat kbps;

/**
 * 延迟
 * 只能表征本端和服务器之间的延迟, 不能体现对端的网络状态
 */
@property (nonatomic, assign) int rtt;

/**
 * 丢包率
 */
@property (nonatomic, assign) int packetLossRate;

@end

NS_ASSUME_NONNULL_END
