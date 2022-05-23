//
//  GBGetUserListAPI.m
//  KTVGrab
//
//  Created by Vic on 2022/3/17.
//

#import "GBGetUserListAPI.h"

@implementation GBGetUserListAPI

- (NSString *)path {
  return @"get_attendee_list";
}

- (NSDictionary *)payload {
  return @{
    @"room_id": self.roomID,
    @"page": @1,
    @"page_size": @100,
  };
}

@end
