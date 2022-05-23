//
//  GBHeartbeatManager.h
//  KTVGrab
//
//  Created by Vic on 2022/3/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 房间心跳服务
 */
@interface GBHeartbeatService : NSObject

/**
 * 开启房间心跳
 */
- (void)startRepeatedlyHeartbeatWithRoomID:(NSString *)roomID;

/**
 * 停止房间心跳
 */
- (void)stopRepeatedlyHeartbeat;

@end

NS_ASSUME_NONNULL_END
