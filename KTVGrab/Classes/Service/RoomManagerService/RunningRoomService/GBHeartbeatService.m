//
//  GBHeartbeatManager.m
//  KTVGrab
//
//  Created by Vic on 2022/3/15.
//

#import "GBHeartbeatService.h"
#import "GBDataProvider.h"
#import <YYKit/YYKit.h>

#define GB_HEART_BEAT_DEFAULT_INTERVAL 10

@interface GBHeartbeatService ()

@property (nonatomic, assign) BOOL shouldHeartbeat;
@property (nonatomic, assign) NSTimeInterval interval;
@property (nonatomic,  copy ) NSString *roomID;

@end

@implementation GBHeartbeatService

- (void)dealloc {
  [self _stopBeating];
  GB_LOG_D(@"[DEALLOC][HB]%@ dealloc", NSStringFromClass(self.class));
}

- (void)startRepeatedlyHeartbeatWithRoomID:(NSString *)roomID {
  GB_LOG_D(@"[HB] Start heartbeat");
  self.shouldHeartbeat = YES;
  self.roomID = roomID;
  self.interval = GB_HEART_BEAT_DEFAULT_INTERVAL;
  [self _beat];
}

- (void)stopRepeatedlyHeartbeat {
  [self _stopBeating];
}

- (void)_beat {
  if (!self.shouldHeartbeat) {
    return;
  }
  @weakify(self);
  GB_LOG_D(@"[HB] Beat once with interval: %.0f", self.interval);
  self.interval = GB_HEART_BEAT_DEFAULT_INTERVAL;
  [GBDataProvider heartbeatWithRoomID:self.roomID complete:^(BOOL suc, NSError * _Nullable err, NSNumber * _Nonnull itvNumber) {
    @strongify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      if (!err) {
        self.interval = itvNumber.doubleValue;
      }
      [self _beat];
    });
  }];
}

- (void)_stopBeating {
  if (!self.shouldHeartbeat) {
    return;
  }
  GB_LOG_D(@"[HB] Stop heartbeat");
  self.shouldHeartbeat = NO;
  self.roomID = nil;
  self.interval = GB_HEART_BEAT_DEFAULT_INTERVAL;
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_beat) object:nil];
}

- (NSTimeInterval)interval {
  return MAX(_interval, 5);
}

@end
