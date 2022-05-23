//
//  GBSDKEventAgent.m
//  KTVGrab
//
//  Created by Vic on 2022/3/17.
//

#import "GBSDKEventAgent.h"
#import "GBIM.h"
#import "GBExpress.h"
#import "GBConstants.h"
#import "GBPushMessege.h"
#import "GBConcreteRespModel.h"
#import "GBRoomInfo.h"
#import "GBUser.h"
#import "GBSongPlay.h"
#import <YYKit/YYKit.h>

@interface GBSDKEventAgent ()
<
GBIMMessageListener
>
@property (nonatomic, weak) id<GBAgentRoomStateListener> roomStateListener;
@property (nonatomic, weak) id<GBAgentUserUpdateListener> userUpdateListener;
@property (nonatomic, weak) id<GBAgentSongListUpdateListener> songListUpdateListener;

@end

@implementation GBSDKEventAgent

- (void)dealloc {
  GB_LOG_D(@"[DEALLOC]GBSDKEventAgent dealloc");
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [self setup];
  }
  return self;
}

- (void)setup {
  [[GBIM shared] setMessageListener:self];
}

#pragma mark - Private
#pragma mark - Push Handle
- (void)onReceiveUserStateUpdateWithMessage:(GBPushMessege *)message {
  NSArray<NSDictionary *> *userDictList = message.data[@"users"];
  NSArray<GBUserRespModel *> *userModels = [NSArray modelArrayWithClass:[GBUserRespModel class] json:userDictList];
  NSUInteger seq = message.timestamp;
  [self.userUpdateListener onRoomUserStateUpdate:userModels seq:seq];
}

- (void)onReceiveUserListUpdateWithMessage:(GBPushMessege *)message {
  NSArray<NSDictionary *> *userDictList = message.data[@"users"];
  NSArray<GBUserRespModel *> *userModels = [NSArray modelArrayWithClass:[GBUserRespModel class] json:userDictList];
  NSUInteger seq = message.timestamp;
  [self.userUpdateListener onRoomUserListUpdate:userModels seq:seq];
}

- (void)onReceiveRoomStateUpdateWithMessage:(GBPushMessege *)message {
  NSDictionary *data = message.data;
  GBRoomRespModel *roomRespModel = [GBRoomRespModel modelWithJSON:data];
  GBRoomInfo *roomInfo = [[GBRoomInfo alloc] init];
  [roomInfo updateWithRoomRespModel:roomRespModel];
  long long seq = message.timestamp;
  [self.roomStateListener onRoomStateUpdate:roomInfo seq:seq];
}

- (void)onReceiveBroadcastMessage:(GBPushMessege *)message {
  
}

- (void)onReceiveSongListUpdateWithMessage:(GBPushMessege *)message {
  NSDictionary *data = message.data;
  if (!data) {
    return;
  }
  NSArray<NSDictionary *> *songDictList = data[@"songs"];
  NSArray<GBSongRespModel *> *songList = [NSArray modelArrayWithClass:[GBSongRespModel class] json:songDictList];
  NSUInteger round = [data[@"round"] unsignedIntegerValue];
  NSUInteger type = [data[@"type"] unsignedIntegerValue];
  
  NSMutableArray *songPlayInfos = [NSMutableArray array];
  for (GBSongRespModel *model in songList) {
    GBSongPlay *info = [[GBSongPlay alloc] init];
    [info updateWithSongRespModel:model];
    [songPlayInfos addObject:info];
  }
  NSUInteger seq = message.timestamp;
  [self.songListUpdateListener onRoomSongListUpdate:songPlayInfos.copy inRound:round seq:seq type:type];
}


#pragma mark - GBIMEvent
- (void)onIMReceiveRoomMessage:(NSString *)message {
  GB_LOG_D(@"[PUSH] %@", message);
  // push 消息
  GBPushMessege *messageModel = [GBPushMessege modelWithJSON:message];
  GBPushCommand cmd = messageModel.cmd;
  
  if (cmd == kGBUserStateUpdateCmd) {
    // 成员状态变更
    [self onReceiveUserStateUpdateWithMessage:messageModel];
  }
  
  else if (cmd == kGBUserListUpdateCmd) {
    // 成员列表变更通知
    [self onReceiveUserListUpdateWithMessage:messageModel];
  }
  
  else if (cmd == kGBRoomStateUpdateCmd) {
    // 房间状态变更通知
    [self onReceiveRoomStateUpdateWithMessage:messageModel];
  }
  
  else if (cmd == kGBBroadcastCmd) {
    // 终端透传广播消息
    [self onReceiveBroadcastMessage:messageModel];
  }
  
  else if (cmd == kGBSongListUpdateCmd) {
    // 点歌列表变更通知
    [self onReceiveSongListUpdateWithMessage:messageModel];
  }
}

@end
