//
//  GBGrabMicAPI.m
//  KTVGrab
//
//  Created by Vic on 2022/3/16.
//

#import "GBGrabMicAPI.h"

@implementation GBGrabMicAPI

- (NSString *)path {
  return @"grab_mic";
}

- (NSDictionary *)payload {
  return @{
    @"room_id": self.roomID,
    @"round": @(self.round),
    @"song_index": @(self.index),
  };
}

@end
