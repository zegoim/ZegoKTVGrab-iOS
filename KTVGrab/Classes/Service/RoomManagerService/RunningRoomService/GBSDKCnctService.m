//
//  GBSDKCnctService.m
//  KTVGrab
//
//  Created by Vic on 2022/5/12.
//

#import "GBSDKCnctService.h"
#import "GBIM.h"
#import "GBExpress.h"

@interface GBSDKCnctService ()<GBIMCnctListener, GBRTCRoomCnctListener>

@property (nonatomic, weak) id<GBRoomCnctListener> listener;

@property (nonatomic, assign) BOOL imRoomReconnected;
@property (nonatomic, assign) BOOL imRoomReconnecting;
@property (nonatomic, assign) BOOL imRoomDisconnected;
@property (nonatomic, assign) BOOL rtcRoomReconnected;
@property (nonatomic, assign) BOOL rtcRoomReconnecting;
@property (nonatomic, assign) BOOL rtcRoomDisconnected;
@property (nonatomic, assign) BOOL rtcKickedOut;

@end

@implementation GBSDKCnctService

- (instancetype)init {
  self = [super init];
  if (self) {
    [self setup];
  }
  return self;
}

- (void)setup {
  [self setupCnctStateFlags];
  [self setupDelegation];
}

- (void)setupCnctStateFlags {
  self.imRoomReconnected = YES;
  self.imRoomReconnecting = NO;
  self.imRoomDisconnected = NO;
  
  self.rtcRoomReconnected = YES;
  self.rtcRoomReconnecting = NO;
  self.rtcRoomDisconnected = NO;
  self.rtcKickedOut = NO;
}

- (void)setupDelegation {
  [[GBIM shared] setConnectionListener:self];
  [[GBExpress shared] setRoomCnctListener:self];
}

#pragma mark - Connectivity
- (void)onIMConnectionReconnected {
  GB_LOG_D(@"[CNCT]IM reconnected");
  self.imRoomReconnected = YES;
  self.imRoomReconnecting = NO;
  self.imRoomDisconnected = NO;
  [self calloutRoomConnectivityUpdates];
}

- (void)onIMConnectionReconnecting {
  GB_LOG_D(@"[CNCT]IM reconnecting");
  self.imRoomReconnected = NO;
  self.imRoomReconnecting = YES;
  self.imRoomDisconnected = NO;
  [self calloutRoomConnectivityUpdates];
}

- (void)onIMConnectionDisconnected {
  self.imRoomReconnected = NO;
  self.imRoomReconnecting = NO;
  self.imRoomDisconnected = YES;
  GB_LOG_D(@"[CNCT]IM disconnected");
  [self calloutRoomConnectivityUpdates];
}

- (void)onIMRoomReconnecting {
  //  GB_LOG_D(@"[CNCT]IM reconnecting");
  //  self.imRoomReconnected = NO;
  //  [self.roomEventListener onRoomReconnecting];
}

- (void)onIMRoomReconnected {
  //  GB_LOG_D(@"[CNCT]IM reconnected");
  //  self.imRoomReconnected = YES;
  //  if (self.rtcRoomReconnected) {
  //    [self.roomEventListener onRoomReconnected];
  //  }
}

- (void)onIMRoomDisconnected {
  //  self.imRoomReconnected = NO;
  //  GB_LOG_D(@"[CNCT]IM disconnected");
  //  [self.roomEventListener onRoomDisconnected];
}


#pragma mark - Express Event
- (void)onRTCRoomDisconnected {
  GB_LOG_D(@"[CNCT]RTC disconnected");
  self.rtcRoomReconnected = NO;
  self.rtcRoomReconnecting = NO;
  self.rtcRoomDisconnected = YES;
  [self calloutRoomConnectivityUpdates];
}

- (void)onRTCRoomReconnecting {
  GB_LOG_D(@"[CNCT]RTC reconnecting");
  self.rtcRoomReconnected = NO;
  self.rtcRoomReconnecting = YES;
  self.rtcRoomDisconnected = NO;
  [self calloutRoomConnectivityUpdates];
}

- (void)onRTCRoomReconnected {
  GB_LOG_D(@"[CNCT]RTC reconnected");
  self.rtcRoomReconnected = YES;
  self.rtcRoomReconnecting = NO;
  self.rtcRoomDisconnected = NO;
  [self calloutRoomConnectivityUpdates];
}

- (void)onRTCRoomKickout {
  GB_LOG_D(@"[CNCT]RTC kickout");
  self.rtcKickedOut = YES;
  [self calloutRoomConnectivityUpdates];
}

- (void)calloutRoomConnectivityUpdates {
  /**
   * 等待房间状态同步, 延迟房间状态更新, 用于向外抛出正确回调
   *
   * 例:
   * IM 目前没有提供 KickOut 回调, 只有 Disconnected 回调.
   * 如果 RTC 回调 KickOut, 那么外界应该收到 KickOut 的信息, 而不是 IM 的 Disconnected 所示的网络不好断开连接的信息
   * 所以, 当 IM 的 Disconnected 回调和 RTC 的 KickOut 回调几乎同时到达后, 如果不延迟进行判断, 则可能会向外界抛出错误回调信息.
   */
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    /**
     * 1. Reconnected
     * 2. Connecting
     * 3. Disconnected
     * 4. KickOut
     */
    if (self.imRoomReconnected && self.rtcRoomReconnected) {
      [self.listener onRoomReconnected];
      return;
    }
    
    if (self.imRoomReconnecting || self.rtcRoomReconnecting) {
      [self.listener onRoomReconnecting];
      return;
    }
    
    if (self.rtcKickedOut) {
      [self.listener onRoomKickout];
      return;
    }
    
    if (self.imRoomDisconnected || self.rtcRoomDisconnected) {
      [self.listener onRoomDisconnected];
      return;
    }
  });
}

@end
