//
//  GBUserSpectatorAuthority.m
//  KTVGrab
//
//  Created by Vic on 2022/4/21.
//

#import "GBUserSpectatorAuthority.h"

@implementation GBUserSpectatorAuthority


- (BOOL)canPublishStream {
  return NO;
}

- (BOOL)canDownloadSong {
  return YES;
}

- (BOOL)canDownloadLyric {
  return YES;
}

- (BOOL)canDownloadPitch {
  return NO;
}

- (BOOL)canGrab {
  return NO;
}

- (BOOL)canSeeRoundGrade {
  return NO;
}

- (BOOL)canOperateMicrophone {
  return NO;
}

- (BOOL)canOperateAudioConfig {
  return NO;
}

@end
