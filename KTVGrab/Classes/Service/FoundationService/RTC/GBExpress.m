//
//  KTVExpress.m
//  GoChat
//
//  Created by Vic on 2022/2/17.
//  Copyright © 2022 zego. All rights reserved.
//

#import "GBExpress.h"
#import "GBExternalDependency.h"
#import "GBSong.h"
#import "GBSDKModel.h"
#import "GBTokenService.h"
#import <YYKit/YYKit.h>

static NSString * const GBIMErrorDomain = @"im.zego.KTVGrab.express";

#define ee(x) [self newErrorWithErrorCode:(x)]

@interface GBExpress () <ZegoCopyrightedMusicEventHandler>

@property (nonatomic, strong) ZegoExpressEngine *expressEngine;
@property (nonatomic, strong) ZegoCopyrightedMusic *copyrightMusic;
@property (nonatomic, strong) ZegoMediaPlayer *mediaPlayer;

@property (nonatomic, weak) id<GBRTCRoomCnctListener> roomCnctListener;
@property (nonatomic, weak) id<GBRTCMediaEventListener> mediaEventListener;
@property (nonatomic, weak) id<GBRTCStreamEventListener> streamEventListener;
@property (nonatomic, weak) id<GBRTCQualityEventListener> netQualityEventListener;

@property (nonatomic, strong) NSMutableDictionary<NSString *, GBSongDownloadCallback> *downloadCallbacks; //resourceID: callback
@property (nonatomic, strong) NSMutableSet *downloadFinishedSongIDs;
@property (nonatomic, strong) GBErrorBlock loginCompletionBlock;
@property (nonatomic, assign) BOOL loggedIn;

@end

@implementation GBExpress

+ (instancetype)shared {
  static dispatch_once_t onceToken;
  static id _instance;
  dispatch_once(&onceToken, ^{
    _instance = [[self alloc] init];
  });
  return _instance;
}

- (NSString *)getVersion {
  return [ZegoExpressEngine getVersion];
}

- (void)create {
  [self expressPreConfig];
  [self createExpress];
  [self expressPostSetup];
}

- (void)destroy:(GBEmptyBlock)block {
  [ZegoExpressEngine destroyEngine:^{
    [self reset];
    !block ?: block();
  }];
  
  /**
   * 因为 Engine 销毁不会销毁 config, 所以重新设置一遍
   */
  ZegoEngineConfig *config = [[ZegoEngineConfig alloc] init];
  config.advancedConfig = @{
    @"sei_audio_drive":             @"false",
    @"bluetooth_capture_only_voip": @"false",
    @"ktv_adapt_device_delay":      @"false",
  };
  [ZegoExpressEngine setEngineConfig:config];
}

- (void)reset {
  self.expressEngine = nil;
  self.mediaPlayer = nil;
  self.copyrightMusic = nil;
  self.downloadCallbacks = nil;
  self.downloadFinishedSongIDs = nil;
  self.loginCompletionBlock = nil;
  self.loggedIn = NO;
}

