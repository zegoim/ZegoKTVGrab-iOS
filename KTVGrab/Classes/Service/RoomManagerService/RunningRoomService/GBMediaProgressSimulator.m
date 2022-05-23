//
//  GBMediaProgressDataService.m
//  KTVGrab
//
//  Created by Vic on 2022/3/23.
//

#import "GBMediaProgressSimulator.h"
#import <YYKit/YYKit.h>

static NSTimeInterval const timerInterval = 0.03;   // 计时器时间间隔

@interface GBMediaProgressSimulator ()

@property (nonatomic,  weak ) id<GBProgressSimListener> listener;
@property (nonatomic, strong) YYTimer *timer;
@property (nonatomic, assign) NSInteger lastMediaRealProgress;
@property (nonatomic, strong) NSDate *realMediaProgressUpdateDate;

@property (nonatomic, assign) NSInteger lastSEIRealProgress;
@property (nonatomic, strong) NSDate *realSEIProgressUpdateDate;
@property (nonatomic, strong) GBSEIModel *seiModel;

@property (nonatomic, assign) BOOL shouldSimulateMediaProgress;
@property (nonatomic, assign) BOOL shouldUpdateSEI;

@end

@implementation GBMediaProgressSimulator
- (void)dealloc {
  GB_LOG_D(@"[DEALLOC]%@ dealloc", NSStringFromClass(self.class));
  [self invalidateTimer];
}

- (void)startMediaProgressSimulation {
  self.shouldSimulateMediaProgress = YES;
  [self startTimer];
}

- (void)stopMediaProgressSimulation {
  self.shouldSimulateMediaProgress = NO;
  self.realMediaProgressUpdateDate = nil;
  self.lastMediaRealProgress = 0;
}

- (void)startSEIProgressSimulation {
  self.shouldUpdateSEI = YES;
  [self startTimer];
}

- (void)stopSEIProgressSimulation {
  self.seiModel = nil;
  self.shouldUpdateSEI = NO;
  self.realSEIProgressUpdateDate = nil;
  self.lastSEIRealProgress = 0;
}

- (void)setLastMediaRealProgress:(NSInteger)progress {
  _lastMediaRealProgress = progress;
  self.realMediaProgressUpdateDate = [NSDate date];
  [self.listener progressSimulator:self onMediaRealProgressUpdate:progress];
}

- (void)setLastSEIRealProgress:(NSInteger)progress {
  _lastSEIRealProgress = progress;
  self.realSEIProgressUpdateDate = [NSDate date];
}

#pragma mark - Timer
- (void)startTimer {
  if (_timer) {
    return;
  }
  [self.timer fire];
}

- (void)invalidateTimer {
  if (!_timer) {
    return;
  }
  [self.timer invalidate];
  self.timer = nil;
}

- (YYTimer *)timer {
  if (!_timer) {
    _timer = [YYTimer timerWithTimeInterval:timerInterval target:self selector:@selector(updateCalculatedMediaProgress) repeats:YES];
  }
  return _timer;
}

#pragma mark - Media progress calculation
- (void)updateCalculatedMediaProgress {
  NSInteger calculatedProgress = [self getCalculatedMediaProgress];
  
  if (self.shouldSimulateMediaProgress) {
    [self.listener progressSimulator:self onMediaSimulatedProgressUpdateEvery30ms:calculatedProgress];
    
    GB_INTERVAL_EXECUTE(kGBProgressSimulator60msCallFlag, 1, ^{
      [self.listener progressSimulator:self onMediaSimulatedProgressUpdateEvery60ms:calculatedProgress];
    })
  }
  
  if (self.shouldUpdateSEI) {
    [self updateCalculatedSEI];
  }
}

- (NSInteger)getCalculatedMediaProgress {
  NSTimeInterval interval = [self getTimeIntervalBetweenLastMediaProgressSetDateAndTimerFiringDate];
  return self.lastMediaRealProgress + interval;
}

- (NSTimeInterval)getTimeIntervalBetweenLastMediaProgressSetDateAndTimerFiringDate {
  return [[NSDate date] timeIntervalSinceDate:self.realMediaProgressUpdateDate] * 1000;
}

#pragma mark - SEI progress calculation
- (void)updateCalculatedSEI {
  NSInteger calculatedSEIProgress = [self getCalculatedSEIProgress];
  self.seiModel.progress = calculatedSEIProgress;
  [self.listener progressSimulator:self onSimulatedSEIUpdateEvery30ms:self.seiModel];
}

- (NSInteger)getCalculatedSEIProgress {
  NSTimeInterval interval = [self getTimeIntervalBetweenLastSEIProgressSetDateAndTimerFiringDate];
  return self.lastSEIRealProgress + interval;
}

- (NSTimeInterval)getTimeIntervalBetweenLastSEIProgressSetDateAndTimerFiringDate {
  return [[NSDate date] timeIntervalSinceDate:self.realSEIProgressUpdateDate] * 1000;
}

#pragma mark - GBMediaPlayerProgressListener
- (void)mediaPlayer:(GBMediaPlayer *)mediaPlayer onProgressUpdate:(NSUInteger)progress {
  [self setLastMediaRealProgress:progress];
}

#pragma mark - GBRoomUserSEIListener
- (void)userService:(GBRoomUserService *)service onReceiveSEI:(GBSEIModel *)model {
  self.seiModel = model;
  [self setLastSEIRealProgress:model.progress];
}

#pragma mark - GBMediaPlayerEventListener
- (void)mediaPlayer:(GBMediaPlayer *)mediaPlayer onStateUpdate:(GBMediaPlayerState)state playingSong:(GBSong *)song {
  if (state == GBMediaPlayerStatePlaying) {
    [self startMediaProgressSimulation];
  }else {
    [self stopMediaProgressSimulation];
  }
}

@end
