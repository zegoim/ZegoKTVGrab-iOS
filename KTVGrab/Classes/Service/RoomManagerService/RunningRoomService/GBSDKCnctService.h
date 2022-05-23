//
//  GBSDKCnctService.h
//  KTVGrab
//
//  Created by Vic on 2022/5/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GBRoomCnctListener <NSObject>

/**
 * 房间断开
 */
- (void)onRoomDisconnected;

/**
 * 房间正在重连
 */
- (void)onRoomReconnecting;

/**
 * 房间重连成功
 */
- (void)onRoomReconnected;

/**
 * 账号在其他地方登录, 被踢出房间
 */
- (void)onRoomKickout;

@end

/**
 * 用于监听 SDK 的房间连接情况,
 * 屏蔽了底层 Express RTC 和 IM 两个房间的信息, 向外提供统一的房间连接信息回调
 */
@interface GBSDKCnctService : NSObject

/**
 * 设置事件监听对象
 */
- (void)setListener:(id<GBRoomCnctListener>)listener;

@end

NS_ASSUME_NONNULL_END
