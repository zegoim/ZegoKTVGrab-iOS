//
//  GBLoginRoomAPI.m
//  KTVGrab
//
//  Created by Vic on 2022/3/14.
//

#import "GBJoinRoomAPI.h"
#import "GBExternalDependency.h"

@implementation GBJoinRoomAPI

- (NSString *)path {
  return @"login_room";
}

- (NSDictionary *)payload {
  return @{
    @"room_id": self.roomID,
    @"nick_name": self.userName,
    @"avatar": [GBExternalDependency shared].avatar,
  };
}

@end