#pragma mark -
#pragma mark - Private
#pragma mark - Express setup
- (void)createExpress {
  ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
  profile.appID = [GBExternalDependency shared].appID;
  profile.scenario = ZegoScenarioGeneral;
  
  GB_LOG_D(@"[RTC]Create Express: %@", [self getVersion]);
  ZegoExpressEngine *express = [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
  self.expressEngine = express;
}


- (void)expressPreConfig {
  ZegoEngineConfig *config = [[ZegoEngineConfig alloc] init];
  config.advancedConfig = @{
    //音频设备模式
    @"audio_device_mode":@"2",
    //超低延时模式
    @"ultra_low_latency":@"true",
    @"enforce_audio_loopback_in_sync":@"true",
    //高通滤波器
    @"prep_high_pass_filter":@"false",
    //推拉流质量回调周期
    @"publish_quality_interval":@"500",
    @"play_quality_interval":@"500",
    @"sei_audio_drive": @"true",
    @"room_retry_time": [NSString stringWithFormat:@"%d", GB_NET_TIME_OUT_SECOND],
    //蓝牙耳机在非通话场景，只使用单工模式（只播放，不能采集，采集使用手机只带麦克风）
    //蓝牙耳机在双工的情况下，只能使用通话模式，此时会引入明显的耳返延迟，同时蓝牙耳机双工的情况下，由于协议的原因，播放音质会有明显的下降。
    @"bluetooth_capture_only_voip": @"true",
    //自适应播放延迟
    @"auxiliary_delay_mode": @"0",
    //主路推流时间戳偏移伴奏播放延迟
    @"ktv_adapt_device_delay": @"true",
  };
  [ZegoExpressEngine setEngineConfig:config];
}


#pragma mark - Post setup
- (void)expressPostSetup {
  [self.expressEngine enableCamera:NO];
  [self setMainPublisherStandardQuality];
  [self setupAuxChannel];
  [self setupSEI];
  [self setupSoundLevel];
  [self setupMedia];
  [self setup3A];
}

- (void)setupAuxChannel {
  ZegoCustomAudioConfig *config = [[ZegoCustomAudioConfig alloc] init];
  config.sourceType = ZegoAudioSourceTypeMediaPlayer;
  [[ZegoExpressEngine sharedEngine] enableCustomAudioIO:YES config:config channel:ZegoPublishChannelAux];
}

- (void)setupSEI {
  ZegoSEIConfig *seiConfig = [ZegoSEIConfig defaultConfig];
  seiConfig.type = ZegoSEITypeZegoDefined;
  [[ZegoExpressEngine sharedEngine] setSEIConfig:seiConfig];
}

- (void)setupSoundLevel {
  [[ZegoExpressEngine sharedEngine] startSoundLevelMonitor];
}

- (void)setupMedia {
  [self setIemValue:50];
  [self setIemEnable:NO];
  [self setVoiceCaptureVolume:100];
  [self setReverbPreset:ZegoReverbPresetRecordingStudio];
}

- (void)setup3A {
  [[ZegoExpressEngine sharedEngine] enableAEC:YES];
  [[ZegoExpressEngine sharedEngine] enableAGC:NO];
  [[ZegoExpressEngine sharedEngine] enableANS:YES];
  [[ZegoExpressEngine sharedEngine] setAECMode:ZegoAECModeSoft];
  [[ZegoExpressEngine sharedEngine] setANSMode:ZegoANSModeMedium];
  [[ZegoExpressEngine sharedEngine] enableHeadphoneAEC:NO];
}

#pragma mark - Internal
- (NSError *)newErrorWithErrorCode:(int)errorCode {
  NSError *err = [NSError errorWithDomain:GBIMErrorDomain code:errorCode userInfo:nil];
  GB_LOG_E(@"[RTC] Error: %@", err.debugDescription);
  if (errorCode == 0) {
    return nil;
  }
  return err;
}

#pragma mark - Copyrighted music
- (void)setCopyrightMusic:(ZegoCopyrightedMusic *)copyrightMusic {
  _copyrightMusic = copyrightMusic;
  GB_LOG_D(@"[RTC][CM] Set: %@", copyrightMusic);
}

#pragma mark - Public
- (void)createCopyrightMusicWithCompletion:(GBErrorBlock)completionBlock {
  NSString *userID = [GBExternalDependency shared].userID;
  NSString *userName = [GBExternalDependency shared].userName;
  ZegoUser *user = [[ZegoUser alloc] initWithUserID:userID userName:userName];
  
  ZegoCopyrightedMusic *crm = [[ZegoExpressEngine sharedEngine] createCopyrightedMusic];
  GB_LOG_D(@"[RTC][CM] Create: %@", crm);
  ZegoCopyrightedMusicConfig *config = [[ZegoCopyrightedMusicConfig alloc] init];
  config.user = user;
  [crm setEventHandler:self];
  self.copyrightMusic = crm;
  
  self.downloadCallbacks = [NSMutableDictionary dictionary];
  self.downloadFinishedSongIDs = [NSMutableSet set];
  
  [crm initCopyrightedMusic:config callback:^(int errorCode) {
    !completionBlock ?: completionBlock(ee(errorCode));
  }];
}

#pragma mark - Function
- (void)requestSongClipWithSongID:(NSString *)songID complete:(nonnull void (^)(NSError * _Nonnull, GBSong * _Nonnull))complete {
  ZegoCopyrightedMusicRequestConfig *config = [[ZegoCopyrightedMusicRequestConfig alloc] init];
  config.songID = songID;
  config.mode = ZegoCopyrightedMusicBillingModeRoom;
  
  [self.copyrightMusic requestAccompanimentClip:config callback:^(int errorCode, NSString * _Nonnull resource) {
    GBSDKModel *responseModel = [GBSDKModel modelWithJSON:resource];
    GBSDKSongClip *sdkSongClip = [GBSDKSongClip modelWithJSON:responseModel.data];
    GBSong *songClip = [[GBSong alloc] init];
    [songClip updateWithSDKSongClip:sdkSongClip];
    !complete ?: complete(ee(errorCode), songClip);
  }];
}

- (void)requestSongLyricWithKrcToken:(NSString *)krcToken complete:(void(^)(NSError *error, NSString *lyric))complete {
  [self.copyrightMusic getKrcLyricByToken:krcToken callback:^(int errorCode, NSString * _Nonnull lyrics) {
    NSError *err = nil;
    if (errorCode != 0) {
      err = ee(errorCode);
    }
    !complete ?: complete(err, lyrics);
  }];
}

- (void)downloadResource:(NSString *)resourceID callback:(GBSongDownloadCallback)callback {
  @weakify(self);
  if (!resourceID) {
    !callback ?: callback(ee(-1), 0);
    return;
  }
  if (callback) {
    [self.downloadCallbacks setObject:callback forKey:resourceID];
  }
  [self.copyrightMusic download:resourceID callback:^(int errorCode) {
    @strongify(self);
    if (errorCode != 0) {
      NSError *err = ee(errorCode);
      GB_LOG_E(@"[RTC] Download resource with error: %@, resourceID: %@", err, resourceID);
      if (callback) {
        callback(err, 0);
      }
    }
  }];
}

- (void)requestPitchWithResourceID:(NSString *)resourceID complete:(void(^)(NSError *error, NSString *pitchJson))complete {
  @weakify(self);
  [self.copyrightMusic getStandardPitch:resourceID callback:^(int errorCode, NSString * _Nonnull pitch) {
    @strongify(self);
    NSError *err = nil;
    if (errorCode != 0) {
      err = ee(errorCode);
      GB_LOG_E(@"[RTC] Get pitch with error: %@, resourceID: %@", err, resourceID);
    }
    !complete ?: complete(err, pitch);
  }];
}

#pragma mark - Score
- (void)startScore:(NSString *)resourceID {
  if (resourceID.length > 0) {
    [self resetScore:resourceID];
    GB_LOG_D(@"[SCORE] Start score for: %@", resourceID);
    [self.copyrightMusic startScore:resourceID pitchValueInterval:30];
  }
}

- (void)stopScore:(NSString *)resourceID {
  if (resourceID.length > 0) {
    GB_LOG_D(@"[SCORE] Stop score: %@", resourceID);
    [self.copyrightMusic stopScore:resourceID];
  }
}

- (void)resetScore:(NSString *)resourceID {
  if (resourceID.length > 0) {
    GB_LOG_D(@"[SCORE] Reset score: %@", resourceID);
    [self.copyrightMusic resetScore:resourceID];
  }
}

- (int)getPrevScore:(NSString *)resourceID {
  if (resourceID.length > 0) {
    int score = [self.copyrightMusic getPreviousScore:resourceID];
    GB_LOG_D(@"[SCORE] Get prev score: %d, for: %@", score, resourceID);
    return score;
  }
  return 0;
}

- (int)getAvgScore:(NSString *)resourceID {
  if (resourceID.length > 0) {
    int score = [self.copyrightMusic getAverageScore:resourceID];
    GB_LOG_D(@"[SCORE] Get avg score: %d, for: %@", score, resourceID);
    return score;
  }
  return 0;
}

#pragma mark - Callback
- (void)onDownloadProgressUpdate:(ZegoCopyrightedMusic *)copyrightedMusic resourceID:(NSString *)resourceID progressRate:(float)progressRate {
  GBSongDownloadCallback block = self.downloadCallbacks[resourceID];
  if (progressRate < 1) {
    if (block) {
      block(nil, progressRate);
    }
  }
  else {
    NSLog(@"[RTC] onDownloadProgressUpdate: %.2f, resource_id: %@", progressRate, resourceID);
    BOOL finished = [self.downloadFinishedSongIDs containsObject:resourceID];
    if (!finished) {
      [self.downloadFinishedSongIDs addObject:resourceID];
      if (block) {
        block(nil, 1);
      }
    }
  }
}

- (void)onCurrentPitchValueUpdate:(ZegoCopyrightedMusic *)copyrightedMusic resourceID:(NSString *)resourceID currentDuration:(int)currentDuration pitchValue:(int)pitchValue {
  GB_INTERVAL_EXECUTE(kGBPitchLogInterval, 20, ^{
    GB_LOG_D(@"[SCORE] On pitch update: %d, rscID: %@, duration: %d", pitchValue, resourceID, currentDuration);
  })
  [self.mediaEventListener onCopyrightSongResource:resourceID pitchUpdate:pitchValue atProgress:currentDuration];
}

#pragma mark - Media
#pragma mark - Public
- (ZegoMediaPlayer *)createMediaPlayer {
  if (!self.mediaPlayer) {
    ZegoMediaPlayer *player = [[ZegoExpressEngine sharedEngine] createMediaPlayer];
    [player setEventHandler:self];
    [player enableAux:YES];
    [player setProgressInterval:500];
    [self setMediaPlayerVolume:50];
    self.mediaPlayer = player;
  }
  return self.mediaPlayer;
}

- (void)clearMediaPlayer {
  self.mediaPlayer = nil;
}

- (void)startPlayingCopyrightResource:(NSString *)resourceID atProgress:(NSInteger)progress {
  [self.mediaPlayer stop];
  @weakify(self);
  [self.mediaPlayer loadCopyrightedMusicResourceWithPosition:resourceID startPosition:progress callback:^(int errorCode) {
    @strongify(self);
    if (errorCode != 0) {
      NSError *error = ee(errorCode);
      GB_LOG_E(@"[RTC] Media player load resource error: %@", error);
    }else {
      [self.mediaPlayer start];
    }
  }];
}

- (void)stopPlayingMedia {
  [self.mediaPlayer stop];
}

- (void)setLocalPlayerVolume:(CGFloat)volume {
  [self.mediaPlayer setPlayVolume:volume];
}

- (void)setPublishVolume:(CGFloat)volume {
  [self.mediaPlayer setPlayVolume:volume];
  [self.mediaPlayer setPublishVolume:volume];
}

- (void)setAudioTrackAsOriginal:(BOOL)original {
  [self.mediaPlayer setAudioTrackIndex:original];
}

- (void)startNetworkSpeedTest {
  ZegoNetworkSpeedTestConfig *config = [[ZegoNetworkSpeedTestConfig alloc] init];
  config.testUplink = YES;
  config.expectedUplinkBitrate = 128;
  GB_LOG_D(@"[NQ] Start net speed test: %@", [ZegoExpressEngine sharedEngine]);
  [[ZegoExpressEngine sharedEngine] startNetworkSpeedTest:config interval:1000];
}

- (void)stopNetworkSpeedTest {
  [[ZegoExpressEngine sharedEngine] stopNetworkSpeedTest];
}

#pragma mark - Device
- (void)setMicEnable:(BOOL)enable {
  _micEnable = enable;
  GB_LOG_D(@"[RTC][MEDIA] Enable Mic: %d", enable);
  [self.expressEngine muteMicrophone:!enable];
}

- (void)setIemEnable:(BOOL)enable {
  _iemEnable = enable;
  GB_LOG_D(@"[RTC][MEDIA] Enable IEM: %d", enable);
  [self.expressEngine enableHeadphoneMonitor:enable];
}

- (void)setIemValue:(CGFloat)value {
  _iemValue = value;
  GB_LOG_D(@"[RTC][MEDIA] Set IEM volume: %.0f", value);
  [self.expressEngine setHeadphoneMonitorVolume:value];
}

- (void)setReverbPreset:(ZegoReverbPreset)value {
  _reverbPreset = value;
  GB_LOG_D(@"[RTC][MEDIA] Set reverb preset: %lu", (unsigned long)value);
  [self.expressEngine setReverbPreset:value];
}

- (void)setMediaPlayerVolume:(CGFloat)value {
  _mediaPlayerVolume = value;
  GB_LOG_D(@"[RTC][MEDIA] Set Media player volume: %.0f", value);
  [self setPublishVolume:value];
}

- (void)setVoiceCaptureVolume:(CGFloat)value {
  _voiceCaptureVolume = value;
  GB_LOG_D(@"[RTC][MEDIA] Set voice capture volume: %.0f", value);
  [self.expressEngine setCaptureVolume:value];
}

#pragma mark - Room
- (void)loginRoomWithID:(NSString *)roomID complete:(GBErrorBlock)complete {
  
  GBErrorBlock block = ^(NSError *err) {
    if (err) {
      GB_LOG_E(@"[RTC] Login failed with error: %@", err);
    }else {
      GB_LOG_D(@"[RTC] Login success");
    }
    complete(err);
  };
  
  self.loginCompletionBlock = block;
  
  ZegoUser *user = [ZegoUser userWithUserID:[[GBExternalDependency shared] userID]
                                   userName:[[GBExternalDependency shared] userName]];
  ZegoRoomConfig *config = [[ZegoRoomConfig alloc] init];
  config.isUserStatusNotify = YES;
  config.token = [[GBTokenService shared] getCacheToken];
  [[ZegoExpressEngine sharedEngine] loginRoom:roomID user:user config:config];
}

- (void)logout {
  [[ZegoExpressEngine sharedEngine] logoutRoom];
  [self stopNetworkSpeedTest];
  [self reset];
}

- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
  GB_LOG_D(@"[RTC] onRoomStateUpdate: %lu, errorCode: %d, roomID: %@", (unsigned long)state, errorCode, roomID);
  switch (state) {
    case ZegoRoomStateDisconnected:
    {
      if (self.loggedIn) {
        if (errorCode == ZegoErrorCodeRoomKickedOut) {
          [self.roomCnctListener onRTCRoomKickout];
        }else {
          // 判定为登录失败
          [self.roomCnctListener onRTCRoomDisconnected];
        }
        self.loggedIn = NO;
      }else {
        if (self.loginCompletionBlock) {
          self.loginCompletionBlock(ee(errorCode));
        }
      }
    }
      break;
      
    case ZegoRoomStateConnecting:
    {
      if (self.loggedIn) {
        [self.roomCnctListener onRTCRoomReconnecting];
      }
    }
      break;
      
    case ZegoRoomStateConnected:
    {
      if (self.loggedIn) {
        [self.roomCnctListener onRTCRoomReconnected];
      }else {
        self.loggedIn = YES;
        if (self.loginCompletionBlock) {
          // 进房后才能开启网络测速
          [self startNetworkSpeedTest];
          self.loginCompletionBlock(nil);
        }
      }
    }
      break;
  }
}

