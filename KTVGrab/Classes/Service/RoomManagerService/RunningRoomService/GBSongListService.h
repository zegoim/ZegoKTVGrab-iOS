//
//  GBSongListService.h
//  KTVGrab
//
//  Created by Vic on 2022/4/6.
//

#import <Foundation/Foundation.h>
#import "GBSDKEventAgent.h"

@class GBSongListService;
@class GBSongPlay;

NS_ASSUME_NONNULL_BEGIN


@protocol GBSongListListener <NSObject>

/**
 * 歌单列表更新回调
 */
- (void)songListService:(GBSongListService *)service
       onSongListUpdate:(NSArray<GBSongPlay *> *)songPlays
                inRound:(NSUInteger)round
                   type:(NSUInteger)type;

@end

@interface GBSongListService : NSObject <GBAgentSongListUpdateListener>

/**
 * 设置事件监听对象
 */
- (void)setListener:(id<GBSongListListener>)listener;

/**
 * 强制更新歌单列表
 */
- (void)forceUpdatingSongPlays:(NSArray<GBSongPlay *> *)songPlays inRound:(NSUInteger)round;

/**
 * 获取指定歌单的指定歌曲
 * @param index 第 X 首歌
 * @param round 第 X 轮
 */
- (GBSongPlay *)getSongPlayAtIndex:(NSUInteger)index inRound:(NSUInteger)round;

@end

NS_ASSUME_NONNULL_END
