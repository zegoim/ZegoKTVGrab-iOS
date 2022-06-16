//
//  GBSongResourceCache.m
//  KTVGrab
//
//  Created by Vic on 2022/4/6.
//

#import "GBSongResourceCache.h"
#import "GBSong.h"
#import "GBSongPlay.h"
#import <YYKit/YYKit.h>

@interface GBSongResourceCache ()

/**
 * 缓存 GBSong  对象, key 为 songID
 * <NSString *, GBSong *>
 */
@property (nonatomic, strong) YYMemoryCache *songTable;

/**
 * 缓存 GBSongPlay 对象, key 为 songID
 * <NSString *, GBSongPlay *>
 */
@property (nonatomic, strong) YYMemoryCache *songPlayTable;

@end

@implementation GBSongResourceCache

- (instancetype)init
{
  self = [super init];
  if (self) {
    _songTable = [[YYMemoryCache alloc] init];
    _songTable.shouldRemoveAllObjectsWhenEnteringBackground = NO;
    _songTable.shouldRemoveAllObjectsOnMemoryWarning = NO;
    _songTable.didReceiveMemoryWarningBlock = ^(YYMemoryCache * _Nonnull cache) {
      GB_LOG_W(@"[MEMORY] Receiving memory warning, clear all objects related.");
    };

    _songPlayTable = [[YYMemoryCache alloc] init];
    _songPlayTable.shouldRemoveAllObjectsOnMemoryWarning = NO;
    _songPlayTable.shouldRemoveAllObjectsWhenEnteringBackground = NO;
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
      GB_LOG_E(@"[BUG] -[%@ %@] Song is nil. SongID: %@, songTable: %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), songID, self.songTable);
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
