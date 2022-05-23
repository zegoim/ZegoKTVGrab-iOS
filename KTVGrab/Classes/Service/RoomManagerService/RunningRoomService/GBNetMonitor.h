//
//  GBNetMonitor.h
//  KTVGrab
//
//  Created by Vic on 2022/4/14.
//

#import <Foundation/Foundation.h>

@class GBNetMonitor;
@class GBNetQualityModel;

NS_ASSUME_NONNULL_BEGIN

@protocol GBNetMonitorEventListener <NSObject>

/**
 * 通过测速接口测得的网络质量回调
 */
- (void)netMonitor:(GBNetMonitor *)monitor onNetSpeedTestQualityUpdate:(GBNetQuality)qualityLevel;

/**
 * 流质量回调
 */
- (void)netMonitor:(GBNetMonitor *)monitor onStream:(NSString *)streamID qualityUpdate:(GBNetQualityModel *)quality;

/**
 * 用户上行网络监测质量回调
 */
- (void)netMonitor:(GBNetMonitor *)monitor onUser:(NSString *)userID netQualityLevelUpdate:(GBNetQuality)qualityLevel;

@end

@interface GBNetMonitor : NSObject

/**
 * 添加事件监听对象
 */
- (void)appendListener:(id<GBNetMonitorEventListener>)listener;

@end

NS_ASSUME_NONNULL_END
