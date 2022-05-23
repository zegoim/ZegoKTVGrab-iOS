//
//  GBSeatService.m
//  KTVGrab
//
//  Created by Vic on 2022/4/11.
//

#import "GBSeatService.h"
#import "GBSeatInfo.h"

@interface GBSeatService ()

@property (nonatomic, weak) id<GBSeatEventListener> listener;
@property (nonatomic, strong) NSMutableDictionary<NSString *, GBSeatInfo *> *userSeatTable; // {userID: 麦位信息}
@property (nonatomic, strong) NSMutableSet *usersHasStream;

@end

@implementation GBSeatService

- (instancetype)init {
  self = [super init];
  if (self) {
    _userSeatTable = [NSMutableDictionary dictionary];
    _usersHasStream = [NSMutableSet set];
  }
  return self;
}

- (void)userService:(GBRoomUserService *)service onUserListUpdate:(NSArray<GBUser *> *)userList {
  [self.userSeatTable removeAllObjects];
  
  [userList enumerateObjectsUsingBlock:^(GBUser * _Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
    GBSeatInfo *seatInfo = [[GBSeatInfo alloc] init];
    seatInfo.userName = ({
      NSString *name = user.userName;
      if ([user.userID isEqualToString:[GBUserAccount shared].myself.userID]) {
        name = [name stringByAppendingString:@"(我)"];
      }
      name;
    });
    seatInfo.avatarURLString = user.avatarURLString;
    seatInfo.seatIndex = user.micIndex;
    seatInfo.mute = !user.isMicOn;
    seatInfo.hasStream = [self.usersHasStream containsObject:user.userID];
    
    [self.userSeatTable setObject:seatInfo forKey:user.userID];
  }];
  
  [self calloutToUpdateSeatList:self.userSeatTable.allValues];
}

- (void)userService:(GBRoomUserService *)service onUserMiscUpdate:(GBUser *)user {
  if (!user) {
    return;
  }
  GBSeatInfo *seat = [self.userSeatTable objectForKey:user.userID];
  if (!seat) {
    return;
  }
  seat.mute = !user.isMicOn;
  // 如果麦位位置变了, 则需要通知 UI 刷新列表
  if (seat.seatIndex != user.micIndex) {
    seat.seatIndex = user.micIndex;
    [self calloutToUpdateSeatList:self.userSeatTable.allValues];
  }else {
    [self calloutToUpdateSeatMisc:seat];
  }
}

- (void)userService:(GBRoomUserService *)service onUser:(NSString *)userID soundLevelUpdate:(CGFloat)soundLevel {
  GBSeatInfo *seat = [self.userSeatTable objectForKey:userID];
  if (!seat) {
    return;
  }
  seat.soundLevel = soundLevel;
  [self calloutToUpdateSeatMisc:seat];
}

- (void)userService:(GBRoomUserService *)service onUser:(NSString *)userID qualityUpdate:(GBNetQualityModel *)quality {
  GBSeatInfo *seat = [self.userSeatTable objectForKey:userID];
  if (!seat) {
    return;
  }
  seat.netQuality = quality;
  [self calloutToUpdateSeatMisc:seat];
}

- (void)userService:(GBRoomUserService *)service onUser:(NSString *)userID netQualityLevelUpdate:(GBNetQuality)qualityLevel {
  GBSeatInfo *seat = [self.userSeatTable objectForKey:userID];
  if (!seat) {
    return;
  }
  seat.qualityLevel = qualityLevel;
  [self calloutToUpdateSeatMisc:seat];
}

- (void)userService:(GBRoomUserService *)service onUser:(NSString *)userID streamOnAir:(BOOL)onAir {
  // 不能直接回调给 seat, 因为流回调比用户列表更新要早, seatTable 在第一之间还没有创建
  if (userID.length > 0) {  
    if (onAir) {
      [self.usersHasStream addObject:userID];
    }else {
      [self.usersHasStream removeObject:userID];
    }
  }
  
  GBSeatInfo *seat = [self.userSeatTable objectForKey:userID];
  if (!seat) {
    return;
  }
  seat.hasStream = onAir;
  [self calloutToUpdateSeatMisc:seat];
}

#pragma mark - Private
- (void)calloutToUpdateSeatList:(NSArray<GBSeatInfo *> *)seatList {
  [self.listener seatService:self onSeatListUpdate:seatList];
}
  
- (void)calloutToUpdateSeatMisc:(GBSeatInfo *)seat {
  [self.listener seatService:self onSeatMiscUpdate:seat];
}

@end
