//
//  GBCreateRoomAPI.h
//  KTVGrab
//
//  Created by Vic on 2022/3/12.
//

#import "GBBaseAuthRequest.h"

NS_ASSUME_NONNULL_BEGIN

/// 创建并加入房间
@interface GBCreateRoomAPI : GBBaseAuthRequest

/// 房间名称
@property (nonatomic, copy) NSString *roomName;

/// 房间背景图片
@property (nonatomic, copy) NSString *coverImage;

/// 抢唱游戏总共的轮次
@property (nonatomic, assign) NSInteger rounds;

/// 抢唱游戏每轮的歌曲数目
@property (nonatomic, assign) NSInteger songsPerRound;

/// 最大麦位数量
@property (nonatomic, assign) NSInteger maxMic;


@end

NS_ASSUME_NONNULL_END
