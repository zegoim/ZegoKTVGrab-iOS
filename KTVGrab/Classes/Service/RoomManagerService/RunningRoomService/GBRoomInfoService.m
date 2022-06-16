//
//  GBGameProcManager.m
//  GoChat
//
//  Created by Vic on 2022/2/22.
//  Copyright © 2022 zego. All rights reserved.
//

#import "GBRoomInfoService.h"
#import "GBRoomInfo.h"

@interface GBRoomInfoService ()

@property (nonatomic, weak) id<GBRoomInfoUpdateListener> listener;
@property (nonatomic, assign) long long lastSeq;

@end

@implementation GBRoomInfoService

- (void)dealloc {
  GB_LOG_D(@"[DEALLOC]%@ dealloc", NSStringFromClass(self.class));
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _lastSeq = -1;
  }
  return self;
}

- (void)forceUpdatingRoomInfo:(GBRoomInfo *)roomInfo {
  roomInfo.seq = self.lastSeq + 1;
  [self.listener roomInfoService:self onRoomInfoUpdate:roomInfo];
}

- (void)onRoomStateUpdate:(GBRoomInfo *)roomInfo seq:(long long)seq {
  if (seq > self.lastSeq) {
    self.lastSeq = seq;
    roomInfo.seq = seq;
    [self.listener roomInfoService:self onRoomInfoUpdate:roomInfo];
  }else {
    GB_LOG_W(@"This room state seq has expired. Last seq: %lld, this seq: %ld", self.lastSeq, seq);
  }
}

@end
