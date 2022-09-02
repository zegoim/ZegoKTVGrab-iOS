//
//  GBIM.m
//  IMTest
//
//  Created by Vic on 2022/3/7.
//

#import "GBIM.h"
#import "GBExternalDependency.h"
#import "GBTokenService.h"
#import <GZIP/GZIP.h>
#import <YYKit/YYKit.h>
@import GoKit;

#define e(x) [self _newErrorByIMError:(x)]

static NSString * const GBIMErrorDomain = @"im.zego.KTVGrab.im";

@interface GBIM ()

@property (nonatomic, strong) ZIM *im;
@property (nonatomic, copy) NSString *roomID;

@property (nonatomic, weak) id<GBIMCnctListener> connectionListener;
@property (nonatomic, weak) id<GBIMMessageListener> messageListener;

@property (nonatomic, assign) BOOL loggedIn;
@property (nonatomic, assign) BOOL inRoom;

@end

@implementation GBIM
@synthesize im = _im;

+ (instancetype)shared {
  static dispatch_once_t onceToken;
  static id _instance;
  dispatch_once(&onceToken, ^{
    _instance = [[self alloc] init];
  });
  return _instance;
}

#pragma mark - Private Function
- (ZIM *)im {
//  assert(_im);
  return _im;
}

- (void)setIm:(ZIM *)im {
  _im = im;
  GB_LOG_D(@"[IM]Set im: %@", im);
}

#pragma mark - Foundation
- (void)create {
  GB_LOG_D(@"[IM]IM Version: %@", [ZIM getVersion]);
  GB_LOG_D(@"[IM]Create IM");
  ZIMAppConfig *config = [[ZIMAppConfig alloc] init];
  config.appID = GBExternalDependency.shared.appID;
  config.appSign = GBExternalDependency.shared.appSign;
  ZIM *im = [ZIM createWithAppConfig:config];
  self.im = im;
  
  [im setEventHandler:self];
}

- (void)destroy {
  GB_LOG_D(@"[IM]Destroy IM");
  [self.im destroy];
  [self resetAll];
}

- (NSString *)getVersion {
  return [ZIM getVersion];
}

#pragma mark - Reset Protocol
- (void)resetAll {
  self.im = nil;
  self.inRoom = NO;
  self.loggedIn = NO;
}

#pragma mark - Callback
- (void)zim:(ZIM *)zim errorInfo:(ZIMError *)errorInfo {
  GB_LOG_E(@"[IM][CB]ERROR: %@, code: %lu, message: %@", errorInfo, errorInfo.code, errorInfo.message);
  if (errorInfo.code == ZIMErrorCodeCommonModuleInvalidAppID) {
    [GoNotice showToast:@"无效 appID,请确认此 appID 已开通 ZIM 服务" onView:[UIApplication sharedApplication].keyWindow];
  }
}

- (void)zim:(ZIM *)zim connectionStateChanged:(ZIMConnectionState)state event:(ZIMConnectionEvent)event extendedData:(NSDictionary *)extendedData {
  /*
   IM SDK 给的 state 和 event 非常奇怪, 仅仅使用这两个值无法区分精确场景, 如: 登录成功, 重连等事件, 需要自己添加变量进行维护
   */
  GB_LOG_D(@"[IM][CB]Connection state: %lu, event: %lu", (unsigned long)state, (unsigned long)event);
  
  switch (state) {
    case ZIMConnectionStateDisconnected:
    {
      if (self.loggedIn) {
        [self.connectionListener onIMConnectionDisconnected];
      }
      self.loggedIn = NO;
    }
      break;
      
    case ZIMConnectionStateConnecting:
    {
      
    }
      break;
      
    case ZIMConnectionStateConnected:
    {
      if (!self.loggedIn) {
        /// 用户登录成功
        self.loggedIn = YES;
      }else {
        /// 重连成功
        [self.connectionListener onIMConnectionReconnected];
      }
    }
      break;
      
    case ZIMConnectionStateReconnecting:
    {
      if (self.loggedIn) {
        [self.connectionListener onIMConnectionReconnecting];
      }
    }
      break;
  }
}


- (void)zim:(ZIM *)zim roomStateChanged:(ZIMRoomState)state event:(ZIMRoomEvent)event extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
  GB_LOG_D(@"[IM][CB]Room state: %lu, event: %lu", (unsigned long)state, (unsigned long)event);
  switch (state) {
    case ZIMRoomStateDisconnected:
    {
      if (self.inRoom) {
        [self.connectionListener onIMRoomDisconnected];
      }
      self.inRoom = NO;
    }
      break;
      
    case ZIMRoomStateConnecting:
    {
      if (self.inRoom) {
        [self.connectionListener onIMRoomReconnecting];
      }
    }
      break;
      
    case ZIMRoomStateConnected:
    {
      if (event == ZIMRoomEventSuccess) {
        if (self.inRoom) {
          [self.connectionListener onIMRoomReconnected];
        }
        self.inRoom = YES;
      }
    }
      break;
  }
}

- (void)zim:(ZIM *)zim receiveRoomMessage:(NSArray<ZIMMessage *> *)messageList fromRoomID:(NSString *)fromRoomID {
  for (ZIMMessage *msg in messageList) {
    NSString *message = [self stringMessageFromMessage:msg];
    if (message) {
      [self.messageListener onIMReceiveRoomMessage:message];
    }
  }
}

