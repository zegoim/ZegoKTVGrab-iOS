//
//  GBMediaProgressDataService.h
//  KTVGrab
//
//  Created by Vic on 2022/3/23.
//

#import <Foundation/Foundation.h>
#import "GBMediaPlayer.h"
#import "GBRoomUserService.h"
#import "GBSEIModel.h"

@class GBMediaProgressSimulator;

NS_ASSUME_NONNULL_BEGIN

@protocol GBProgressSimListener <NSObject>

/**
 * SEI 模拟对象更新回调
 * 回调间隔 ~30ms
 */
- (void)progressSimulator:(GBMediaProgressSimulator *)simulator onSimulatedSEIUpdateEvery30ms:(GBSEIModel *)seiModel;

/**
 * 媒体播放器模拟进度更新回调
 * 回调间隔 ~30ms
 */
- (void)progressSimulator:(GBMediaProgressSimulator *)simulator onMediaSimulatedProgressUpdateEvery30ms:(NSInteger)progress;

/**
 * 媒体播放器模拟进度更新回调
 * 回调间隔 ~60ms
 */
- (void)progressSimulator:(GBMediaProgressSimulator *)simulator onMediaSimulatedProgressUpdateEvery60ms:(NSInteger)progress;

/**
 * 媒体播放器真实进度更新回调
 * 回调间隔 ~500ms
 */
- (void)progressSimulator:(GBMediaProgressSimulator *)simulator onMediaRealProgressUpdate:(NSInteger)progress;

@end

/**
 * 歌词的更新依赖于播放器进度回调或 SEI 进度通知
 * 但是播放器进度回调间隔和 SEI 进度回调间隔不能太快
 * 因此该类使用 timer 缩短 progress 回调间隔(~30ms), 使歌词控件和音高线控件刷新更流畅
 */
@interface GBMediaProgressSimulator : NSObject <GBMediaPlayerProgressListener, GBRoomUserSEIListener, GBMediaPlayerStateListener>

/**
 * 设置事件监听对象
 */
- (void)setListener:(id<GBProgressSimListener>)listener;

/**
 * 开启媒体播放器进度模拟回调
 *
 * 因为媒体播放器目前设置的进度回调为 500ms
 * 所以需要将 progress 回调模拟为 30 ms
 * 以保证歌词控件及音高线空间流畅的效果
 *
 * 一般在本地媒体播放器开启后调用
 */
- (void)startMediaProgressSimulation;

/**
 * 关闭媒体播放器进度模拟回调
 *
 * 一般在本地媒体播放器停止播放后调用
 */
- (void)stopMediaProgressSimulation;

/**
 * 开启 SEI 进度模拟回调
 *
 * 因为 SEI 中包含当前播放歌曲进度的 progress 字段
 * 且 SEI 的回调间隔大于 30ms
 * 所以需要将 progress 回调模拟为 30ms
 * 以保证歌词控件及音高线空间流畅的效果
 */
- (void)startSEIProgressSimulation;

/**
 * 关闭 SEI 进度模拟回调
 */
- (void)stopSEIProgressSimulation;

@end

NS_ASSUME_NONNULL_END
