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
+ (void)getTokenComplete:(void (^)(BOOL, NSError * _Nullable, NSDictionary *))complete;

#pragma mark - 房间协议

/**
 * 拉取房间列表
 * @param count 单次拉取的房间数量
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
 * @param roomID 房间 ID
 */
+ (void)joinRoomWithRoomID:(NSString *)roomID complete:(GBDataProviderRoomInfoCallback)complete;

/**
 * 获取房间信息
 * @param roomID 房间 ID
 */
+ (void)getRoomInfoWithRoomID:(NSString *)roomID complete:(GBDataProviderRoomInfoCallback)complete;

/**
 * 房间心跳
 * @param roomID 房间 ID
 */
+ (void)heartbeatWithRoomID:(NSString *)roomID complete:(void(^)(BOOL suc, NSError * _Nullable  err, NSNumber *interval))complete;

/**
 * 离开房间
 * 房主离开房间则房间自动销毁(后台逻辑)
 * @param roomID 房间 ID
 */
+ (void)leaveRoomWithRoomID:(NSString *)roomID complete:(GBDataProviderRsvCallback _Nullable)complete;


#pragma mark - 抢唱协议

/**
 * 开始一轮抢唱
 * (该接口暂未使用)
 * @param roomID 房间 ID
 */
+ (void)startRoundWithRoomID:(NSString *)roomID complete:(GBDataProviderRsvCallback _Nullable)complete;

/**
 * 抢麦
 * @param roomID 房间 ID
 * @param round 待抢唱歌曲位于的轮次
 * @param index 待抢唱歌曲在轮次中的 index
 */
+ (void)grabMicWithRoomID:(NSString *)roomID round:(NSInteger)round index:(NSInteger)index complete:(GBDataProviderRsvCallback _Nullable)complete;

/**
 * 获取随机歌曲曲库
 * (该接口暂未使用)
 */
+ (void)getRandomSongsComplete:(void(^_Nullable)(BOOL suc, NSError * _Nullable err, NSArray<NSString *> *songIDs))complete;

/**
 * 该轮次歌曲下载完毕上报
 * @param roomID 房间 ID
 * @param round 下载完毕对应的轮次
 * @param invalidIDs 下载失败歌曲的 uniqueID 数组
 */
+ (void)reportSongsReadyWithRoomID:(NSString *)roomID round:(NSUInteger)round invalidIDs:(NSArray<NSString *> *)invalidIDs complete:(GBDataProviderRsvCallback _Nullable)complete;

/**
 * 上报歌曲分数
 * @param score 唱歌获得的分数
 * @param roomID 房间 ID
 * @param songID 对应歌曲的 songID
 */
+ (void)reportScore:(NSUInteger)score withRoomID:(NSString *)roomID songID:(NSString *)songID complete:(GBDataProviderRsvCallback _Nullable)complete;

/**
 * 上报麦克风状态改变
 * @param enable 麦克风可用状态. YES 为打开麦克风, NO 为关闭麦克风
 * @param index 被操作人所在麦位的 index
 * @param roomID 房间 ID
 */
+ (void)reportOperationWithMicEnabled:(BOOL)enable atIndex:(NSUInteger)index roomID:(NSString *)roomID complete:(GBDataProviderRsvCallback _Nullable)complete;

/**
 * 进入下一轮
 * @param roomID 房间 ID
 */
+ (void)enterNextRoundWithRoomID:(NSString *)roomID complete:(GBDataProviderRsvCallback _Nullable)complete;

#pragma mark - 杂项

/**
 * 获取成员列表
 * (该接口暂未使用)
 * @param roomID 房间 ID
 */
+ (void)getUserListWithRoomID:(NSString *)roomID complete:(void(^_Nullable)(BOOL suc, NSError * _Nullable  err, NSArray<GBUserRespModel *> *respUsers))complete;

@end

NS_ASSUME_NONNULL_END
