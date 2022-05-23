//
//  KTVExpress.h
//  GoChat
//
//  Created by Vic on 2022/2/17.
//  Copyright © 2022 zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import "GBInternalHeader.h"

@class GBSong;

NS_ASSUME_NONNULL_BEGIN

@protocol GBRTCRoomCnctListener <NSObject>

/**
 * 房间断开
 */
- (void)onRTCRoomDisconnected;

/**
 * 房间重连中
 */
- (void)onRTCRoomReconnecting;

/**
 * 房间已重连
 */
- (void)onRTCRoomReconnected;

/**
 * 相同账号登录被踢出房间
 */
- (void)onRTCRoomKickout;

@end

@protocol GBRTCMediaEventListener <NSObject>

- (void)onMediaPlayerProgressUpdate:(NSInteger)progress;
- (void)onMediaPlayerStateUpdate:(ZegoMediaPlayerState)state;
- (void)onCopyrightSongResource:(NSString *)resourceID pitchUpdate:(int)pitch atProgress:(NSInteger)progress;

@end

@protocol GBRTCStreamEventListener <NSObject>

- (void)onRTCAddStream:(ZegoStream *)stream;
- (void)onRTCRemoveStream:(ZegoStream *)stream;
- (void)onRTCStream:(NSString *)streamID soundLevelUpdate:(CGFloat)soundLevel;
- (void)onRTCStreamCapturedSoundLevelUpdate:(CGFloat)soundLevel;
- (void)onRTCStream:(NSString *)streamID receiveSEIData:(NSData *)data;

@end

@protocol GBRTCQualityEventListener <NSObject>

- (void)onRTCNetSpeedTestUpdate:(ZegoNetworkSpeedTestQuality * _Nullable)quality error:(NSError * _Nullable)error;
- (void)onRTCStreamQualityUpdate:(ZegoPlayStreamQuality *)quality playStreamID:(NSString *)streamID;
- (void)onRTCStreamQualityUpdate:(ZegoPublishStreamQuality *)quality publishStreamID:(NSString *)streamID;
- (void)onRTCNetworkQualityUpdate:(ZegoStreamQualityLevel)qualityLevel userID:(NSString *)userID;

@end

@interface GBExpress : NSObject <ZegoEventHandler, ZegoMediaPlayerEventHandler>

- (void)setRoomCnctListener:(id<GBRTCRoomCnctListener>)roomCnctListener;
- (void)setMediaEventListener:(id<GBRTCMediaEventListener>)listener;
- (void)setStreamEventListener:(id<GBRTCStreamEventListener>)listener;
- (void)setNetQualityEventListener:(id<GBRTCQualityEventListener>)listener;

/**
 * 单例对象
 */
+ (instancetype)shared;

/**
 * 获取 express 版本号
 */
- (NSString *)getVersion;

/**
 * 创建 express 实例
 */
- (void)create;

/**
 * 销毁 express 实例
 */
- (void)destroy:(GBEmptyBlock)block;

/**
 * 重置该类数据
 */
- (void)reset;

#pragma mark - Copyrighted Music

/**
 * 创建并初始化版权音乐模块
 */
- (void)createCopyrightMusicWithCompletion:(GBErrorBlock)completionBlock;

- (void)requestSongClipWithSongID:(NSString *)songID complete:(void(^)(NSError *error, GBSong *songClip))complete;
- (void)requestSongLyricWithKrcToken:(NSString *)krcToken complete:(void(^)(NSError *error, NSString *lyric))complete;
- (void)downloadResource:(NSString *)resourceID callback:(GBSongDownloadCallback)callback;
- (void)requestPitchWithResourceID:(NSString *)resourceID complete:(void(^)(NSError *error, NSString *pitchJson))complete;

- (void)startScore:(NSString *)resourceID;
- (void)stopScore:(NSString *)resourceID;
- (int)getPrevScore:(NSString *)resourceID;
- (int)getAvgScore:(NSString *)resourceID;
 
#pragma mark - Media

/**
 * 麦克风是否开启
 */
@property (nonatomic, assign) BOOL micEnable;

/**
 * 耳返是否开启
 */
@property (nonatomic, assign) BOOL iemEnable;

/**
 * 耳返音量
 */
@property (nonatomic, assign) CGFloat iemValue;

/**
 * 伴奏音量
 */
@property (nonatomic, assign) CGFloat mediaPlayerVolume;

/**
 * 人声音量
 */
@property (nonatomic, assign) CGFloat voiceCaptureVolume;

/**
 * 混响类型
 */
@property (nonatomic, assign) ZegoReverbPreset reverbPreset;

/**
 * 创建版权音乐播放器
 */
- (ZegoMediaPlayer *)createMediaPlayer;

/**
 * 在指定进度位置播放版权音乐歌曲
 * @param resourceID 版权音乐的 resourceID
 * @param progress 从该进度开始播放
 */
- (void)startPlayingCopyrightResource:(NSString *)resourceID atProgress:(NSInteger)progress;

/**
 * 播放器停止播放
 */
- (void)stopPlayingMedia;

#pragma mark - Room

/**
 * 进入房间
 */
- (void)loginRoomWithID:(NSString *)roomID complete:(GBErrorBlock)complete;

/**
 * 退出房间
 */
- (void)logout;

#pragma mark - SEI

/**
 * 随推流发送 SEI 数据
 */
- (void)sendSEI:(NSData *)data;

#pragma mark - Stream

/**
 * 高音质推流
 */
- (void)setMainPublisherStandardQuality;

/**
 * 标准音质推流
 */
- (void)setMainPublisherHighQuality;

/**
 * 开始拉流
 */
- (void)playStream:(NSString *)streamID;

/**
 * 停止拉流
 */
- (void)stopPlayingStream:(NSString *)streamID;

/**
 * 开始推流
 */
- (void)startPublishingStream:(NSString *)streamID;

/**
 * 停止推流
 */
- (void)stopPublishingStream;


#pragma mark - Media player
/**
 * 切换原唱/伴奏
 */
- (void)setAudioTrackAsOriginal:(BOOL)original;

#pragma mark - Net quality test
/**
 * 开始网络测速
 */
- (void)startNetworkSpeedTest;

/**
 * 停止网络测速
 */
- (void)stopNetworkSpeedTest;

@end


NS_ASSUME_NONNULL_END
