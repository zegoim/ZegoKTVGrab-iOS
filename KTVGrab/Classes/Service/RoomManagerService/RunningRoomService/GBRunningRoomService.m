//
//  GBRunningRoomService.m
//  KTVGrab
//
//  Created by Vic on 2022/3/21.
//

#import "GBRunningRoomService.h"

#import "GBIM.h"
#import "GBExpress.h"
#import "GBDataProvider.h"
#import "GBSong.h"
#import "GBSongPlay.h"
#import "GBSEIModel.h"
#import "GBRoomManager.h"
#import "GBNetQualityModel.h"


#define CHECK_SONG [self validateCurSong]
#define GBTOAST(x) [self.delegate toastMsg:(x)];

@interface GBRunningRoomService ()
<
GBIMCnctListener,
GBProgressSimListener,
GBMediaPlayerStateListener,
GBSongResourceDownloadListener,
GBRoomInfoUpdateListener,
GBSongListListener,
GBRoomUserEventListener,
GBRoomUserSEIListener,
GBSongScoreEventListener,
GBSeatEventListener,
GBRoomUserNetQualityListener,
GBRoomUserAwaringListener,
GBRoomCnctListener
>

@property (nonatomic,  weak ) id<GBRunningRoomEvent> delegate;
@property (nonatomic,  weak ) id<GBRunningRoomLeaveBackendRoomListener> leaveBackendRoomListener;
@property (nonatomic, strong) NSPointerArray *lifeCycleListeners;

@property (nonatomic, assign) BOOL shouldSendSEI;
@property (nonatomic, assign) BOOL shouldReportDownloadFinish;
@property (nonatomic, assign) GBMediaPlayerState mediaPlayerState;
@property (nonatomic, strong) YYThreadSafeDictionary *userQualityTable;
/// Singing 阶段网络差的toast提示只弹一次
@property (nonatomic, assign) NSUInteger lastBadCnctToastSeq;
@property (nonatomic, assign) BOOL inCleaningSDKProcess;

@end

@interface GBRunningRoomService (Helper)

- (BOOL)shouldSendingSEIForRoomState:(GBRoomState)roomState;
- (BOOL)shouldPublishStreamForRoomState:(GBRoomState)roomState;
- (BOOL)shouldPlayHostStreamForRoomState:(GBRoomState)state;
- (BOOL)shouldTurnOnMicrophoneAsDefaultForRoomState:(GBRoomState)state;
- (BOOL)shouldUseHighAudioQualityForRoomState:(GBRoomState)state;
- (BOOL)shouldLocalPlayForRoomState:(GBRoomState)state;
- (BOOL)shouldStartReceivingSEISimulationForRoomState:(GBRoomState)state;
- (void)checkStreamConnectivityWhenSomeoneSinging:(GBRoomInfo *)roomInfo;
- (void)checkNetConnectivityWhenSomeoneSinging:(GBRoomInfo *)roomInfo;

@end

@implementation GBRunningRoomService

- (void)dealloc {
  GB_LOG_D(@"[DEALLOC]GBRunningRoomService dealloc");
}

- (instancetype)initWithRoomInfo:(GBRoomInfo *)roomInfo {
  self = [super init];
  if (self) {
    _roomInfo = roomInfo;
    [self setup];
  }
  return self;
}

