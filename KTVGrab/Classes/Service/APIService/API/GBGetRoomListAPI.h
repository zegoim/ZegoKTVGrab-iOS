//
//  GBGetRoomListAPI.h
//  KTVGrab
//
//  Created by Vic on 2022/3/12.
//

#import "GBBaseAuthRequest.h"

NS_ASSUME_NONNULL_BEGIN

/// 获取房间列表
@interface GBGetRoomListAPI : GBBaseAuthRequest

/// 单词拉取的房间数量
@property (nonatomic, assign) NSUInteger pageCount;

/// 拉取 beginTimeStamp 时间之前的若干个房间
@property (nonatomic, assign) NSUInteger beginTimeStamp;

@end

NS_ASSUME_NONNULL_END
