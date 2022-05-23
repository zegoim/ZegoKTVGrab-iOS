//
//  GBConcreteRespModel.h
//  KTVGrab
//
//  Created by Vic on 2022/3/12.
//

#import "GBNetworkRespModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GBSongRespModel : NSObject

/// 歌曲在业务后台的唯一 ID
@property (nonatomic, copy) NSString *uniqueID;

/// 音速达歌曲 ID
@property (nonatomic, copy) NSString *songID;

/// 歌曲名
@property (nonatomic, copy) NSString *songName;

/// 歌曲名
@property (nonatomic, copy) NSString *singerName;

/// 序号
@property (nonatomic, assign) int order;

/// 抢唱倒计时秒数
@property (nonatomic, assign) int firstPartDuration;

@end


@interface GBUserRespModel : NSObject

/// 用户 userID
@property (nonatomic, copy) NSString *userID;

/// 用户名
@property (nonatomic, copy) NSString *userName;

/// 用户头像 URL 地址
@property (nonatomic, copy) NSString *avatar;

/// 用户角色. 1-听众, 2-游戏参与者, 3-房主
@property (nonatomic, assign) NSUInteger role;

/// 用户登录时间
@property (nonatomic, assign) NSUInteger loginTime;

/// 用户麦克风状态. 0-未设置, 1-关闭, 2-开启
@property (nonatomic, assign) int micState;

/// 用户是否在台上. 1-不在台上, 2-在台上
@property (nonatomic, assign) int onstageState;

/// 麦位
@property (nonatomic, assign) int micIndex;

/// 抢唱数量
@property (nonatomic, assign) NSUInteger grabSongCount;

/// 抢唱成功数量
@property (nonatomic, assign) NSUInteger grabSongPassCount;

/// 抢唱总分
@property (nonatomic, assign) NSUInteger grabSongTotalScore;

/// 后台字段, 标识成员状态变更类型
@property (nonatomic, assign) NSInteger type;

/// 后台字段, 标识成员状态变更行为
@property (nonatomic, assign) NSInteger delta;

@end


@interface GBRoomRespModel : GBNetworkRespModel

/// 房间 ID
@property (nonatomic, copy) NSString *roomID;

/// 房间状态
@property (nonatomic, assign) NSUInteger status;

/// 房间名称
@property (nonatomic, copy) NSString *subject;

/// 房间创建时间
@property (nonatomic, assign) NSUInteger createTime;

/// 房间内总人数
@property (nonatomic, assign) NSUInteger onlineCount;

/// 房间内上麦人数
@property (nonatomic, assign) NSUInteger onstageCount;

/// 房间背景图片
@property (nonatomic, copy) NSString *coverImage;

/// 创建者 ID
@property (nonatomic, copy) NSString *creatorID;

/// 创建者头像 URL
@property (nonatomic, copy) NSString *creatorAvatar;

/// 创建者昵称
@property (nonatomic, copy) NSString *creatorName;

/// 抢唱游戏的总轮次
@property (nonatomic, assign) NSUInteger rounds;

/// 当前轮次
@property (nonatomic, assign) NSUInteger curRound;

/// 抢唱游戏每轮的歌曲数目
@property (nonatomic, assign) NSUInteger songsPerRound;

/// 抢唱游戏该轮的歌曲数目
@property (nonatomic, assign) NSUInteger songsThisRound;

/// 当前正在播放的歌曲序号
@property (nonatomic, assign) NSUInteger curSongIndex;

/// 抢唱者 ID
@property (nonatomic, copy) NSString *singerID;

/// 当前正在播放的歌曲 ID
@property (nonatomic, copy) NSString *curSongID;

/// 抢唱得分
@property (nonatomic, assign) NSUInteger singScore;

/// 抢唱是否成功
@property (nonatomic, assign) NSUInteger isSingerPass;

/// 最大麦位数量
@property (nonatomic, assign) NSUInteger maxMicNumber;

/// 当前房间正在进行轮次的抢唱歌单
@property (nonatomic, copy) NSArray<GBSongRespModel *> *songList;

/// 房间用户信息
@property (nonatomic, copy) NSArray<GBUserRespModel *> *userList;

@end

NS_ASSUME_NONNULL_END
