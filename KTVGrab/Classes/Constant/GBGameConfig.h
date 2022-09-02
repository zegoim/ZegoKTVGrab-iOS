//
//  GBGameConfig.h
//  KTVGrab
//
//  Created by Vic on 2022/5/6.
//

/**
 * 抢唱游戏配置文件
 */
#ifndef GBGameConfig_h
#define GBGameConfig_h

/**
 * 抢唱最大轮次数
 */
#define GB_CREATE_ROOM_ROUNDS 2

/**
 * 抢唱每轮包含的歌曲数目
 */
#define GB_CREATE_ROOM_SONGS_PER_ROUND 8

/**
 * 抢唱麦位最大人数
 * n 及 n 之前进房的人会自动上麦加入游戏
 * n 之后进房的人将自动成为观众
 */
#define GB_CREATE_ROOM_MAX_SEAT_COUNT 6

/**
 * 抢唱房间断网超时时间, 单位(秒)
 * SDK 需要和业务后台的超时时间保持一致
 * 需要在设置 ZegoExpressEngine 的 ZegoEngineConfig.advancedConfig 设置该字段
 * 例如:  @{@"advancedConfig": @"90" };
 */
#define GB_NET_TIME_OUT_SECOND 90

/**
 * 房间背景图片网络地址格式化字符串
 * 0-9 有效
 */
#define GB_ROOM_BG_IMAGE_PATH_FORMAT @"https://zego-customersucc.oss-cn-shanghai.aliyuncs.com/solution_app/avatar/ktv/mobile/%d.png"

/**
 * 用户头像图片网络地址格式化字符串, 目前和房间背景图片相同
 * 0-9 有效
 */
#define GB_USER_AVATAR_IMAGE_PATH_FORMAT @"https://zego-customersucc.oss-cn-shanghai.aliyuncs.com/solution_app/avatar/ktv/mobile/%d.png"

#endif /* GBGameConfig_h */
