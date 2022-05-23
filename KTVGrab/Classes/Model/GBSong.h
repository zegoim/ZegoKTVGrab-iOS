//
//  GBSongClip.h
//  KTVGrab
//
//  Created by Vic on 2022/3/7.
//

#import <Foundation/Foundation.h>

@class GBSDKSongClip;
@class GBSongPlay;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GBSongDownloadState) {
  GBSongDownloadStateNotDownloaded,
  GBSongDownloadStateDownloading,
  GBSongDownloadStateDownloaded,
};

@interface GBSong : NSObject
/// Resources
/**
 * 音速达歌曲 ID
 */
@property (nonatomic,  copy ) NSString *songID;

/**
 * 音速达歌曲资源 ID
 * 一个 songID 可能对应多个 resourceID
 * 这里取第一个
 */
@property (nonatomic,  copy ) NSString *resourceID;

/**
 * 逐字歌词 token
 * 获取逐字歌词信息需要使用该 token
 */
@property (nonatomic,  copy ) NSString *krcToken;

/**
 * 高潮片段开始时间
 */
@property (nonatomic, assign) NSUInteger segBegin;

/**
 * 高潮片段结束时间
 */
@property (nonatomic, assign) NSUInteger segEnd;

/**
 * 高潮持续时间
 */
@property (nonatomic, assign) NSUInteger duration;

/**
 * 高潮前奏时间
 */
@property (nonatomic, assign) NSUInteger preludeDuration;

/**
 * 歌词 JSON 信息
 */
@property (nonatomic,  copy ) NSString *lyricJson;

/**
 * 音高线 JSON 信息
 */
@property (nonatomic,  copy ) NSString *pitchJson;

/**
 * 歌曲名
 */
@property (nonatomic,  copy ) NSString *songName;

/**
 * 歌手名
 */
@property (nonatomic,  copy ) NSString *singerName;

/**
 * 歌曲资源下载状态
 */
@property (nonatomic, assign) GBSongDownloadState downloadState;


- (void)updateWithSDKSongClip:(GBSDKSongClip *)sdkSongClip;
- (void)updateWithSongPlay:(GBSongPlay *)songPlay;

/**
 * 检查歌曲完整性
 * 包括 resourceID, 歌曲是否已经下载, 歌词信息, 音高线信息
 */
- (BOOL)validateIntegrity;

/**
 * 检查歌词是否下载完毕
 */
- (BOOL)validateLyric;

@end

NS_ASSUME_NONNULL_END
