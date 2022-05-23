//
//  GBNetMonitor.m
//  KTVGrab
//
//  Created by Vic on 2022/4/14.
//

#import "GBNetMonitor.h"
#import "GBExpress.h"
#import "GBNetQualityModel.h"

@interface GBNetMonitor ()<GBRTCQualityEventListener>

@property (nonatomic, copy) NSArray *qualityMap;
@property (nonatomic, strong) NSPointerArray *listeners;

@end

@implementation GBNetMonitor

- (instancetype)init {
  self = [super init];
  if (self) {
    [[GBExpress shared] setNetQualityEventListener:self];
    _listeners = [NSPointerArray weakObjectsPointerArray];
  }
  return self;
}

- (void)appendListener:(id<GBNetMonitorEventListener>)listener {
  [self.listeners addPointer:(__bridge void * _Nullable)(listener)];
}

- (void)startMonitoring {
  [[GBExpress shared] startNetworkSpeedTest];
}

- (void)stopMonitoring {
  [[ZegoExpressEngine sharedEngine] stopNetworkSpeedTest];
}

#pragma mark - Private
- (GBNetQuality)netQualityWithRTCQuality:(ZegoStreamQualityLevel)level {
  return (GBNetQuality)[self.qualityMap[level] unsignedIntegerValue];
}

- (NSArray *)qualityMap {
  if (!_qualityMap) {
    /*
     GBNetQualityUnknown = 0,
     GBNetQualityTesting = 1,
     GBNetQualityBad = 2,
     GBNetQualityMedium = 3,
     GBNetQualityGood = 4,
     */
    _qualityMap = @[@4, @4, @3, @2, @2, @2];
  }
  return _qualityMap;
}

#pragma mark - GBNetQualityEventListener
- (void)onRTCNetSpeedTestUpdate:(ZegoNetworkSpeedTestQuality *)quality error:(NSError *)error {
  if (quality) {
    [self calloutListenersExecuteSelector:@selector(netMonitor:onNetSpeedTestQualityUpdate:)
                                  doBlock:^(id<GBNetMonitorEventListener> listener) {
      [listener netMonitor:self onNetSpeedTestQualityUpdate:[self netQualityWithRTCQuality:quality.quality]];
    }];
    return;
  }
  /*
   1. 如果是拉流导致的停止, 应重启测速
   2. 如果是推流导致的停止, 不用重启
   3. 如果超过一次性测速最大时长导致停止, 应重启测速
   */
  NSArray *restartErrorCodes = @[
    @(1015005),
    @(1015006), //拉流导致停止
    @(1015004), //超过最大测速时长导致停止
  ];
  
  NSUInteger errorCode = error.code;
  if (errorCode != 0) {
    [self startMonitoring];
  }
}

- (void)onRTCStreamQualityUpdate:(ZegoPlayStreamQuality *)quality playStreamID:(NSString *)streamID {
  GBNetQualityModel *model = [[GBNetQualityModel alloc] init];
  model.kbps = quality.audioKBPS;
  model.rtt = quality.rtt;
  model.packetLossRate = quality.packetLostRate;
  [self calloutListenersExecuteSelector:@selector(netMonitor:onStream:qualityUpdate:)
                                doBlock:^(id<GBNetMonitorEventListener> listener) {
    [listener netMonitor:self onStream:streamID qualityUpdate:model];
  }];
}

- (void)onRTCStreamQualityUpdate:(ZegoPublishStreamQuality *)quality publishStreamID:(NSString *)streamID {
  GBNetQualityModel *model = [[GBNetQualityModel alloc] init];
  model.kbps = quality.audioKBPS;
  model.rtt = quality.rtt;
  model.packetLossRate = quality.packetLostRate;
  [self calloutListenersExecuteSelector:@selector(netMonitor:onStream:qualityUpdate:)
                                doBlock:^(id<GBNetMonitorEventListener> listener) {
    [listener netMonitor:self onStream:streamID qualityUpdate:model];
  }];
}

- (void)onRTCNetworkQualityUpdate:(ZegoStreamQualityLevel)qualityLevel userID:(NSString *)userID {
  __block NSString *blockUserID = userID;
  [self calloutListenersExecuteSelector:@selector(netMonitor:onUser:netQualityLevelUpdate:) doBlock:^(id<GBNetMonitorEventListener> listener) {
    // 如果 userID 为 @"", 则对应的 user 为自己, 这是 express 的规则
    if (blockUserID.length == 0) {
      blockUserID = [GBUserAccount shared].myself.userID;
    }
    [listener netMonitor:self onUser:blockUserID netQualityLevelUpdate:[self netQualityWithRTCQuality:qualityLevel]];
  }];
}

- (void)calloutListenersExecuteSelector:(SEL)sel doBlock:(void(^)(id<GBNetMonitorEventListener> listener))block {
  for (id<GBNetMonitorEventListener> listener in self.listeners) {
    if ([listener respondsToSelector:sel]) {
      block(listener);
    }
  }
}

@end
