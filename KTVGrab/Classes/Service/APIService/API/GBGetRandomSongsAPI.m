//
//  GBGetRandomSongsAPI.m
//  KTVGrab
//
//  Created by Vic on 2022/3/16.
//

#import "GBGetRandomSongsAPI.h"

@implementation GBGetRandomSongsAPI

- (NSString *)path {
  return @"get_song_id_list";
}

- (NSDictionary *)payload {
  return @{};
}

@end
