//
//  GBSDKEventAgent.h
//  KTVGrab
//
//  Created by Vic on 2022/3/17.
//

#import <Foundation/Foundation.h>

@class GBRoomInfo;
@class GBSongPlay;
@class GBUser;
@class GBUserRespModel;

NS_ASSUME_NONNULL_BEGIN

@protocol GBAgentRoomStateListener <NSObject>

/**
 * 房间信息更新回调
 */
- (void)onRoomStateUpdate:(GBRoomInfo *)roomInfo seq:(long long)seq;

@end

@protocol GBAgentUserUpdateListener <NSObject>

/**
 * 用户列表更新回调
 */
- (void)onRoomUserListUpdate:(NSArray<GBUserRespModel *> *)userList seq:(NSUInteger)seq;

/**
 * 用户状态更新回调
 */
- (void)onRoomUserStateUpdate:(NSArray<GBUserRespModel *> *)userList seq:(NSUInteger)seq;

@end

@protocol GBAgentSongListUpdateListener <NSObject>

/**
 * 歌单更新回调
 * @param songList  歌单数组
 * @param round  歌单对应的轮次
 * @param seq  sequence 序列号, seq 越大表示信息越新. 用于过滤陈旧信息
 * @param type  type == 5 表示后台在每轮第一次下发的歌单, type == 6 表示下载上报后的歌单
 */
- (void)onRoomSongListUpdate:(NSArray<GBSongPlay *> *)songList inRound:(NSUInteger)round seq:(NSUInteger)seq type:(NSUInteger)type;

@end


/**
 * 封装 IM 的 Push 消息, 转换为业务回调方法
 */
@interface GBSDKEventAgent : NSObject

/**
 * 设置房间信息更新监听
 */
- (void)setRoomStateListener:(id<GBAgentRoomStateListener>)listener;

/**
 * 设置用户信息更新监听
 */
- (void)setUserUpdateListener:(id<GBAgentUserUpdateListener>)listener;

/**
 * 设置歌曲列表更新监听
 */
- (void)setSongListUpdateListener:(id<GBAgentSongListUpdateListener>)listener;

@end

NS_ASSUME_NONNULL_END