- (void)setup {
  self.userQualityTable = [YYThreadSafeDictionary dictionary];
  
  self.heartbeatService         = [[GBHeartbeatService alloc] init];
  self.userService              = [[GBRoomUserService alloc] init];
  self.eventAgent               = [[GBSDKEventAgent alloc] init];
  self.songResourceProvider     = [[GBSongResourceProvider alloc] init];
  self.mediaPlayer              = [[GBMediaPlayer alloc] init];
  self.mediaProgressSimulator   = [[GBMediaProgressSimulator alloc] init];
  self.roomInfoService          = [[GBRoomInfoService alloc] init];
  self.songListService          = [[GBSongListService alloc] init];
  self.seiService               = [[GBSEIService alloc] init];
  self.scoreService             = [[GBScoreService alloc] init];
  self.seatService              = [[GBSeatService alloc] init];
  self.audioQualityService      = [[GBAudioQualityService alloc] init];
  self.sdkCnctService           = [[GBSDKCnctService alloc] init];
  
  [self.sdkCnctService          setListener:self];
  [self.eventAgent              setUserUpdateListener:self.userService];
  [self.eventAgent              setSongListUpdateListener:self.songListService];
  [self.eventAgent              setRoomStateListener:self.roomInfoService];
  [self.mediaPlayer             appendEventListener:self];
  [self.mediaPlayer             appendEventListener:self.mediaProgressSimulator];
  [self.mediaPlayer             setProgressListener:self.mediaProgressSimulator];
  [self.mediaPlayer             setScoreEventListener:self];
  [self.mediaProgressSimulator  setListener:self];
  [self.songResourceProvider    setListener:self];
  [self.roomInfoService        setListener:self];
  [self.songListService         setListener:self];
  [self.seatService             setListener:self];
  [self.userService             setEventListener:self.seatService];
  [self.userService             setUserAwaringListener:self];
  [self.userService             appendSeiListeners:@[self.mediaProgressSimulator, self.songResourceProvider]];
  [self.userService             appendQualityUpdateListeners:@[self.seatService, self]];;
  
  self.lifeCycleListeners = [NSPointerArray weakObjectsPointerArray];
}

#pragma mark - Public
- (void)startWithRoomInfo:(GBRoomInfo *)roomInfo {
  /**
   * 1. 开启心跳
   * 2. 同步用户列表
   * 3. 同步歌单
   * 4. 同步房间状态
   */
  [self.heartbeatService startRepeatedlyHeartbeatWithRoomID:roomInfo.roomID];
  [self.userService forceUpdateUserList:roomInfo.roomUsers];
  [self updateSongPlaysIfNeeded:![self.userService isMyselfHost]];
  [self.roomInfoService forceUpdatingRoomInfo:roomInfo];
}

- (void)start {
  [self startWithRoomInfo:self.roomInfo];
  if (self.roomInfo.roomState == GBRoomStateGrabWaiting ||
      self.roomInfo.roomState == GBRoomStateGrabSuccessfully ||
      self.roomInfo.roomState == GBRoomStateSinging) {
    if ([[[GBUserAccount shared] getMyAuthority] canGrab]) {
      [self.delegate alertCurSongGrabNotAllowed];
    }
  }
}

- (void)synchronizeToLatestRoomState {
  @weakify(self);
  [GBDataProvider getRoomInfoWithRoomID:self.roomInfo.roomID complete:^(BOOL suc, NSError * _Nullable err, GBRoomRespModel * _Nonnull model) {
    @strongify(self);
    if (!suc) {
      [self.delegate toastMsg:[NSString stringWithFormat:@"同步房间状态失败: %@", err]];
    }
    else if (!err && model) {
      GBRoomInfo *roomInfo = [[GBRoomInfo alloc] init];
      [roomInfo updateWithRoomRespModel:model];
      [self startWithRoomInfo:roomInfo];
    }
    else {
      [self.delegate alertRoomHasBeenDestroyed];
    }
  }];
}

- (BOOL)hasAnotherRound {
  return self.roomInfo.curRound < self.roomInfo.rounds;
}

- (void)startRound {
  [GBDataProvider startRoundWithRoomID:self.roomInfo.roomID complete:^(BOOL suc, NSError * _Nullable err, id  _Nullable rsv) {
    if (!err) {
      GB_LOG_D(@"Start round in success");
    }else {
      GB_LOG_E(@"Start round in failure with error: %@", err);
      [self.delegate toastMsg:[NSString stringWithFormat:@"开始抢唱失败:%ld", (long)err.code]];
    }
  }];
}

- (void)enterNextRound {
  [GBDataProvider enterNextRoundWithRoomID:self.roomInfo.roomID complete:^(BOOL suc, NSError * _Nullable err, id  _Nullable rsv) {
    if (!err) {
      GB_LOG_D(@"Enter next round in success");
    }else {
      GB_LOG_E(@"Enter next round in failure with error: %@", err);
      [self.delegate toastMsg:[NSString stringWithFormat:@"再来一轮失败:%ld", (long)err.code]];
    }
  }];
}

