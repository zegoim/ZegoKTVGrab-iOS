//
//  GBScoreService.h
//  KTVGrab
//
//  Created by Vic on 2022/4/11.
//

#import <Foundation/Foundation.h>

@class GBSong;

NS_ASSUME_NONNULL_BEGIN

/**
 * 封装 RTC 的打分接口
 */
@interface GBScoreService : NSObject

/**
 * 开始打分
 */
- (void)startScoringSong:(GBSong *)song;

/**
 * 停止打分
 */
- (void)stopScoringSong;

/**
 * 获取平均分
 */
- (int)getAvgScoreForSong:(GBSong *)song;

/**
 * 获取前一句得分
 */
- (int)getPrevScoreForSong:(GBSong *)song;

@end

NS_ASSUME_NONNULL_END
