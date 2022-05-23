//
//  GBRoomUserService.m
//  KTVGrab
//
//  Created by Vic on 2022/3/16.
//

#import "GBRoomUserService.h"
#import "GBExpress.h"
#import "GBIM.h"
#import "GBExternalDependency.h"
#import "GBConcreteRespModel.h"
#import "GBRoomInfo.h"
#import "GBRoomStreamService.h"
#import "GBNetMonitor.h"
#import "GBDataProvider.h"
#import "GBNetQualityModel.h"

@interface GBRoomUserService ()
<
GBStreamServiceEventListener
>

@property (nonatomic,  weak ) id<GBRoomUserEventListener> eventListener;
@property (nonatomic,  weak ) id<GBRoomUserAwaringListener> userAwaringListener;
@property (nonatomic, strong) NSPointerArray              *seiListeners;
@property (nonatomic, strong) NSPointerArray              *netQualityListeners;
@property (nonatomic, strong) GBRoomStreamService         *streamService;

@property (nonatomic, strong) NSMutableDictionary<NSString *, GBUser *> *userInfoTable; // userID: user

@property (nonatomic, assign) NSUInteger  listSeq;
@property (nonatomic, assign) BOOL        myMicEnable;

@end

@implementation GBRoomUserService
 
- (void)dealloc {
  GB_LOG_D(@"[DEALLOC]GBRoomUserService dealloc");
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [self setup];
  }
  return self;
}

- (void)setup {
  self.userInfoTable        = [NSMutableDictionary dictionary];
  self.seiListeners         = [NSPointerArray weakObjectsPointerArray];
  self.netQualityListeners  = [NSPointerArray weakObjectsPointerArray];
  
  self.streamService = [[GBRoomStreamService alloc] init];
  [self.streamService setListener:self];
}

- (void)appendSeiListeners:(NSArray<id<GBRoomUserSEIListener>> *)seiListeners {
  for (id<GBRoomUserSEIListener> listener in seiListeners) {
    [self.seiListeners addPointer:(__bridge void * _Nullable)(listener)];
  }
}

- (void)appendQualityUpdateListeners:(NSArray<id<GBRoomUserNetQualityListener>> *)listeners {
  for (id<GBRoomUserNetQualityListener> listener in listeners) {
    [self.netQualityListeners addPointer:(__bridge void * _Nullable)(listener)];
  }
}

- (GBUser *)getMyself {
  return [GBUserAccount shared].myself;
}

- (GBUser *)getRoomHost {
  __block GBUser *host = nil;
  [self.userInfoTable enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, GBUser * _Nonnull obj, BOOL * _Nonnull stop) {
    if (obj.roleType == GBUserRoleTypeHost) {
      host = obj;
      *stop = YES;
    }
  }];
  return host;
}

- (BOOL)isMyselfHost {
  return [self getMyself].roleType == GBUserRoleTypeHost;
}

- (void)setUser:(GBUser *)user withUserID:(NSString *)userID {
  if (user && userID.length > 0) {
    [self.userInfoTable setObject:user forKey:userID];
  }
}

- (GBUser *)getUserWithUserID:(NSString *)userID {
  if (userID.length > 0) {
    return [self.userInfoTable objectForKey:userID];
  }
  return nil;
}

- (void)removeUserWithUserID:(NSString *)userID {
  if (userID.length > 0) {
    [self.userInfoTable removeObjectForKey:userID];
  }
}

- (void)forceUpdateUserList:(NSArray<GBUser *> *)userList {
  [self.userInfoTable removeAllObjects];
  GBUser *myself = nil;
  for (GBUser *user in userList) {
    if ([user.userID isEqualToString:[GBExternalDependency shared].userID]) {
      myself = user;
    }
    [self setUser:user withUserID:user.userID];
  }
  // 如果自己是观众, 后台进房信息不会有自己的信息, 需要本地添加自己用户信息
  if (!myself) {
    myself = [self getLocalConstructedMyself];
    [self setUser:myself withUserID:myself.userID];
  }
  
  if (![GBUserAccount shared].myself) {
    [self.userAwaringListener userService:self onAwaringMyself:myself];
  }
  [GBUserAccount shared].myself = myself;
  [self calloutToAddUser];
}

- (GBUser *)getLocalConstructedMyself {
  GBUser *user = [[GBUser alloc] init];
  user.userID = [GBExternalDependency shared].userID;
  user.userName = [GBExternalDependency shared].userName;
  user.avatarURLString = [GBExternalDependency shared].avatar;
  user.role = [[GBUserRole alloc] initWithRoleType:GBUserRoleTypeSpectator];
  user.micOn = NO;
  user.onstage = NO;
  return user;
}

#pragma mark - GBAgentUserUpdateListener
- (void)onRoomUserListUpdate:(NSArray<GBUserRespModel *> *)userList seq:(NSUInteger)seq {
  if (seq > self.listSeq) {
    self.listSeq = seq;
    [self updateUserList:userList];
  }
}

- (void)onRoomUserStateUpdate:(NSArray<GBUserRespModel *> *)userList seq:(NSUInteger)seq {
  if (seq > self.listSeq) {
    self.listSeq = seq;
    [self updateUserState:userList];
  }
}

#pragma mark - GBStreamServiceProtocol
- (void)streamService:(GBRoomStreamService *)service onUser:(NSString *)userID soundLevelUpdate:(CGFloat)soundLevel {
  GB_INTERVAL_EXECUTE(kGBSoundLevelUpdateCount, 20, ^{
    GB_LOG_D(@"[SOUND_LEVEL] user: %@ sound level: %.0f", userID, soundLevel);
  })
  [self.eventListener userService:self onUser:userID soundLevelUpdate:soundLevel];
}

