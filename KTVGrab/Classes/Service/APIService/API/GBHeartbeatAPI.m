//
//  GBHeartbeatAPI.m
//  KTVGrab
//
//  Created by Vic on 2022/3/15.
//

#import "GBHeartbeatAPI.h"

@implementation GBHeartbeatAPI

- (NSString *)path {
  return @"heartbeat";
}

- (NSDictionary *)payload {
  return @{
    @"room_id": self.roomID,
  };
}

@end
