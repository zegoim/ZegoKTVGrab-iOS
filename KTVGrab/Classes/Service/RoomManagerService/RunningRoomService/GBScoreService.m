//
//  GBScoreService.m
//  KTVGrab
//
//  Created by Vic on 2022/4/11.
//

#import "GBScoreService.h"
#import "GBExpress.h"
#import "GBSong.h"

@interface GBScoreService ()

@property (nonatomic, strong) GBSong *curScoringSong;

@end

@implementation GBScoreService

- (void)dealloc {
  GB_LOG_D(@"[DEALLOC]GBScoreService dealloc");
  [self stopScoringSong];
}

- (void)startScoringSong:(GBSong *)song {
  self.curScoringSong = song;
  [[GBExpress shared] startScore:song.resourceID];
}

- (void)stopScoringSong {
  [[GBExpress shared] stopScore:self.curScoringSong.resourceID];
  self.curScoringSong = nil;
}

- (int)getAvgScoreForSong:(GBSong *)song {
  return [[GBExpress shared] getAvgScore:song.resourceID];
}

- (int)getPrevScoreForSong:(GBSong *)song {
  return [[GBExpress shared] getPrevScore:song.resourceID];;
}

@end
