//
//  GBCreateRoomAPI.m
//  KTVGrab
//
//  Created by Vic on 2022/3/12.
//

#import "GBCreateRoomAPI.h"
#import "GBExternalDependency.h"

@implementation GBCreateRoomAPI

- (NSString *)path {
  return @"create_room";
}

- (NSDictionary *)payload {
  return @{
    @"subject": _roomName,
    @"cover_img": _coverImage ?: @"",
    @"max_round": @(_rounds),
    @"song_number_per_round": @(_songsPerRound),
    @"nick_name": self.userName,
    @"avatar": [GBExternalDependency shared].avatar,
    @"max_mic": @(self.maxMic),
  };
}

@end
