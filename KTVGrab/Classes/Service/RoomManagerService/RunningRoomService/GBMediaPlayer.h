//
//  GBMediaPlayer.h
//  KTVGrab
//
//  Created by Vic on 2022/3/22.
//

#import <Foundation/Foundation.h>

@class GBSong;
@class GBMediaPlayer;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GBMediaPlayerState) {
  GBMediaPlayerStateNoPlay = 0,
  GBMediaPlayerStatePlaying = 1,
  GBMediaPlayerStatePausing = 2,
  GBMediaPlayerStatePlayEnded = 3
};

@protocol GBMediaPlayerStateListener <NSObject>

/**
 * 媒体播放器状态更新回调
 */
- (void)mediaPlayer:(GBMediaPlayer *)mediaPlayer onStateUpdate:(GBMediaPlayerState)state playingSong:(GBSong *)song;

@end

@protocol GBMediaPlayerProgressListener <NSObject>

/**
 * 媒体播放器播放进度更新回调
 */
- (void)mediaPlayer:(GBMediaPlayer *)mediaPlayer onProgressUpdate:(NSUInteger)progress;

@end

@protocol GBSongScoreEventListener <NSObject>

/**
 * 媒体播放器音高值更新回调
 */
- (void)mediaPlayer:(GBMediaPlayer *)mediaPlayer onSong:(GBSong *)song pitchUpdate:(int)pitch atProgress:(NSInteger)progress;

@end

/**
 * 媒体播放器服务
 */
@interface GBMediaPlayer : NSObject

- (void)appendEventListener:(id<GBMediaPlayerStateListener>)listener;
- (void)setProgressListener:(id<GBMediaPlayerProgressListener>)progressListener;
- (void)setScoreEventListener:(id<GBSongScoreEventListener>)listener;

/**
 * 开始播放歌曲
 * @param preludeMs 高潮开始位置提前 x(ms)开始播放
 */
- (void)startPlayingSong:(GBSong *)song prelude:(int)preludeMs;

/**
 * 停止播放歌曲
 */
- (void)stopPlaying;

/**
 * 设置原唱/伴奏
 */
- (void)setSoundTrackAsOriginal:(BOOL)original;

@end

NS_ASSUME_NONNULL_END