#pragma mark - SEI
- (void)sendSEI:(NSData *)data {
  [self.expressEngine sendSEI:data channel:ZegoPublishChannelMain];
}

#pragma mark - Stream
- (void)setMainPublisherStandardQuality {
  ZegoAudioConfig *oldAudioConfig = [[ZegoExpressEngine sharedEngine] getAudioConfig];
  if (oldAudioConfig.channel != ZegoAudioChannelMono || oldAudioConfig.bitrate != 48) {
    ZegoAudioConfig *audioConfig = [[ZegoAudioConfig alloc] initWithPreset:ZegoAudioConfigPresetStandardQuality];
    audioConfig.channel = ZegoAudioChannelMono;
    audioConfig.codecID = ZegoAudioCodecIDLow3;
    audioConfig.bitrate = 48;
    [[ZegoExpressEngine sharedEngine] setAudioConfig:audioConfig channel:ZegoPublishChannelMain];
    [self.expressEngine setAudioCaptureStereoMode:ZegoAudioCaptureStereoModeNone];
  }
}

- (void)setMainPublisherHighQuality {
  ZegoAudioConfig *oldAudioConfig = [[ZegoExpressEngine sharedEngine] getAudioConfig];
  if (oldAudioConfig.channel != ZegoAudioChannelStereo || oldAudioConfig.bitrate != 128) {
    ZegoAudioConfig *audioConfig = [[ZegoAudioConfig alloc] initWithPreset:ZegoAudioConfigPresetHighQuality];
    audioConfig.channel = ZegoAudioChannelStereo;
    audioConfig.codecID = ZegoAudioCodecIDLow3;
    audioConfig.bitrate = 128;
    [[ZegoExpressEngine sharedEngine] setAudioConfig:audioConfig channel:ZegoPublishChannelMain];
    [self.expressEngine setAudioCaptureStereoMode:ZegoAudioCaptureStereoModeAlways];
  }
}

