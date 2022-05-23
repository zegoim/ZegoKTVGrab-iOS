//
//  GBUserPlayerAuthority.m
//  KTVGrab
//
//  Created by Vic on 2022/4/21.
//

#import "GBUserPlayerAuthority.h"

@implementation GBUserPlayerAuthority

- (BOOL)canPublishStream {
  return YES;
}

- (BOOL)canDownloadSong {
  return YES;
}

- (BOOL)canDownloadLyric {
  return YES;
}

- (BOOL)canDownloadPitch {
  return YES;
}

- (BOOL)canGrab {
  return YES;
}

- (BOOL)canSeeRoundGrade {
  return YES;
}

- (BOOL)canOperateMicrophone {
  return YES;
}

- (BOOL)canOperateAudioConfig {
  return YES;
}

@end
