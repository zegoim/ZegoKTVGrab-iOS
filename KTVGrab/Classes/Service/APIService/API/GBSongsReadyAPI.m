//
//  GBSongsReadyAPI.m
//  KTVGrab
//
//  Created by Vic on 2022/3/16.
//

#import "GBSongsReadyAPI.h"

@implementation GBSongsReadyAPI

- (NSString *)path {
  return @"report_finish_download";
}

- (NSDictionary *)payload {
  
  NSMutableArray *errList = [NSMutableArray array];
  for (NSString *uniqID in self.invalidUniqueIDs) {
    [errList addObject:@{
      @"unique_id": uniqID,
    }];
  }
  
  return @{
    @"room_id": self.roomID,
    @"round": @(self.round),
    @"error_song_list": errList.copy,
  };
}

@end