- (void)playStream:(NSString *)streamID {
  GB_LOG_D(@"[RTC][STREAM]Start playing stream: %@", streamID);
  [self.expressEngine startPlayingStream:streamID canvas:nil];
}

- (void)stopPlayingStream:(NSString *)streamID {
  GB_LOG_D(@"[RTC][STREAM]Stop playing stream: %@", streamID);
  [self.expressEngine stopPlayingStream:streamID];
}

- (void)startPublishingStream:(NSString *)streamID {
  GB_LOG_D(@"[RTC][STREAM]Start publishing stream: %@", streamID);
  [self.expressEngine startPublishingStream:streamID];
}

- (void)stopPublishingStream {
  GB_LOG_D(@"[RTC][STREAM]Stop publishing stream");
  [self.expressEngine stopPublishingStream];
}

- (void)onAudioRouteChange:(ZegoAudioRoute)audioRoute {
  
}

@end


@interface GBExpress (Callback)

@end

@implementation GBExpress (Callback)

- (void)onDebugError:(int)errorCode funcName:(NSString *)funcName info:(NSString *)info {
  GB_LOG_E(@"[RTC] onDebugError: %d, funcName:%@, info: %@", errorCode, funcName, info);
}

#pragma mark - MediaPlayer
- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer playingProgress:(unsigned long long)millisecond {
  [self.mediaEventListener onMediaPlayerProgressUpdate:millisecond];
}

- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer stateUpdate:(ZegoMediaPlayerState)state errorCode:(int)errorCode {
  [self.mediaEventListener onMediaPlayerStateUpdate:state];
}

- (void)onPlayerRecvSEI:(NSData *)data streamID:(NSString *)streamID {
  [self.streamEventListener onRTCStream:streamID receiveSEIData:data];
}

#pragma mark - Stream event
- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
  for (ZegoStream *stream in streamList) {
    if (updateType == ZegoUpdateTypeAdd) {
      GB_LOG_D(@"[RTC][STREAM]On add stream: %@", stream.streamID);
      [self.streamEventListener onRTCAddStream:stream];
    }else {
      GB_LOG_D(@"[RTC][STREAM]On remove stream: %@", stream.streamID);
      [self.streamEventListener onRTCRemoveStream:stream];
    }
  }
}

- (void)onRemoteSoundLevelUpdate:(NSDictionary<NSString *,NSNumber *> *)soundLevels {
  [soundLevels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull streamID, NSNumber * _Nonnull level, BOOL * _Nonnull stop) {
    [self.streamEventListener onRTCStream:streamID soundLevelUpdate:level.floatValue];
  }];
}

- (void)onCapturedSoundLevelUpdate:(NSNumber *)soundLevel {
  [self.streamEventListener onRTCStreamCapturedSoundLevelUpdate:[soundLevel floatValue]];
}