- (void)grabCurSong {
  [GBDataProvider grabMicWithRoomID:self.roomInfo.roomID
                              round:self.roomInfo.curRound
                              index:self.roomInfo.curSongIndex
                           complete:^(BOOL suc, NSError * _Nullable err, id  _Nullable rsv) {
    if (!err) {
      GB_LOG_D(@"Grab song in success");
    }else {
      GB_LOG_E(@"Grab song in failure with error: %@", err);
      [self.delegate toastMsg:[NSString stringWithFormat:@"抢唱失败:%ld", (long)err.code]];
    }
  }];
}

- (void)enableMicrophone:(BOOL)enable toast:(BOOL)flag {
  @weakify(self);
  if (enable) {
    [self.userService startSendingMySoundWithCompletion:^(BOOL suc) {
      @strongify(self);
      if (suc) {
        if (flag) {
          [self.delegate toastMsg:@"麦克风已开启"];
        }
      }
    }];
  }else {
    [self.userService stopSendingMySoundWithCompletion:^(BOOL suc) {
      @strongify(self);
      if (suc) {
        if (flag) {
          [self.delegate toastMsg:@"麦克风已关闭"];
        }
      }
    }];
  }
}

#pragma mark - Setter & Getter
#pragma mark - GBSDKRoomEvent
- (void)onRoomDisconnected {
  [self.delegate onRoomDisconnected];
}

- (void)onRoomReconnecting {
  [self.delegate onRoomReconnecting];
}

- (void)onRoomReconnected {
  [self synchronizeToLatestRoomState];
  [self.delegate onRoomReconnected];
}

- (void)onRoomKickout {
  [self.delegate onRoomKickout];
}

#pragma mark - Private
- (void)setRoomInfo:(GBRoomInfo *)roomInfo {
  _roomInfo = roomInfo;
  [self.userService setRoomInfo:roomInfo];
  [self _updateRoomInfo:roomInfo checkSong:CHECK_SONG];
}

- (void)_prepareSongPlays:(NSArray<GBSongPlay *> *)songList inRound:(NSUInteger)round {
  if ([self.userService isMyselfHost]) {
    GB_LOG_D(@"[SONG_LIST] Prepare song list for host");
    [self.songResourceProvider prepareSongPlaysInBatches:songList inRound:round];
  }else {
    GB_LOG_D(@"[SONG_LIST] Prepare song list for player");
    [self.songResourceProvider prepareSongPlaysInSequence:songList inRound:round];
  }
}

- (void)_updateRoomInfo:(GBRoomInfo *)roomInfo checkSong:(BOOL)available {
  
  GBRoomState roomState = roomInfo.roomState;
  
  /**
   * 检测其他人在歌唱时候的拉流状况, 如果有异常则 toast 提示
   * 自己端唱歌时的网络检测依赖 -[checkNetConnectivityWhenSomeoneSinging:] 方法
   */
  [self checkStreamConnectivityWhenSomeoneSinging:roomInfo];
  
  /**
   * 控制是否拉取房主流
   */
  if ([self shouldPlayHostStreamForRoomState:roomState]) {
    [self.userService playHostStream:YES];
  }else {
    [self.userService playHostStream:NO];
  }
  
  /**
   * 控制本端推流
   */
  if ([self shouldPublishStreamForRoomState:roomState]) {
    [self.userService startSendingMyStream];
  }else {
    [self.userService stopSendingMyStream];
  }
  
  /**
   * 控制本地音乐播放
   */
  if ([self shouldLocalPlayForRoomState:roomState]) {
    /**
     * 考虑断网重连情况更新 roomState
     * 如果当前播放器正在播放, 则不需要从头播放音乐
     */
    if (self.mediaPlayerState != GBMediaPlayerStatePlaying) {
      self.shouldSendSEI = YES;
      if (roomState == GBRoomStateGrabWaiting) {
        //播放原唱
        [self playCurSongWithOriginal:YES];
      }else {
        //播放伴奏
        [self playCurSongWithOriginal:NO];
      }
    }
  }else {
    self.shouldSendSEI = NO;
    [self.mediaPlayer stopPlaying];
  }
  
  /**
   * 控制接收 SEI 进度模拟回调
   */
  if ([self shouldStartReceivingSEISimulationForRoomState:roomState]) {
    [self.mediaProgressSimulator startSEIProgressSimulation];
  }else {
    [self.mediaProgressSimulator stopSEIProgressSimulation];
  }
  
  /**
   * 控制麦克风默认开闭
   */
  if ([self shouldTurnOnMicrophoneAsDefaultForRoomState:roomState]) {
    [self enableMicrophone:YES toast:NO];
  }else {
    [self enableMicrophone:NO toast:NO];
  }
  
  /**
   * 控制是否开启 RTC 高音质配置
   */
  if ([self shouldUseHighAudioQualityForRoomState:roomState]) {
    [self.audioQualityService setHighAudioQuality];
  }else {
    [self.audioQualityService setStandardAudioQuality];
  }
}

