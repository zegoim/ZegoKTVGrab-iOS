//
//  GBSongPlayInfo.m
//  KTVGrab
//
//  Created by Vic on 2022/3/14.
//

#import "GBSongPlay.h"
#import "GBConcreteRespModel.h"

@implementation GBSongPlay

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
  return @{
    @"songID": @"song_id",
    @"uniqueID": @"song_unique_id",
    @"order": @"songID",
  };
}

- (void)updateWithSongRespModel:(GBSongRespModel *)model {
  self.songID = model.songID;
  self.uniqueID = model.uniqueID;
  self.order = model.order;
  self.firstPartDuration = model.firstPartDuration;
  self.singerName = model.singerName;
  self.songName = model.songName;
}

@end