#pragma mark - Network quality
- (void)onNetworkSpeedTestError:(int)errorCode type:(ZegoNetworkSpeedTestType)type {
  [self.netQualityEventListener onRTCNetSpeedTestUpdate:nil error:ee(errorCode)];
}

- (void)onNetworkSpeedTestQualityUpdate:(ZegoNetworkSpeedTestQuality *)quality type:(ZegoNetworkSpeedTestType)type {
  [self.netQualityEventListener onRTCNetSpeedTestUpdate:quality error:nil];
}

- (void)onPlayerQualityUpdate:(ZegoPlayStreamQuality *)quality streamID:(NSString *)streamID {
//  NSLog(@"[RTC] onPlayerQualityUpdate rtt: %d, streamID: %@", quality.rtt, streamID);
  [self.netQualityEventListener onRTCStreamQualityUpdate:quality playStreamID:streamID];
}

- (void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality streamID:(NSString *)streamID {
  [self.netQualityEventListener onRTCStreamQualityUpdate:quality publishStreamID:streamID];
}

- (void)onNetworkQuality:(NSString *)userID upstreamQuality:(ZegoStreamQualityLevel)upstreamQuality downstreamQuality:(ZegoStreamQualityLevel)downstreamQuality {
  NSLog(@"[RTC] onNetworkQuality:%@, upstreamQuality: %lu, downstreamQuality: %lu", userID, (unsigned long)upstreamQuality, downstreamQuality);
  if (upstreamQuality != ZegoStreamQualityLevelUnknown) {
    [self.netQualityEventListener onRTCNetworkQualityUpdate:upstreamQuality userID:userID];
  }
}

@end