- (BOOL)validateCurSong {
  return [self.songResourceProvider validateSongWithSongID:self.roomInfo.curSongID];
}

- (void)playCurSongWithOriginal:(BOOL)original {
  if (self.mediaPlayerState == GBMediaPlayerStatePlaying) {
    return;
  }
  /*
   1. 发送 SEI
   2. 推流
   */
  [self.mediaPlayer setSoundTrackAsOriginal:original];
  
  int prelude = 0;
  if (!original) {
    prelude = 3000;
  }
  [self.mediaPlayer startPlayingSong:[self getCurSong] prelude:prelude];
}

- (void)updateSongPlaysIfNeeded:(BOOL)needUpdate {
  [self.songListService forceUpdatingSongPlays:self.roomInfo.songPlays
                                       inRound:self.roomInfo.curRound];
}

- (void)sendSEIWhenNecessaryWithProgress:(NSInteger)progress {
  if (self.shouldSendSEI) {
    GBUser *myself = [self.userService getMyself];
    GBSong *song = [self getCurSong];
    if (self.mediaPlayerState == GBMediaPlayerStatePlaying) {
      [self.seiService sendSEIWithRole:myself.roleType
                                songID:self.roomInfo.curSongID
                           playerState:self.mediaPlayerState
                              progress:progress
                              duration:song.duration];
    }
  }
}

#pragma mark - Leave room
- (void)startBackendLeaveRoomProcess {
  if (!self.roomInfo.roomID) {
    return;
  }
  
  [self.delegate onHudStart];
  [self.heartbeatService stopRepeatedlyHeartbeat];
  NSString *roomID = self.roomInfo.roomID;
  @weakify(self);
  [GBDataProvider leaveRoomWithRoomID:roomID complete:^(BOOL suc, NSError * _Nullable err, id  _Nullable rsv) {
    @strongify(self);
    [self.delegate onHudEnd];
    if (!suc) {
      [self.delegate toastMsg:[NSString stringWithFormat:@"退出后台房间失败: %@", err]];
      return;
    }
    if (![self isMyselfHost]) {
      /**
       * 非房主继续执行退房流程, 直接退出房间即可
       * 房主需要在收到后台 push onRoomExit 的消息的时候再进行下一步
       */
      [self startServiceCleanUpProcess];
    }
  }];
}

- (void)startServiceCleanUpProcess {
  if (self.inCleaningSDKProcess) {
    return;
  }
  self.inCleaningSDKProcess = YES;
  [GBUserAccount shared].myself = nil;
  [[GBRoomManager shared] leaveRoomAndCleanUpSDK];
  [self niloutDataProperties];
  [self unloadServices];
}

- (void)niloutDataProperties {
  self.shouldSendSEI = NO;
  self.shouldReportDownloadFinish = NO;
}

