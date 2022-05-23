//
//  GBRoomManager.h
//  KTVGrab
//
//  Created by Vic on 2022/3/11.
//

#import <Foundation/Foundation.h>
#import "GBRunningRoomService.h"
#import "GBRoomInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface GBRoomManager : NSObject

/**
 * 当前房间对应的 service
 */
@property (nonatomic, strong, nullable) GBRunningRoomService *runningRoomService;

+ (instancetype)shared;

/**
 * 进入房间
 * @param roomInfo 若有 roomInfo, 则认为是进入已经存在的房间. 若 roomInfo 为 nil, 则认为是创建房间
 */
- (void)enterRoomWithRoomInfo:(GBRoomInfo *)roomInfo complete:(void(^)(BOOL suc, NSError *err, GBRunningRoomService * _Nullable service))complete;

/**
 * 离开房间, 并且清理 IM 和 Express SDK
 */
- (void)leaveRoomAndCleanUpSDK;

@end

NS_ASSUME_NONNULL_END
