//
//  GBCloseRoomAPI.m
//  KTVGrab
//
//  Created by Vic on 2022/3/15.
//

#import "GBCloseRoomAPI.h"

@implementation GBCloseRoomAPI

- (NSString *)path {
  return @"close_room";
}

- (NSDictionary *)payload {
  return @{
    @"room_id": self.roomID,
  };
}

@end
