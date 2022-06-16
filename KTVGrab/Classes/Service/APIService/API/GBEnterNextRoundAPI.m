//
//  GBEnterNextRoundAPI.m
//  KTVGrab
//
//  Created by Vic on 2022/5/31.
//

#import "GBEnterNextRoundAPI.h"

@implementation GBEnterNextRoundAPI

- (NSString *)path {
  return @"enter_next_round";
}

- (NSDictionary *)payload {
  return @{
    @"room_id": self.roomID,
  };
}

@end
