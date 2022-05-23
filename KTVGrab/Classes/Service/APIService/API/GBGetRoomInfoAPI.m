//
//  GBGetRoomInfoAPI.m
//  KTVGrab
//
//  Created by Vic on 2022/4/11.
//

#import "GBGetRoomInfoAPI.h"

@implementation GBGetRoomInfoAPI

- (NSString *)path {
  return @"get_room_info";
}

- (NSDictionary *)payload {
  return @{
    @"room_id": self.roomID,
  };
}

@end
