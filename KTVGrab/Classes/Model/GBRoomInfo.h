//
//  GBRoomInfo.h
//  KTVGrab
//
//  Created by Vic on 2022/3/13.
//

#import <Foundation/Foundation.h>
#import "GBEnums.h"

@class GBRoomRespModel;
@class GBUser;
@class GBSongPlay;

NS_ASSUME_NONNULL_BEGIN

/**
 * 房间信息数据模型
 */
@interface GBRoomInfo : NSObject

/**
 * 房间信息对应的 seq
 */
@property (nonatomic, assign) long long seq;

/**
 * 房间 ID
 */
@property (nonatomic, copy) NSString *roomID;

/**
 * 房间名
 */
@property (nonatomic, copy) NSString *roomName;

/**
 * 房间背景图片 URL 地址
 */
@property (nonatomic, copy) NSString *imgURLString;

/**
 * 房间创建时间
 */
@property (nonatomic, assign) NSUInteger createTime;

/**
 * 房间内所有在线人数
 */
@property (nonatomic, assign) NSUInteger userOnlineCount;

/**
 * 房间内上麦人数
 */
@property (nonatomic, assign) NSUInteger userOnstageCount;

/**
 * 房间内抢唱游戏状态
 */
@property (nonatomic, assign) GBRoomState roomState;

/**
 * 抢唱总轮次
 */
@property (nonatomic, assign) NSUInteger rounds;

/**
 * 当前轮次
 */
@property (nonatomic, assign) NSUInteger curRound;

/**
 * 抢唱游戏每轮的歌曲数目
 */
@property (nonatomic, assign) NSUInteger songsPerRound;

/**
 * 抢唱游戏该轮的歌曲数目
 */
@property (nonatomic, assign) NSUInteger songsThisRound;

/**
 * 当前正在播放的歌曲序号
 */
@property (nonatomic, assign) NSUInteger curSongIndex;

/**
 * 正在抢唱的用户 ID
 */
@property (nonatomic, copy) NSString *curPlayerID;

/**
 * 当前正在播放的歌曲 ID
 */
@property (nonatomic, copy) NSString *curSongID;

/**
 * 抢唱得分
 */
@property (nonatomic, assign) NSInteger singScore;

/**
 * 抢唱是否成功
 */
@property (nonatomic, assign) BOOL isSingerPass;

/**
 * 最大麦位数量
 */
@property (nonatomic, assign) NSUInteger seatsCount;

/**
 * 当前房间正在进行轮次的抢唱歌单
 */
@property (nonatomic, copy) NSArray<GBSongPlay *> *songPlays;

/**
 * 房间用户信息
 */
@property (nonatomic, copy) NSArray<GBUser *> *roomUsers;


/**
 * 根据网络模型刷新房间模型数据
 */
- (void)updateWithRoomRespModel:(GBRoomRespModel *)rsp;

@end

NS_ASSUME_NONNULL_END
