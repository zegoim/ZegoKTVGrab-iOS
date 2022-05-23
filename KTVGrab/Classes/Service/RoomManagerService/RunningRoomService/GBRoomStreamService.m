//
//  GBRoomStreamService.m
//  KTVGrab
//
//  Created by Vic on 2022/3/31.
//

#import "GBRoomStreamService.h"
#import "GBExpress.h"
#import "GBSEIService.h"
#import "GBSEIModel.h"
#import <YYKit/YYKit.h>
#import "GBNetMonitor.h"
#import "GBNetQualityModel.h"
#import "GBExternalDependency.h"

@interface GBRoomStreamService ()<GBRTCStreamEventListener, GBNetMonitorEventListener>

@property (nonatomic,  weak ) id<GBStreamServiceEventListener> listener;
@property (nonatomic, strong) GBSEIService *seiService;
@property (nonatomic, strong) GBNetMonitor *netMonitor;

/**
 * 本端已推拉的流信息
 * key: streamID
 * value: userID
 */
@property (nonatomic, strong) NSMutableDictionary *streamUserTable;

/**
 * 记录本端已推拉的流对应的 userID, 用于外界根据该用户是否有流, 来展示网络状态等业务
 * 开始推拉流的时候 add
 * 停止推拉流的时候 remove
 */
@property (nonatomic, strong) NSMutableSet *onAirStreamUsers;

/**
 * 房主的 streamID
 */
@property (nonatomic, copy) NSString *hostStreamID;

@end

@implementation GBRoomStreamService

- (void)dealloc {
  GB_LOG_D(@"[DEALLOC]%@ dealloc", NSStringFromClass(self.class));
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [self setup];
  }
  return self;
}

- (void)setup {
  self.streamUserTable  = [NSMutableDictionary dictionary];
  self.onAirStreamUsers = [NSMutableSet set];

  self.seiService       = [[GBSEIService alloc] init];
  self.netMonitor       = [[GBNetMonitor alloc] init];
  [self.netMonitor    appendListener:self];
  [[GBExpress shared] setStreamEventListener:self];
}

- (NSString *)streamIDFromUserID:(NSString *)userID {
  return [NSString stringWithFormat:@"main_i_%@", userID];
}

- (void)startPublishingWithUserID:(NSString *)userID {
  if (!userID) {
    return;
  }
  NSString *streamID = [self streamIDFromUserID:userID];
  [self addStreamOnAirUser:userID];
  [self addPairWithStreamID:streamID userID:userID];
  [[GBExpress shared] startPublishingStream:streamID];
}

- (void)stopPublishingWithUserID:(NSString *)userID {
  if (!userID) {
    return;
  }
  [self removeStreamOnAirUser:userID];
  NSString *streamID = [self streamIDFromUserID:userID];
  
  [self removePairWithStreamID:streamID];
  [[GBExpress shared] stopPublishingStream];
}

- (void)playHostStream:(BOOL)play hostUserID:(nonnull NSString *)userID {
  if (!userID) {
    return;
  }
  if (!self.hostStreamID) {
    [self.streamUserTable enumerateKeysAndObjectsUsingBlock:^(NSString *streamID, NSString *uid, BOOL * _Nonnull stop) {
      if ([uid isEqualToString:userID]) {
        self.hostStreamID = streamID;
      }
    }];
  }
  GB_LOG_D(@"[STREAM]Play host stream: %d, userID: %@", play, userID);
  if (play) {
    [self tryToPlayStream:self.hostStreamID userID:userID];
  }else {
    [self tryToStopPlayingStream:self.hostStreamID userID:userID];
  }
}

- (BOOL)checkIfUserStreamOnAir:(NSString *)userID {
  if (!userID) {
    return NO;
  }
  return [self.onAirStreamUsers containsObject:userID];
}

#pragma mark - Private
- (void)addStreamOnAirUser:(NSString *)userID {
  [self.onAirStreamUsers addObject:userID];
  [self.listener streamService:self onUser:userID streamOnAir:YES];
}

- (void)removeStreamOnAirUser:(NSString *)userID {
  [self.onAirStreamUsers removeObject:userID];
  [self cancelBadQualityStreamCallout:userID];
  [self.listener streamService:self onUser:userID streamOnAir:NO];
}

- (void)tryToPlayStream:(NSString *)streamID userID:(NSString *)userID {
  if (!streamID || !userID) {
    return;
  }
  
  [self addPairWithStreamID:streamID userID:userID];
  [[GBExpress shared] playStream:streamID];
  [self addStreamOnAirUser:userID];
}

