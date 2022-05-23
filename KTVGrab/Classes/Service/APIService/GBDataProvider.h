//
//  GBDataProvider.h
//  KTVGrab
//
//  Created by Vic on 2022/3/11.
//

#import <Foundation/Foundation.h>
#import "GBCreateRoomAPI.h"
#import "GBConcreteRespModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^GBDataProviderRsvCallback)(BOOL suc, NSError * _Nullable  err, id _Nullable rsv);
typedef void(^GBDataProviderRoomInfoCallback)(BOOL suc, NSError * _Nullable err, GBRoomRespModel *model);

@interface GBDataProvider : NSObject

/**
 * 获取 token
 */
+ (void)getTokenComplete:(void(^)(BOOL suc, NSError * _Nullable err, NSString * _Nullable token))complete;

#pragma mark - 房间协议

/**
 * 拉取房间列表
 * @param count 单词拉取的房间数量
 * @param time 拉取 beginTimeStamp 时间之前的若干个房间
 * @param complete 拉取房间列表结果回调
 */
+ (void)getRoomListWithCount:(NSUInteger)count beforeTime:(NSInteger)time complete:(void(^)(BOOL suc, NSError * _Nullable  err, NSArray<GBRoomRespModel *> *models))complete;

/**
 * 创建房间
 */
+ (void)createRoomWithAPI:(GBCreateRoomAPI *)api complete:(GBDataProviderRoomInfoCallback)complete;

/**
 * 加入房间
 */
+ (void)joinRoomWithRoomID:(NSString *)roomID complete:(GBDataProviderRoomInfoCallback)complete;

/**
 * 获取房间信息
 */
+ (void)getRoomInfoWithRoomID:(NSString *)roomID complete:(GBDataProviderRoomInfoCallback)complete;

/**
 * 房间心跳
 */
+ (void)heartbeatWithRoomID:(NSString *)roomID complete:(void(^)(BOOL suc, NSError * _Nullable  err, NSNumber *interval))complete;

/**
 * 离开房间
 * 房主离开房间则房间自动销毁(后台逻辑)
 */
+ (void)leaveRoomWithRoomID:(NSString *)roomID complete:(GBDataProviderRsvCallback _Nullable)complete;


#pragma mark - 抢唱协议

/**
 * 开始一轮抢唱
 */
+ (void)startRoundWithRoomID:(NSString *)roomID complete:(GBDataProviderRsvCallback _Nullable)complete;

/**
 * 抢麦
 */
+ (void)grabMicWithRoomID:(NSString *)roomID complete:(GBDataProviderRsvCallback _Nullable)complete;

/**
 * 获取随机歌曲曲库
 */
+ (void)getRandomSongsComplete:(void(^_Nullable)(BOOL suc, NSError * _Nullable err, NSArray<NSString *> *songIDs))complete;

/**
 * 该轮次歌曲下载完毕上报
 */
+ (void)reportSongsReadyWithRoomID:(NSString *)roomID inRound:(NSUInteger)round invalidIDs:(NSArray<NSString *> *)invalidIDs complete:(GBDataProviderRsvCallback _Nullable)complete;

/**
 * 上报歌曲分数
 */
+ (void)reportScore:(NSUInteger)score withRoomID:(NSString *)roomID songID:(NSString *)songID complete:(GBDataProviderRsvCallback _Nullable)complete;

/**
 * 操作麦克风
 */
+ (void)reportOperationWithMicEnabled:(BOOL)enable atIndex:(NSUInteger)index roomID:(NSString *)roomID complete:(GBDataProviderRsvCallback _Nullable)complete;

#pragma mark - 杂项

/**
 * 获取成员列表
 */
+ (void)getUserListWithRoomID:(NSString *)roomID complete:(void(^_Nullable)(BOOL suc, NSError * _Nullable  err, NSArray<GBUserRespModel *> *respUsers))complete;

@end

NS_ASSUME_NONNULL_END
