//
//  GBGetRoomListAPI.m
//  KTVGrab
//
//  Created by Vic on 2022/3/12.
//

#import "GBGetRoomListAPI.h"

@implementation GBGetRoomListAPI

- (NSString *)path {
  return @"get_room_list";
}

- (NSDictionary *)payload {
  return @{
    @"count": @(_pageCount),
    @"begin_timestamp": @(_beginTimeStamp),
  };
}

@end
