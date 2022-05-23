//
//  GBSongResourceDownloader.h
//  KTVGrab
//
//  Created by Vic on 2022/4/6.
//

#import <Foundation/Foundation.h>

@class GBSong;
@class GBSongPlay;
@class GBSongResourceCache;

NS_ASSUME_NONNULL_BEGIN

/**
 * 该类仅供 GBSongResourceProvider 内部使用
 */
@interface GBSongResourceDownloader : NSObject

/**
 * 初始化方法
 * @param resourceCache 歌曲资源缓存对象
 */
- (instancetype)initWithResourceCache:(GBSongResourceCache *)resourceCache;

/**
 * 批量获取歌曲 resourceID, krcToken 等资源信息
 * @param songPlays 歌曲列表
 * @param complete 结果回调. 分为有版权歌曲和无版权歌曲列表. 无版权歌曲需要上报后台
 */
- (void)getResourceInfoInBatchesWithSongPlays:(NSArray<GBSongPlay *> *)songPlays
                                     complete:(void (^)(NSError * error,
                                                        NSArray<GBSongPlay *> *songPlaysWithCR,
                                                        NSArray<GBSongPlay *> *songPlaysWithoutCR))complete;

/**
 * 获取单首歌曲 resourceID, krcToken 等资源信息
 */
- (void)getResourceInfoWithSongPlay:(GBSongPlay *)songPlay complete:(void (^)(NSError * error))complete;

/**
 * 批量下载歌曲资源. 如歌词, 音高线等
 * @param songPlays 歌曲列表
 * @param complete 结果回调
 */
- (void)downloadSongDataInBatchesWithSongPlays:(NSArray<GBSongPlay *> *)songPlays
                                      complete:(void(^)(NSError *error))complete;

/**
 * 下载单首歌曲资源. 如歌词, 音高线等
 */
- (void)downloadSongDataWithSongPlay:(GBSongPlay *)songPlay complete:(void(^)(NSError *error))complete;

@end

NS_ASSUME_NONNULL_END
