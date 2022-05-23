//
//  GBIM.h
//  IMTest
//
//  Created by Vic on 2022/3/7.
//

#import <Foundation/Foundation.h>
#import <ZIM/ZIM.h>
#import "GBInternalHeader.h"

NS_ASSUME_NONNULL_BEGIN


@protocol GBIMCnctListener <NSObject>

/**
 * IM 正在重连
 */
- (void)onIMConnectionReconnecting;

/**
 * IM 已完成重连
 */
- (void)onIMConnectionReconnected;

/**
 * IM 已断线
 */
- (void)onIMConnectionDisconnected;

/**
 * IM 正进行房间重连
 */
- (void)onIMRoomReconnecting;

/**
 * IM 已完成房间重连
 */
- (void)onIMRoomReconnected;

/**
 * IM 已断开与房间的连接
 */
- (void)onIMRoomDisconnected;

@end

@protocol GBIMMessageListener <NSObject>

/**
 * IM 接收到房间消息
 */
- (void)onIMReceiveRoomMessage:(NSString *)message;

@end

@interface GBIM : NSObject <ZIMEventHandler>

/**
 * 设置 IM 连接状态监听对象
 */
- (void)setConnectionListener:(id<GBIMCnctListener>)connectionListener;

/**
 * 设置 IM Message 事件监听对象
 */
- (void)setMessageListener:(id<GBIMMessageListener>)messageListener;

/**
 * 单例
 */
+ (instancetype)shared;

/**
 * 创建 IM 模块
 */
- (void)create;

/**
 * 销毁 IM 模块
 */
- (void)destroy;

/**
 * 获取 IM 模块版本号
 */
- (NSString *)getVersion;


#pragma mark - Login
/**
 * 登录 IM 模块
 */
- (void)loginWithComplete:(GBErrorBlock)complete;

/**
 * 登出 IM 模块
 */
- (void)logout;

#pragma mark - Room
/**
 * 创建房间
 * 如果创建成功, 则自动加入房间. 否则返回错误码
 */
- (void)createRoomWithRoomID:(NSString *)roomID roomName:(NSString *)roomName complete:(GBErrorBlock)complete;

/**
 * 加入房间
 */
- (void)joinRoomWithRoomID:(NSString *)roomID complete:(GBErrorBlock)complete;

/**
 * 离开当前房间
 */
- (void)leaveRoomWithCompletion:(GBErrorBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
