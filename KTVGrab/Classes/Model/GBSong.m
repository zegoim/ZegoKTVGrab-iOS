//
//  GBSong.m
//  KTVGrab
//
//  Created by Vic on 2022/3/7.
//

#import "GBSong.h"
#import "GBSDKModel.h"
#import "GBSongPlay.h"

@implementation GBSong

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
  return @{
    @"songID": @"song_id",
    @"krcToken": @"krc_token",
    @"segBegin": @"segment_begin",
    @"segEnd": @"segment_end",
    @"preDuration": @"prelude_duration",
  };
}

- (NSUInteger)duration {
  if (_duration <= 0) {
    if (self.segBegin > 0
        && self.segEnd > 0
        && self.segEnd > self.segBegin) {
      return self.segEnd - self.segBegin;
    }
    return 0;
  }
  return _duration;
}

- (void)updateWithSDKSongClip:(GBSDKSongClip *)sdkSongClip {
  if (!self.songID || [self.songID isEqualToString:sdkSongClip.songID]) {
    self.songID = sdkSongClip.songID;
    self.krcToken = sdkSongClip.krcToken;
    self.segBegin = sdkSongClip.segBegin;
    self.segEnd = sdkSongClip.segEnd;
    self.preludeDuration = sdkSongClip.preDuration;
    
    GBSDKSongResource *resource = sdkSongClip.resources.firstObject;
    self.resourceID = resource.resourceID;
  }
}

- (void)updateWithSongPlay:(GBSongPlay *)songPlay {
  if (!self.songID || [self.songID isEqualToString:songPlay.songID]) {
    self.songID = songPlay.songID;
    self.songName = songPlay.songName;
    self.singerName = songPlay.singerName;
  }
}

- (BOOL)validateIntegrity {
  if (!self.resourceID) {
    return NO;
  }
  
  GBUserAuthority *authority = [[GBUserAccount shared] getMyAuthority];
  
  if ([authority canDownloadSong]) {  
    if (self.downloadState != GBSongDownloadStateDownloaded) {
      return NO;
    }
  }
  
  if (![self validateLyric]) {
    return NO;
  }
  
  if ([authority canDownloadPitch]) {
    if (!self.pitchJson) {
      return NO;
    }
  }
  return YES;
}

- (BOOL)validateLyric {
  GBUserAuthority *authority = [[GBUserAccount shared] getMyAuthority];
  if ([authority canDownloadLyric]) {
    if (self.lyricJson) {
      return YES;
    }
  }
  return NO;
}

@end
