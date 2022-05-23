//
//  GBEnums.h
//  GoChat
//
//  Created by Vic on 2022/2/22.
//  Copyright © 2022 zego. All rights reserved.
//

#ifndef GBEnums_h
#define GBEnums_h

/// 房间全局游戏状态
typedef NS_ENUM(NSUInteger, GBRoomState) {
  GBRoomStateUnknown,
  GBRoomStateGameWaiting,
  GBRoomStateRoundPreparing,
  GBRoomStateGrabWaiting,
  GBRoomStateGrabSuccessfully,
  GBRoomStateSinging,
  GBRoomStateGrabUnsuccessfully,
  GBRoomStateAIScoring,
  GBRoomStateSongEnd,
  GBRoomStateNextSongPreparing,
  GBRoomStateRoundEnd,
  GBRoomStateRoomExit,
};

typedef NS_ENUM(NSUInteger, GBUserRoleType) {
  GBUserRoleTypeUnknown = 0,
  GBUserRoleTypeSpectator = 1,
  GBUserRoleTypePlayer,
  GBUserRoleTypeHost,
};

typedef NS_ENUM(NSUInteger, GBNetQuality) {
  GBNetQualityUnknown = 0,
  GBNetQualityTesting,
  GBNetQualityBad,
  GBNetQualityMedium,
  GBNetQualityGood,
};

typedef NS_ENUM(NSUInteger, GBBackendError) {
  GBBackendRoomNotExists          = 80002,
  GBBackendRoomIsFull             = 80003,
  GBBackendErrorUserNotInRoom     = 80012,
  GBBackendErrorUserAlreadyInRoom = 80032,
};

#endif /* GBEnums_h */
