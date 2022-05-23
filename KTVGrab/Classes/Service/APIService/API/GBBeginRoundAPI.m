//
//  GBBeginRoundAPI.m
//  KTVGrab
//
//  Created by Vic on 2022/3/16.
//

#import "GBBeginRoundAPI.h"

@implementation GBBeginRoundAPI

- (NSString *)path {
  return @"begin_round";
}

- (NSDictionary *)payload {
  return @{
    @"room_id": self.roomID,
  };
}

@end
