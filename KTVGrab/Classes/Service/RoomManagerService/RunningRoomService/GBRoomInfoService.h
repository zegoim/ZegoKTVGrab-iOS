//
//  GBGameProcManager.h
//  GoChat
//
//  Created by Vic on 2022/2/22.
//  Copyright © 2022 zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBEnums.h"
#import "GBSDKEventAgent.h"

@class GBRoomInfo;
@class GBRoomInfoService;

NS_ASSUME_NONNULL_BEGIN

@protocol GBRoomInfoUpdateListener <NSObject>

/**
 * 房间信息更新回调
 */
- (void)roomInfoService:(GBRoomInfoService *)service onRoomInfoUpdate:(GBRoomInfo *)roomInfo;

@end

/**
 * 用于管理房间信息
 */
@interface GBRoomInfoService : NSObject <GBAgentRoomStateListener>

/**
 * 设置事件监听对象
 */
- (void)setListener:(id<GBRoomInfoUpdateListener>)listener;

/**
 * 强制更新当前房间信息
 */
- (void)forceUpdatingRoomInfo:(GBRoomInfo *)roomInfo;

@end

NS_ASSUME_NONNULL_END
