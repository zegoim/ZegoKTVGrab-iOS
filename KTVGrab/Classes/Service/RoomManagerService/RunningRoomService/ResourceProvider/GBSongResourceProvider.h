//
//  GBSongResourceService.h
//  KTVGrab
//
//  Created by Vic on 2022/3/21.
//

#import <Foundation/Foundation.h>
#import "GBRoomUserService.h"

@class GBSong;
@class GBSongPlay;
@class GBSongResourceProvider;

NS_ASSUME_NONNULL_BEGIN

@protocol GBSongResourceDownloadListener <NSObject>

- (void)resourceProvider:(GBSongResourceProvider *)provider onPreparingCompleteInBatchesWithSongPlays:(NSArray<GBSongPlay *> *)songPlays invalidSongPlays:(NSArray<GBSongPlay *> *)invalidSongPlays inRound:(NSUInteger)round error:(NSError * _Nullable)error;

- (void)resourceProvider:(GBSongResourceProvider *)provider onPreparingCompleteInSequenceWithSongPlay:(GBSongPlay *)songPlay inRound:(NSUInteger)round error:(NSError * _Nullable)error;

@end

@interface GBSongResourceProvider : NSObject <GBRoomUserSEIListener>

- (void)setListener:(id<GBSongResourceDownloadListener>)listener;

//TODO: 使用 block 回调结果
/**
 * 批量准备歌曲, 无顺序
 */
- (void)prepareSongPlaysInBatches:(NSArray<GBSongPlay *> *)songPlays inRound:(NSUInteger)round;

/**
 * 批量按顺序依次准备歌曲
 */
- (void)prepareSongPlaysInSequence:(NSArray<GBSongPlay *> *)songList inRound:(NSUInteger)round;

/**
 * 校验该歌曲资源是否完整
 */
- (BOOL)validateSongWithSongID:(NSString *)songID;

/**
 * 校验歌词
 */
- (BOOL)validateLyricWithSongID:(NSString *)songID;

/**
 * 根据 songID 获取 GBSong 对象
 */
- (GBSong *)getSongBySongID:(NSString *)songID;

/**
 * 根据 songID 获取 GBSongPlay 对象
 */
- (GBSongPlay *)getSongPlayBySongID:(NSString *)songID;


@end

NS_ASSUME_NONNULL_END
