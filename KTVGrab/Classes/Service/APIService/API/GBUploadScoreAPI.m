//
//  GBUploadScoreAPI.m
//  KTVGrab
//
//  Created by Vic on 2022/4/8.
//

#import "GBUploadScoreAPI.h"

@implementation GBUploadScoreAPI

- (NSString *)path {
  return @"upload_score";
}

- (NSDictionary *)payload {
  return @{
    @"room_id": self.roomID,
    @"song_id": self.songID,
    @"score": @(self.score),
  };
}

@end
