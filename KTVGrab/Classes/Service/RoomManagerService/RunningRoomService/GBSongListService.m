//
//  GBSongListService.m
//  KTVGrab
//
//  Created by Vic on 2022/4/6.
//

#import "GBSongListService.h"
#import "GBSongPlay.h"

@interface GBSongListService ()

/**
 * round : {
 *  index1: songPlay1,
 *  index2: songPlay2
 * }
 */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary<NSNumber *, GBSongPlay *> *> *songPlaysAtRoundTable;
@property (nonatomic, assign) NSUInteger lastSeq;
@property (nonatomic,  weak ) id<GBSongListListener> listener;

@end

@implementation GBSongListService

- (void)dealloc {
  GB_LOG_D(@"[DEALLOC]%@ dealloc", NSStringFromClass(self.class));
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _songPlaysAtRoundTable = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)forceUpdatingSongPlays:(NSArray<GBSongPlay *> *)songPlays inRound:(NSUInteger)round {
  GB_LOG_D(@"[SONG_LIST] Song plays updating, force: 1, song count: %lu", (unsigned long)songPlays.count);
  if (songPlays.count > 0) {
    [self calloutUpdatingWithSongPlays:songPlays inRound:round type:5];
  }
}

- (GBSongPlay *)getSongPlayAtIndex:(NSUInteger)index inRound:(NSUInteger)round {
  NSDictionary *songPlays = [self.songPlaysAtRoundTable objectForKey:@(round)];
  GBSongPlay *songPlay = [songPlays objectForKey:@(index)];
  return songPlay;
}

- (void)calloutUpdatingWithSongPlays:(NSArray<GBSongPlay *> *)songPlays inRound:(NSUInteger)round type:(NSUInteger)type {
  [self cacheSongPlays:songPlays inRound:round];
  GB_LOG_D(@"[SONG_LIST] List service call updating song plays count: %lu, round: %lu, type: %lu", (unsigned long)songPlays.count, round, type);
  [self.listener songListService:self onSongListUpdate:songPlays inRound:round type:type];
}

- (void)cacheSongPlays:(NSArray<GBSongPlay *> *)songPlays inRound:(NSUInteger)round {
  NSMutableDictionary<NSNumber *, GBSongPlay *> *indexMap = [NSMutableDictionary dictionary];
  [songPlays enumerateObjectsUsingBlock:^(GBSongPlay * _Nonnull songPlay, NSUInteger idx, BOOL * _Nonnull stop) {
    if (songPlay.order <= 0) {
      songPlay.order = idx + 1;
    }
    [indexMap setObject:songPlay forKey:@(songPlay.order)];
  }];
  [self.songPlaysAtRoundTable setObject:indexMap forKey:@(round)];
}

- (void)onRoomSongListUpdate:(nonnull NSArray<GBSongPlay *> *)songList inRound:(NSUInteger)round seq:(NSUInteger)seq type:(NSUInteger)type {
  if (seq > self.lastSeq) {
    GB_LOG_D(@"[SONG_LIST] Song plays updating, force: 0");
    self.lastSeq = seq;
    [self calloutUpdatingWithSongPlays:songList inRound:round type:type];
  }else {
    GB_LOG_W(@"[SONG_LIST] This song list seq has expired. Last seq: %lu, this seq: %lu", (unsigned long)self.lastSeq, (unsigned long)seq);
  }
}

@end
