//
//  GBOperateMicAPI.m
//  KTVGrab
//
//  Created by Vic on 2022/4/12.
//

#import "GBOperateMicAPI.h"

@implementation GBOperateMicAPI

- (NSString *)path {
  return @"operate_mic";
}

- (NSDictionary *)payload {
  return @{
    @"room_id": self.roomID,
    @"mic_index": @(self.micIndex),
    @"mic_state": @(self.micState),
  };
}

@end
