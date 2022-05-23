//
//  GBSongResourceCache.m
//  KTVGrab
//
//  Created by Vic on 2022/4/6.
//

#import "GBSongResourceCache.h"
#import "GBSong.h"
#import "GBSongPlay.h"

@interface GBSongResourceCache ()

/**
 * 缓存 GBSong  对象, key 为 songID
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, GBSong *> *songTable;

/**
 * 缓存 GBSongPlay 对象, key 为 songID
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, GBSongPlay *> *songPlayTable;

/**
 * 映射 resourceID 和 songID
 */
@property (nonatomic, strong) NSMutableDictionary *resourceTable;

@end

@implementation GBSongResourceCache

- (instancetype)init
{
  self = [super init];
  if (self) {
    _songTable = [NSMutableDictionary dictionary];
    _songPlayTable = [NSMutableDictionary dictionary];
    _resourceTable = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)setSong:(GBSong *)song bySongID:(NSString *)songID {
  if (!songID || !song) {
    return;
  }
  [self.songTable setObject:song forKey:songID];
}

- (void)setSongPlay:(GBSongPlay *)songPlay bySongID:(NSString *)songID {
  if (!songPlay || !songID) {
    return;
  }
  [self.songPlayTable setObject:songPlay forKey:songID];
}

- (GBSong *)getSongBySongID:(NSString *)songID {
  if (songID.length > 0) {
    GBSong *song = [self.songTable objectForKey:songID];
    if (!song) {
      song = [[GBSong alloc] init];
      song.songID = songID;
      [self setSong:song bySongID:songID];
    }
    return song;
  }
  return nil;
}

- (GBSongPlay *)getSongPlayBySongID:(NSString *)songID {
  return [self.songPlayTable objectForKey:songID];
}

- (void)updateSongDuration:(NSUInteger)duration forSongID:(NSString *)songID {
  if (!songID) {
    return;
  }
  GBSong *song = [self.songTable objectForKey:songID];
  if (song) {
    song.duration = duration;
  }
}

@end
