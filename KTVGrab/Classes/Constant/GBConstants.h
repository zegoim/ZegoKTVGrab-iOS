//
//  GBConstants.h
//  KTVGrab
//
//  Created by Vic on 2022/2/22.
//

#ifndef GBConstants_h
#define GBConstants_h

#import "GBTypeDefines.h"

/**
 * Notification Name
 */

/**
 * 是否实时数据展示通知
 */
static NSNotificationName const kGBSeatQualityVisibilityNotificationName = @"GBSeatQualityVisibilityNotificationName";

/**
 * 即将离开房间通知
 */
static NSNotificationName const kGBSDKRoomWillLeaveNotificationName = @"GBSDKRoomWillLeaveNotificationName";

/**
 * 已经离开房间通知
 */
static NSNotificationName const kGBSDKRoomDidLeaveNotificationName = @"GBSDKRoomDidLeaveNotificationName";

/**
 * SDK 即将进行清理通知
 */
static NSNotificationName const kGBSDKRoomWillCleanUpNotificationName = @"GBSDKRoomWillCleanUpNotificationName";

/**
 * SDK 清理完毕通知
 */
static NSNotificationName const kGBSDKRoomDidCleanUpNotificationName = @"GBSDKRoomDidCleanUpNotificationName";

/**
 * Dictionary Key
 */

/**
 * 是否实时数据展示通知
 */
static NSString * const kGBSeatQualityVisibilityNotificationKey = @"visible";


/**
 * ZPush command
 */

/**
 * 成员状态变更通知
 */
static GBPushCommand const kGBUserStateUpdateCmd  = 6002;

/**
 * 成员列表变更通知
 */
static GBPushCommand const kGBUserListUpdateCmd   = 6003;

/**
 * 房间状态变更通知
 */
static GBPushCommand const kGBRoomStateUpdateCmd  = 6007;

/**
 * 终端透传广播消息
 */
static GBPushCommand const kGBBroadcastCmd        = 6008;

/**
 * 点歌列表变更通知
 */
static GBPushCommand const kGBSongListUpdateCmd   = 6009;
  
#endif /* GBConstants_h */
