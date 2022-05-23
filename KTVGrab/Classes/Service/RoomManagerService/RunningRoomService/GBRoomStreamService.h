//
//  GBRoomStreamService.h
//  KTVGrab
//
//  Created by Vic on 2022/3/31.
//

#import <Foundation/Foundation.h>

@protocol GBNetMonitorEventListener;

@class GBSEIModel;
@class GBRoomStreamService;
@class GBNetQualityModel;

NS_ASSUME_NONNULL_BEGIN

@protocol GBStreamServiceEventListener <NSObject>

/**
 * 用户音浪更新回调
 */
- (void)streamService:(GBRoomStreamService *)service onUser:(NSString *)userID soundLevelUpdate:(CGFloat)soundLevel;

/**
 * 用户流数据回调
 */
- (void)streamService:(GBRoomStreamService *)service onUser:(NSString *)userID qualityUpdate:(GBNetQualityModel *)quality;

/**
 * 用户网络数据回调
 */
- (void)streamService:(GBRoomStreamService *)service onUser:(NSString *)userID netQualityLevelUpdate:(GBNetQuality)qualityLevel;

/**
 * 用户本人的网络测速质量回调
 */
- (void)streamService:(GBRoomStreamService *)service onMyTestSpeedQualityUpdate:(GBNetQuality)qualityLevel;

/**
 * 收到的 SEI 信息回调
 */
- (void)streamService:(GBRoomStreamService *)service onReceiveSEI:(GBSEIModel *)model;

/**
 * 回调用户是否有流信息
 */
- (void)streamService:(GBRoomStreamService *)service onUser:(NSString *)userID streamOnAir:(BOOL)flag;

@end

@interface GBRoomStreamService : NSObject

/**
 * 设置事件监听对象
 */
- (void)setListener:(id<GBStreamServiceEventListener>)listener;

/**
 * 根据 userID 开始推流, 只能推送自己的流
 * @param userID 只有传用户自己的 userID 才有效
 */
- (void)startPublishingWithUserID:(NSString *)userID;

/**
 * 根据 userID 停止推流
 * @param userID 只有传用户自己的 userID 才有效
 */
- (void)stopPublishingWithUserID:(NSString *)userID;

/**
 * 拉取/停止房主拉流
 * @param play 是否拉取房主流
 * @param userID 房主 userID
 *
 * 之所以要有一个主动拉取/停止房主流的方法, 是因为在 GrabWaiting 阶段, 如果本端没有下载完歌曲, 则需要主动拉取房主流播放歌曲
 */
- (void)playHostStream:(BOOL)play hostUserID:(NSString *)userID;

/**
 * 检查 userID 的流是否有被拉取, 如果 userID 是自己, 则检查是否有推流
 * 这个 OnAir 的表述是针对本端的
 */
- (BOOL)checkIfUserStreamOnAir:(NSString *)userID;

@end

NS_ASSUME_NONNULL_END
