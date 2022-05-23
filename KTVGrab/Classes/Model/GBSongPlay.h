//
//  GBSongPlayInfo.h
//  KTVGrab
//
//  Created by Vic on 2022/3/14.
//

#import <Foundation/Foundation.h>

@class GBSongRespModel;

NS_ASSUME_NONNULL_BEGIN

@interface GBSongPlay : NSObject

/**
 * 音速达歌曲 ID
 */
@property (nonatomic, copy) NSString *songID;

/**
 * 歌曲在业务后台的唯一 ID
 */
@property (nonatomic, copy) NSString *uniqueID;

/**
 * 歌曲在轮次中的序号
 */
@property (nonatomic, assign) NSUInteger order;

/**
 * 抢唱倒计时秒数
 */
@property (nonatomic, assign) int firstPartDuration;

/**
 * 歌手名
 */
@property (nonatomic, copy) NSString *singerName;

/**
 * 歌名
 */
@property (nonatomic, copy) NSString *songName;

- (void)updateWithSongRespModel:(GBSongRespModel *)model;

@end

NS_ASSUME_NONNULL_END