- (void)streamService:(GBRoomStreamService *)service onReceiveSEI:(GBSEIModel *)model {
  for (id<GBRoomUserSEIListener> listener in self.seiListeners) {
    [listener userService:self onReceiveSEI:model];
  }
}

- (void)streamService:(GBRoomStreamService *)service onUser:(NSString *)userID qualityUpdate:(GBNetQualityModel *)quality {
  for (id<GBRoomUserNetQualityListener> listener in self.netQualityListeners) {
    if ([listener respondsToSelector:@selector(userService:onUser:qualityUpdate:)]) {
      [listener userService:self onUser:userID qualityUpdate:quality];
    }
  }
}

- (void)streamService:(GBRoomStreamService *)service onUser:(NSString *)userID netQualityLevelUpdate:(GBNetQuality)qualityLevel {
  for (id<GBRoomUserNetQualityListener> listener in self.netQualityListeners) {
    if ([listener respondsToSelector:@selector(userService:onUser:netQualityLevelUpdate:)]) {
      [listener userService:self onUser:userID netQualityLevelUpdate:qualityLevel];
    }
  }
}

- (void)streamService:(GBRoomStreamService *)service onMyTestSpeedQualityUpdate:(GBNetQuality)qualityLevel {
  for (id<GBRoomUserNetQualityListener> listener in self.netQualityListeners) {
    if ([listener respondsToSelector:@selector(userService:onMyTestSpeedQualityUpdate:)]) {
      [listener userService:self onMyTestSpeedQualityUpdate:qualityLevel];
    }
  }
}

- (void)streamService:(GBRoomStreamService *)service onUser:(NSString *)userID streamOnAir:(BOOL)flag {
  [self.eventListener userService:self onUser:userID streamOnAir:flag];
}

#pragma mark - Private
- (void)updateUserState:(NSArray<GBUserRespModel *> *)userList {
  for (GBUserRespModel *userRsp in userList) {
    GBUser *user = [self getUserWithUserID:userRsp.userID];
    if (!user) {
      continue;
    }
    [user updateWithUserRespModel:userRsp];
    [self.eventListener userService:self onUserMiscUpdate:user];
  }
}

- (void)updateUserList:(NSArray<GBUserRespModel *> *)userList {
  for (GBUserRespModel *userRsp in userList) {
    NSInteger type = userRsp.type;
    NSInteger delta = userRsp.delta;
    GBUser *user = [self getUserWithUserID:userRsp.userID];
    if (!user) {
      user = [[GBUser alloc] init];
    }
    [user updateWithUserRespModel:userRsp];
    
    if (type == 4) {
      // 上下麦
      [self setUser:user withUserID:user.userID];
      [self calloutToAddUser];
    }
    else if (type == 5) {
      // 成员进房间
      if (delta > 0) {
        [self setUser:user withUserID:user.userID];
        [self calloutToAddUser];
      }else {
        [self calloutToRemoveUserWithID:user.userID];
      }
    }
  }
}

#pragma mark Callout
- (void)calloutToAddUser {
  [self calloutToUpdateUserListAfterDelay];
}

- (void)calloutToRemoveUserWithID:(NSString *)userID {
  if ([userID isEqualToString:[self getMyself].userID]) {
    [self.userAwaringListener userService:self onMyselfRemoved:[self getUserWithUserID:userID]];
  }
  [self removeUserWithUserID:userID];
  [self calloutToUpdateUserListAfterDelay];
}

- (void)calloutToUpdateUserListAfterDelay {
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(calloutToUpdateUserList) object:nil];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self calloutToUpdateUserList];
  });
}

- (void)calloutToUpdateUserList {
  [self.eventListener userService:self onUserListUpdate:self.userInfoTable.allValues];
}

@end

@implementation GBRoomUserService (UserAction)

- (void)startSendingMySoundWithCompletion:(void (^)(BOOL))completion {
  [self enableMyMic:YES complete:completion];
}

- (void)stopSendingMySoundWithCompletion:(void (^)(BOOL))completion {
  [self enableMyMic:NO complete:completion];
}

- (void)startSendingMyStream {
  if (![[GBUserAccount shared] getMyAuthority].canPublishStream) {
    return;
  }
  [self.streamService startPublishingWithUserID:[self getMyself].userID];
}

- (void)stopSendingMyStream {
  [self.streamService stopPublishingWithUserID:[self getMyself].userID];
}

- (void)playHostStream:(BOOL)play {
  NSString *userID = [self getRoomHost].userID;
  if (!userID) {
    return;
  }
  [self.streamService playHostStream:play hostUserID:userID];
}

- (BOOL)checkIfUserStreamOnAir:(NSString *)userID {
  if (!userID) {
    return NO;
  }
  return [self.streamService checkIfUserStreamOnAir:userID];
}

- (void)enableMyMic:(BOOL)enable complete:(void (^)(BOOL))complete {
  if (![[[GBUserAccount shared] getMyAuthority] canOperateMicrophone]) {
    [[GBExpress shared] setMicEnable:NO];
    return;
  }
  [[GBExpress shared] setMicEnable:enable];
  NSUInteger index = [self getMyself].micIndex;
  if (enable != self.myMicEnable) {
    @weakify(self);
    [GBDataProvider reportOperationWithMicEnabled:enable atIndex:index roomID:self.roomInfo.roomID complete:^(BOOL suc, NSError * _Nullable err, id  _Nullable rsv) {
      @strongify(self);
      self.myMicEnable = enable;
      !complete ?: complete(err == nil);
    }];
  }
}

@end