- (void)tryToStopPlayingStream:(NSString *)streamID userID:(NSString *)userID {
  if (!streamID) {
    return;
  }
  [self removePairWithStreamID:streamID];
  [self removeStreamOnAirUser:userID];
  [[GBExpress shared] stopPlayingStream:streamID];
}

- (void)addPairWithStreamID:(NSString *)streamID userID:(NSString *)userID {
  if (!streamID || !userID) {
    return;
  }
  
  [self.streamUserTable setObject:userID forKey:streamID];
}

- (void)removePairWithStreamID:(NSString *)streamID {
  if (!streamID) {
    return;
  }
  [self.streamUserTable removeObjectForKey:streamID];
}

#pragma mark - GBStreamEventListener

- (void)onRTCAddStream:(ZegoStream *)stream {
  if (!stream) {
    return;
  }
  [self tryToPlayStream:stream.streamID userID:stream.user.userID];
}

- (void)onRTCRemoveStream:(ZegoStream *)stream {
  if (!stream) {
    return;
  }
  NSString *userID = stream.user.userID;
  [self tryToStopPlayingStream:stream.streamID userID:userID];
  [self removePairWithStreamID:stream.streamID];
}

- (void)onRTCStream:(NSString *)streamID soundLevelUpdate:(CGFloat)soundLevel {
  if (!streamID) {
    return;
  }
  NSString *userID = [self.streamUserTable objectForKey:streamID];
  if (userID.length > 0) {
    [self.listener streamService:self onUser:userID soundLevelUpdate:soundLevel];
  }
}

- (void)onRTCStreamCapturedSoundLevelUpdate:(CGFloat)soundLevel {
  [self.listener streamService:self onUser:[GBExternalDependency shared].userID soundLevelUpdate:soundLevel];
}

- (void)onRTCStream:(NSString *)streamID receiveSEIData:(NSData *)data {
  GBSEIModel *model = [self.seiService seiModelWithData:data];

  GB_INTERVAL_EXECUTE(kGBSEIRecvLogInterval, 0, ^{
    GB_LOG_D(@"[SEI] Receive SEI: %@", [model modelToJSONString]);
  })
  
  [self.listener streamService:self onReceiveSEI:model];
}

#pragma mark - GBNetMonitorEventListener
- (void)netMonitor:(GBNetMonitor *)monitor onNetSpeedTestQualityUpdate:(GBNetQuality)qualityLevel {
  [self.listener streamService:self onMyTestSpeedQualityUpdate:qualityLevel];
}

- (void)netMonitor:(GBNetMonitor *)monitor onStream:(NSString *)streamID qualityUpdate:(GBNetQualityModel *)quality {
  if (!streamID) {
    return;
  }
  NSString *userID = [self.streamUserTable objectForKey:streamID];
  if (!userID) {
    return;
  }
  
  //TODO: 鉴于此处调用频繁导致对象频繁创建, 可考虑缓存 GBNetQualityModel
  GBNetQualityModel *model = [[GBNetQualityModel alloc] init];
  model.kbps = quality.kbps;
  model.rtt = quality.rtt;
  model.packetLossRate = quality.packetLossRate;
  
  [self.listener streamService:self onUser:userID qualityUpdate:model];
}

- (void)netMonitor:(GBNetMonitor *)monitor onUser:(NSString *)userID netQualityLevelUpdate:(GBNetQuality)qualityLevel {
  // 如果用户断网,那么该用户对应的这个回调将会不执行,那么就回调出去网络状态为差
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(calloutNetworkBadWithUserID:) object:userID];
  [self performSelector:@selector(calloutNetworkBadWithUserID:) withObject:userID afterDelay:3];
  
  // 如果该用户的流不在缓存里, 则不需要回调
  [self.listener streamService:self onUser:userID netQualityLevelUpdate:qualityLevel];
}

- (void)cancelBadQualityStreamCallout:(NSString *)userID {
  if (!userID) {
    return;
  }
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(calloutNetworkBadWithUserID:) object:userID];
}

- (void)calloutNetworkBadWithUserID:(NSString *)userID {
  GB_LOG_D(@"[NET]calloutNetworkBadWithUserID: %@", userID);
  [self.listener streamService:self onUser:userID netQualityLevelUpdate:GBNetQualityBad];
}

@end