- (void)unloadServices {
  self.heartbeatService         = nil;
  self.userService              = nil;
  self.eventAgent               = nil;
  self.songResourceProvider     = nil;
  self.mediaPlayer              = nil;
  self.mediaProgressSimulator   = nil;
  self.roomInfoService          = nil;
  self.songListService          = nil;
  self.seiService               = nil;
  self.scoreService             = nil;
  self.seatService              = nil;
  self.audioQualityService      = nil;
}

#pragma mark - GBSongResourceProviderProtocol
- (void)resourceProvider:(GBSongResourceProvider *)provider onPreparingCompleteInBatchesWithSongPlays:(NSArray<GBSongPlay *> *)songPlays invalidSongPlays:(NSArray<GBSongPlay *> *)invalidSongPlays inRound:(NSUInteger)round error:(NSError *)error {
  if (error) {
    return;
  }
  if (!self.shouldReportDownloadFinish) {
    return;
  }
  // 之前轮次的歌单无需上报
  if (round < self.roomInfo.curRound) {
    return;
  }
  GBTOAST(@"资源下载完成");
  NSMutableArray *invalidUniqueIDs = [NSMutableArray array];
  [invalidSongPlays enumerateObjectsUsingBlock:^(GBSongPlay * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    [invalidUniqueIDs addObject:obj.uniqueID];
  }];
  
  [GBDataProvider reportSongsReadyWithRoomID:self.roomInfo.roomID
                                     round:self.roomInfo.curRound
                                  invalidIDs:invalidUniqueIDs.copy
                                    complete:^(BOOL suc, NSError * _Nullable err, id  _Nullable rsv) {
    if (suc && !error) {
      GB_LOG_D(@"Song list download reporting in success");
    }else {
      GB_LOG_E(@"Song list download reporting in failure: %@", error);
    }
  }];
}

- (void)resourceProvider:(GBSongResourceProvider *)provider onPreparingCompleteInSequenceWithSongPlay:(GBSongPlay *)songPlay inRound:(NSUInteger)round error:(NSError *)error {
  if (error || !songPlay) {
    GB_LOG_E(@"[SONG_LIST][CB] List service preparing in sequence callback, song name: %@, song id: %@, round: %lu, error: %@", songPlay.songName, songPlay.songID, (unsigned long)round, error);
    return;
  }
  GB_LOG_D(@"[SONG_LIST][CB] List service preparing in sequence callback, song name: %@, song id: %@, round: %lu", songPlay.songName, songPlay.songID, (unsigned long)round);
  GBRoomState roomState = self.roomInfo.roomState;
  BOOL flag = (roomState == GBRoomStateGrabWaiting ||
               roomState == GBRoomStateSinging);
  GB_LOG_D(@"[SONG_LIST] Determine whether current room state: %lu, supports song UI update: %d", (unsigned long)roomState, flag);
  if (flag) {
    NSString *curPlayingSongID = [self getCurSongPlay].songID;
    BOOL shouldUpdate = [curPlayingSongID isEqualToString:songPlay.songID];
    GB_LOG_D(@"[SONG_LIST] Determine current playing song name: %@, song name completes just now: %@, should update: %d", [self getCurSongPlay].songName, songPlay.songName, shouldUpdate);
    if (shouldUpdate) {
      [self.delegate onSongInfoUIShouldUpdateWithSongPlay:songPlay checkSong:CHECK_SONG];
    }
  }
}

#pragma mark - GBRoomStateServiceProtocol
- (void)roomInfoService:(GBRoomInfoService *)service onRoomInfoUpdate:(GBRoomInfo *)roomInfo {
  [self setRoomInfo:roomInfo];
  [self.delegate onRoomStateUpdate:roomInfo checkSong:CHECK_SONG];
}

#pragma mark - GBSongListServiceProtocol
- (void)songListService:(GBSongListService *)service onSongListUpdate:(NSArray<GBSongPlay *> *)songPlays inRound:(NSUInteger)round type:(NSUInteger)type {
  GB_LOG_D(@"[SONG_LIST][CB] Song list service song plays updating command callback");
  if (type == 5) {
    self.shouldReportDownloadFinish = YES;
    [self _prepareSongPlays:songPlays inRound:round];
  }else {
    self.shouldReportDownloadFinish = NO;
  }
}