#pragma mark - Private
- (NSError *)_newErrorByIMError:(ZIMError *)error {
  NSString *desc = error.debugDescription;
  GB_LOG_E(@"[IM]Error Code: %lu, message: %@", error.code, error.message);
  if (error.code == 0) {
    return nil;
  }
  return [NSError errorWithDomain:GBIMErrorDomain code:error.code userInfo:@{ NSDebugDescriptionErrorKey: desc}];
}

- (NSError *)_newArgError:(NSString *)argName {
  NSInteger errorCode = -1;
  NSString *desc = [NSString stringWithFormat:@"Invalid argument %@", argName];
  GB_LOG_E(@"[IM]Error Code: -1, message: %@", desc);
  return [NSError errorWithDomain:GBIMErrorDomain code:errorCode userInfo:@{ NSDebugDescriptionErrorKey: desc}];
}

- (NSString *)stringMessageFromMessage:(ZIMMessage *)message {
  if ([message isKindOfClass:[ZIMTextMessage class]]) {
    ZIMTextMessage *msg = (ZIMTextMessage *)message;
    return msg.message;
  }
  if ([message isKindOfClass:[ZIMCommandMessage class]]) {
    ZIMCommandMessage *msg = (ZIMCommandMessage *)message;
    NSString *string = [self decodeMessage:msg.message];
    return string;
  }
  return nil;
}

- (NSString *)decodeMessage:(NSData *)data {
  NSData *decodedData = [[NSData alloc] initWithBase64EncodedData:data options:0];
  BOOL isGzipped = [decodedData isGzippedData];
  GB_LOG_D(@"[IM][PUSH]Is gzip data: %d", isGzipped);
  NSData *ungzippedData = [decodedData gunzippedData];
  NSString *msg = [[NSString alloc] initWithData:ungzippedData encoding:NSUTF8StringEncoding];
  return msg;
}

#pragma mark - Login
- (void)loginWithComplete:(GBErrorBlock)complete {
  NSString *userID = [GBExternalDependency shared].userID;
  NSString *userName = [GBExternalDependency shared].userName;
  
  // 先获取 token
  [GBTokenService.shared requestToken:^(NSString * _Nonnull token) {
    if (!(token.length > 0)) {
      !complete ?: complete([self _newArgError:@"token"]);
      return;
    }
    
    ZIMUserInfo *userInfo = [[ZIMUserInfo alloc] init];
    userInfo.userID = userID;
    userInfo.userName = userName;
    
    GB_LOG_D(@"[IM]Login IM. UserID:%@. UserName: %@. Token: %@", userID, userName, token);
    [self.im loginWithUserInfo:userInfo token:nil callback:^(ZIMError * _Nonnull errorInfo) {
      GB_LOG_D(@"[IM][CB]IM Login Callback");
      !complete ?: complete(e(errorInfo));
    }];
  }];
}

- (void)logout {
  GB_LOG_D(@"[IM]Logout IM");
  [GBTokenService.shared stop];
  self.loggedIn = NO;
  [self.im logout];
}

#pragma mark - Room
- (void)createRoomWithRoomID:(NSString *)roomID roomName:(NSString *)roomName complete:(void(^)(NSError *error))complete {
  ZIMRoomInfo *roomInfo = [[ZIMRoomInfo alloc] init];
  roomInfo.roomID = roomID;
  roomInfo.roomName = roomName;
  
  GB_LOG_D(@"[IM]Create room, room_id: %@, room_name: %@", roomID, roomName);
  
  @weakify(self);
  [self.im createRoom:roomInfo callback:^(ZIMRoomFullInfo * _Nonnull roomInfo, ZIMError * _Nonnull errorInfo) {
    @strongify(self);
    GB_LOG_D(@"[IM][CB]Create room callback, room_id: %@, room_name: %@", roomID, roomName);
    !complete ?: complete(e(errorInfo));
  }];
}

- (void)joinRoomWithRoomID:(NSString *)roomID complete:(void (^)(NSError * _Nonnull))complete {
  GB_LOG_D(@"[IM]Join room, room_id: %@", roomID);
  @weakify(self);
  [self.im joinRoom:roomID callback:^(ZIMRoomFullInfo * _Nonnull roomInfo, ZIMError * _Nonnull errorInfo) {
    @strongify(self);
    GB_LOG_D(@"[IM][CB]IM Join room callback");
    if (errorInfo.code == 0) {
      self.roomID = roomID;
    }
    !complete ?: complete(e(errorInfo));
  }];
}

- (void)leaveRoomWithCompletion:(GBErrorBlock)completion {
  GB_LOG_D(@"[IM]Leave room, room_id: %@", self.roomID);
  if (!(self.roomID.length > 0)) {
    !completion ?: completion([self _newArgError:@"roomID"]);
    return;
  }
  GB_LOG_D(@"[IM]IM leave room");
  self.inRoom = NO;
  [self.im leaveRoom:self.roomID callback:^(NSString * _Nonnull roomID, ZIMError * _Nonnull errorInfo) {
    GB_LOG_D(@"[IM][CB]IM leave room callback");
    !completion ?: completion(e(errorInfo));
  }];
}

@end
