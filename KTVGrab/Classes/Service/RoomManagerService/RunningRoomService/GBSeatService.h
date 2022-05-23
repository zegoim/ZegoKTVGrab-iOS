//
//  GBSeatService.h
//  KTVGrab
//
//  Created by Vic on 2022/4/11.
//

#import <Foundation/Foundation.h>
#import "GBRoomUserService.h"

@class GBSeatInfo;
@class GBSeatService;

NS_ASSUME_NONNULL_BEGIN

@protocol GBSeatEventListener <NSObject>

/**
 * 麦位列表更新, 需要监听者全量刷新列表 UI
 */
- (void)seatService:(GBSeatService *)service onSeatListUpdate:(NSArray<GBSeatInfo *> *)seatInfos;

/**
 * 某个麦位的信息更新, 监听者仅需局部更新该麦位信息
 */
- (void)seatService:(GBSeatService *)service onSeatMiscUpdate:(GBSeatInfo *)seatInfo;

@end

/**
 * 用于更新麦位 UI
 */
@interface GBSeatService : NSObject <GBRoomUserEventListener, GBRoomUserNetQualityListener>

/**
 * 设置事件监听对象
 */
- (void)setListener:(id<GBSeatEventListener>)listener;

@end

NS_ASSUME_NONNULL_END