#pragma mark - MediaEvent
- (void)progressSimulator:(GBMediaProgressSimulator *)delegator onMediaSimulatedProgressUpdateEvery30ms:(NSInteger)progress {
  [self.delegate onSongProgressUpdate:progress];
}

- (void)progressSimulator:(GBMediaProgressSimulator *)simulator onMediaSimulatedProgressUpdateEvery60ms:(NSInteger)progress {
  [self sendSEIWhenNecessaryWithProgress:progress];
}

- (void)progressSimulator:(GBMediaProgressSimulator *)delegator onMediaRealProgressUpdate:(NSInteger)progress {

}

- (void)progressSimulator:(GBMediaProgressSimulator *)simulator onSimulatedSEIUpdateEvery30ms:(GBSEIModel *)seiModel {
  // 必要时提示 RoomVC 更新 UI
  GBRoomState roomState = self.roomInfo.roomState;
  
  if (roomState == GBRoomStateGrabWaiting || roomState == GBRoomStateSinging) {
    GBSongPlay *songPlay = self.getCurSongPlay;
    if (![seiModel.songID isEqualToString:songPlay.songID]) {
      return;
    }
    [self.delegate onSongInfoUIShouldUpdateBySEIWithSongPlay:songPlay progress:seiModel.progress];
  }
}

#pragma mark - GBRoomUserNetQualityListener
- (void)userService:(GBRoomUserService *)service onMyTestSpeedQualityUpdate:(GBNetQuality)qualityLevel {
  [self.delegate onNetSpeedTestQualityUpdate:qualityLevel];
}

- (void)userService:(GBRoomUserService *)service onUser:(NSString *)userID netQualityLevelUpdate:(GBNetQuality)qualityLevel {
  if (userID) {
    [self.userQualityTable setObject:@(qualityLevel) forKey:userID];
    if (qualityLevel < GBNetQualityGood) {
      [self checkNetConnectivityWhenSomeoneSinging:self.roomInfo];
    }
  }
}

#pragma mark - GBRoomUserAwaringListener
- (void)userService:(GBRoomUserService *)service onAwaringMyself:(GBUser *)myself {
  if (myself.roleType == GBUserRoleTypeSpectator) {
    [self.delegate toastMsg:@"您当前为麦下用户,无法参与抢唱"];
  }
}

- (void)userService:(GBRoomUserService *)service onMyselfRemoved:(GBUser *)myself {
  //收到 IM push 自己已经被移除了, 走退房清理流程
  [self startServiceCleanUpProcess];
}

#pragma mark - GBSongPitchUpdateListener
- (void)mediaPlayer:(GBMediaPlayer *)mediaPlayer onStateUpdate:(GBMediaPlayerState)state playingSong:(GBSong *)song {
  GBSong *curSong = [self getCurSong];
  
  if (state == GBMediaPlayerStatePlaying) {
    // 如果当前房间状态为 singing 且抢唱者是自己, 才打分
    if (self.roomInfo.roomState == GBRoomStateSinging
        && [[self getCurGrabUser].userID isEqualToString:[self getMyself].userID]) {
      [self.scoreService startScoringSong:curSong];
    }
  }
  else if (state == GBMediaPlayerStatePlayEnded) {
    int avgScore = [self.scoreService getAvgScoreForSong:curSong];
    [self.scoreService stopScoringSong];
    [GBDataProvider reportScore:avgScore withRoomID:self.roomInfo.roomID songID:self.getCurSong.songID complete:nil];
  }
  
  self.mediaPlayerState = state;
}

#pragma mark - GBSongPitchUpdateListener
- (void)mediaPlayer:(GBMediaPlayer *)mediaPlayer onSong:(GBSong *)song pitchUpdate:(int)pitch atProgress:(NSInteger)progress {
  [self.delegate onSongPitchUpdate:pitch atProgress:progress];
}

