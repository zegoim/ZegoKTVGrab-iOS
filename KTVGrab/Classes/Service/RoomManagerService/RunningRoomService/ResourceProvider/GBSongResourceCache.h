//
//  GBSongResourceCache.h
//  KTVGrab
//
//  Created by Vic on 2022/4/6.
//

#import <Foundation/Foundation.h>

@class GBSong;
@class GBSongPlay;

NS_ASSUME_NONNULL_BEGIN

/**
 * 该类仅供 GBSongResourceProvider 内部使用
 */
@interface GBSongResourceCache : NSObject

/**
 * 缓存 GBSong 对象
 */
- (void)setSong:(GBSong *)song bySongID:(NSString *)songID;

/**
 * 缓存 GBSongPlay 对象
 */
- (void)setSongPlay:(GBSongPlay *)songPlay bySongID:(NSString *)songID;

/**
 * 获取 GBSong 缓存
 */
- (GBSong * _Nullable)getSongBySongID:(NSString *)songID;

/**
 * 获取 GBSongPlay 缓存
 */
- (GBSongPlay * _Nullable)getSongPlayBySongID:(NSString *)songID;

/**
 * 更新歌曲的 duration 信息
 * 在没有歌曲完整信息的情况下, 需要从 SEI 更新歌曲 duration 信息, 用于 UI 展示
 */
- (void)updateSongDuration:(NSUInteger)duration forSongID:(NSString *)songID;

@end

NS_ASSUME_NONNULL_END
