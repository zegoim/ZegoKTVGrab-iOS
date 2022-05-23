//
//  GBLeaveRoomAPI.m
//  KTVGrab
//
//  Created by Vic on 2022/3/15.
//

#import "GBLeaveRoomAPI.h"

@implementation GBLeaveRoomAPI

- (NSString *)path {
  return @"quit_room";
}

- (NSDictionary *)payload {
  return @{
    @"room_id": self.roomID,
  };
}

@end