#pragma mark - GBSeatEventListener
- (void)seatService:(GBSeatService *)service onSeatListUpdate:(NSArray<GBSeatInfo *> *)seatInfos {
  [self.delegate onSeatListUpdate:seatInfos];
}

- (void)seatService:(GBSeatService *)service onSeatMiscUpdate:(GBSeatInfo *)seatInfo {
  [self.delegate onSeatMiscUpdate:seatInfo];
}

@end

@implementation GBRunningRoomService (FetchInfo)

- (GBSong *)getSongBySongID:(NSString *)songID {
  return [self.songResourceProvider getSongBySongID:songID];
}

- (GBSong *)getCurSong {
  GBSongPlay *songPlay = [self getCurSongPlay];
  GBSong *song = [self getSongBySongID:songPlay.songID];
  return song;
}

- (GBSongPlay *)getCurSongPlay {
  return [self.songListService getSongPlayAtIndex:self.roomInfo.curSongIndex inRound:self.roomInfo.curRound];
}

- (GBUser *)getCurGrabUser {
  return [self.userService getUserWithUserID:self.roomInfo.curPlayerID];
}

- (GBUser *)getMyself {
  return [self.userService getMyself];
}

- (GBUser *)getRoomHost {
  return [self.userService getRoomHost];
}

- (BOOL)isMyselfHost {
  return [self.userService isMyselfHost];
}

- (BOOL)isMyselfGrabCurSong {
  return [[self getCurGrabUser].userID isEqualToString:[self getMyself].userID];
}

@end

@implementation GBRunningRoomService (Helper)

- (BOOL)shouldSendingSEIForRoomState:(GBRoomState)state {
  /**
   * 发送 SEI 场景
   * 1. 房主在 GrabWaiting 阶段发送
   * 2. 抢唱者在 Singing 阶段发送
   */
  if ([self.userService isMyselfHost]) {
    if (state == GBRoomStateGrabWaiting) {
      return YES;
    }
  }
  if ([self isMyselfGrabCurSong]) {
    if (state == GBRoomStateSinging) {
      return YES;
    }
  }
  return NO;
}

- (BOOL)shouldPublishStreamForRoomState:(GBRoomState)state {
  /**
   * 推流场景
   * 1. GameWaiting 阶段, 所有人推流
   * 2. 房主需要在 RoundPreparing, NextSong 阶段提前推流
   * 3. 房主在 GrabWaiting 阶段推流
   * 4. 抢唱者在 GrabSuccessfully 阶段提前推流
   * 5. 抢唱者在 Singing 阶段推流
   */
  if (state == GBRoomStateGameWaiting) {
    return YES;
  }
  if ([self.userService isMyselfHost]) {
    if (state == GBRoomStateRoundPreparing ||
        state == GBRoomStateNextSongPreparing ||
        state == GBRoomStateGrabWaiting) {
      return YES;
    }
  }
  if (state == GBRoomStateGrabSuccessfully ||
      state == GBRoomStateSinging) {
    if ([self isMyselfGrabCurSong]) {
      return YES;
    }
  }
  return NO;
}

- (BOOL)shouldPlayHostStreamForRoomState:(GBRoomState)state {
  /**
   * 拉取房主流场景
   * 1. 如果是 GameWaiting 阶段, 需要拉取
   * 2. 非房主在 RoundPreparing, NextSong, GrabWaiting 阶段拉取房主流
   * 3. 如果房主是抢唱者, 非抢唱者在 GrabSuccesfully 和 Singing 阶段拉取房主流
   */
  if ([self isMyselfHost]) {
    return NO;
  }
  
  if (state == GBRoomStateGameWaiting) {
    return YES;
  }
  
  if (state == GBRoomStateRoundPreparing ||
      state == GBRoomStateNextSongPreparing ||
      state == GBRoomStateGrabWaiting) {
    if (!CHECK_SONG) {
      return YES;
    }
  }
  
  if ([[self.userService getRoomHost].userID isEqualToString:[self getCurGrabUser].userID]) {
    if (state == GBRoomStateGrabSuccessfully ||
        state == GBRoomStateSinging) {
      return YES;
    }
  }
  
  return NO;
}

- (BOOL)shouldTurnOnMicrophoneAsDefaultForRoomState:(GBRoomState)state {
  /**
   * 麦克风默认开启场景
   * 1. 抢唱者在 Singing 阶段
   */
  if (state == GBRoomStateSinging) {
    if ([self isMyselfGrabCurSong]) {
      return YES;
    }
  }
  return NO;
}

- (BOOL)shouldUseHighAudioQualityForRoomState:(GBRoomState)state {
  /**
   * 高音质默认开启场景
   * 1. 只有 GrabWaiting 和 Singing 的时候需要开启高音质
   */
  if (state == GBRoomStateGrabWaiting ||
      state == GBRoomStateSinging) {
    return YES;
  }
  return NO;
}

- (BOOL)shouldLocalPlayForRoomState:(GBRoomState)state {
  if (!CHECK_SONG) {
    return NO;
  }
  /**
   * 本地播放场景
   * 1. 房主和观众在 GrabWaiting 阶段
   * 2. 抢唱者在 Singing 阶段
   */
  if (state == GBRoomStateGrabWaiting) {
    return YES;
  }
  if ([self isMyselfGrabCurSong]) {
    if (state == GBRoomStateSinging) {
      return YES;
    }
  }
  return NO;
}

- (BOOL)shouldStartReceivingSEISimulationForRoomState:(GBRoomState)state {
  /**
   * 接收 SEI 模拟进度回调场景
   * 1. 观众在 GrabWaiting 阶段
   * 2. 非抢唱者在 Singing 阶段
   */
  if ([self shouldLocalPlayForRoomState:state]) {
    return NO;
  }
  if (![self isMyselfHost]) {
    if (state == GBRoomStateGrabWaiting) {
      return YES;
    }
  }
  if (![self isMyselfGrabCurSong]) {
    if (state == GBRoomStateSinging) {
      return YES;
    }
  }
  return NO;
}

- (void)checkStreamConnectivityWhenSomeoneSinging:(GBRoomInfo *)roomInfo {
  if (roomInfo.roomState == GBRoomStateSinging) {
    if (roomInfo.seq > self.lastBadCnctToastSeq) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL singerStreamOnAir = [self.userService checkIfUserStreamOnAir:[self getCurGrabUser].userID];
        if (!singerStreamOnAir) {
          self.lastBadCnctToastSeq = roomInfo.seq;
          [self.delegate toastMsg:@"演唱者网络较差"];
          return;
        }
      });
    }
  }
}

- (void)checkNetConnectivityWhenSomeoneSinging:(GBRoomInfo *)roomInfo {
  if (roomInfo.roomState != GBRoomStateSinging) {
    return;
  }
  // 如果 seq 不对, 则表示已经提示过网络差
  if (roomInfo.seq <= self.lastBadCnctToastSeq) {
    return;
  }
  
  // 检测自己网络状态
  //FIXME: 检测自己的流? 这里感觉问题很大, 需要改, 会有 bug
  if ([self.userService checkIfUserStreamOnAir:[self getMyself].userID]) {
    NSNumber *qualityNumber = [self.userQualityTable objectForKey:[self getMyself].userID];
    GBNetQuality qualityLevel = [qualityNumber unsignedIntegerValue];
    if (qualityNumber) {
      if (qualityLevel < GBNetQualityGood) {
        self.lastBadCnctToastSeq = roomInfo.seq;
        [self.delegate toastMsg:@"本端网络较差"];
        return;
      }
    }
  }
  // 检测演唱者网络状态
  if ([self.userService checkIfUserStreamOnAir:[self getCurGrabUser].userID]) {
    NSNumber *qualityNumber = [self.userQualityTable objectForKey:[self getCurGrabUser].userID];
    GBNetQuality qualityLevel = [qualityNumber unsignedIntegerValue];
    if (qualityNumber) {
      if (qualityLevel < GBNetQualityGood) {
        self.lastBadCnctToastSeq = roomInfo.seq;
        [self.delegate toastMsg:@"演唱者网络较差"];
        return;
      }
    }
  }
}

@end
