//
//  GBSongResourceDownloader.m
//  KTVGrab
//
//  Created by Vic on 2022/4/6.
//

#import "GBSongResourceDownloader.h"
#import "GBSong.h"
#import "GBSongPlay.h"
#import "GBSongResourceCache.h"
#import "GBExpress.h"

@interface GBSongResourceDownloader ()

@property (nonatomic, strong) GBSongResourceCache *resourceCache;

@end

@implementation GBSongResourceDownloader

- (instancetype)initWithResourceCache:(GBSongResourceCache *)resourceCache {
  if (self = [super init]) {
    _resourceCache = resourceCache;
  }
  return self;
}

- (void)getResourceInfoInBatchesWithSongPlays:(NSArray<GBSongPlay *> *)songPlays
                                     complete:(void (^)(NSError * error, NSArray<GBSongPlay *> *songPlaysWithCR, NSArray<GBSongPlay *> *songPlaysWithoutCR))complete {
  
  GB_LOG_D(@"[SONG_LIST] Get song list resource info in batches, song count: %lu", (unsigned long)songPlays.count);
  
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
    dispatch_group_t group = dispatch_group_create();
    NSMutableArray *songPlaysWithCR = [NSMutableArray array];
    NSMutableArray *songPlaysWithoutCR = [NSMutableArray array];
    __block NSError *err = nil;
    
    [songPlays enumerateObjectsUsingBlock:^(GBSongPlay * _Nonnull songPlay, NSUInteger idx, BOOL * _Nonnull stop) {
      dispatch_group_enter(group);
      
      NSString *songID = songPlay.songID;
      
      GBSong *cacheSong = [self.resourceCache getSongBySongID:songID];
      [self.resourceCache setSongPlay:songPlay bySongID:songID];
      
      if (cacheSong.resourceID.length > 0) {
        [songPlaysWithCR addObject:songPlay];
        dispatch_group_leave(group);
        return;
      }
      
      [cacheSong updateWithSongPlay:songPlay];
      
      [[GBExpress shared] requestSongClipWithSongID:songID complete:^(NSError * _Nonnull error, GBSong * _Nonnull res) {
        if (error && error.code != 0) {
          // 加入列表, 用于告知后台该歌曲无版权
          [songPlaysWithoutCR addObject:songPlay];
        }else {
          cacheSong.resourceID   = res.resourceID;
          cacheSong.krcToken     = res.krcToken;
          cacheSong.segBegin     = res.segBegin;
          cacheSong.segEnd       = res.segEnd;
          cacheSong.preludeDuration  = res.preludeDuration;
          
          [songPlaysWithCR addObject:songPlay];
        }
        dispatch_group_leave(group);
      }];
    }];
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
      if (complete) {
        GB_LOG_D(@"[SONG_LIST][CB] Get song list resource info in batches callback");
        //TODO: 这里的 err 只会回调 nil, 因为有 songPlaysWithoutCR
        complete(err, songPlaysWithCR, songPlaysWithoutCR);
      }
    });
  });
}

- (void)getResourceInfoWithSongPlay:(GBSongPlay *)songPlay complete:(void (^)(NSError * _Nonnull))complete {
  GB_LOG_D(@"[SONG_LIST] Get song list resource info, song name: %@, song id: %@", songPlay.songName, songPlay.songID);
  [self getResourceInfoInBatchesWithSongPlays:@[songPlay] complete:^(NSError * _Nonnull error, NSArray<GBSongPlay *> * _Nonnull songPlaysWithCR, NSArray<GBSongPlay *> * _Nonnull songPlaysWithoutCR) {
    GB_LOG_D(@"[SONG_LIST][CB] Get song list resource info callback, song name: %@, song id: %@, error: %@", songPlay.songName, songPlay.songID, error);
    complete(error);
  }];
}

- (void)downloadSongDataInBatchesWithSongPlays:(NSArray<GBSongPlay *> *)songPlays complete:(void(^)(NSError *error))complete {
  GB_LOG_D(@"[SONG_LIST] Download song data in batches, song count: %lu", (unsigned long)songPlays.count);
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    dispatch_group_t group = dispatch_group_create();
    __block NSError *error = nil;
    
    if ([[[GBUserAccount shared] getMyAuthority] canDownloadSong]) {
      dispatch_group_enter(group);
      [self downloadMediaResourceWithSongPlays:songPlays complete:^(NSError * err) {
        if (err) {
          error = err;
        }
        dispatch_group_leave(group);
      }];
    }
    
    if ([[[GBUserAccount shared] getMyAuthority] canDownloadLyric]) {
      dispatch_group_enter(group);
      [self downloadLyricInfoWithSongPlays:songPlays complete:^(NSError * err) {
        if (err) {
          error = err;
        }
        dispatch_group_leave(group);
      }];
    }
    
    if ([[[GBUserAccount shared] getMyAuthority] canDownloadPitch]) {
      dispatch_group_enter(group);
      [self downloadPitchInfoWithSongPlays:songPlays complete:^(NSError * err) {
        if (err) {
          error = err;
        }
        dispatch_group_leave(group);
      }];
    }
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
      GB_LOG_D(@"[SONG_LIST][CB] Download song data in batches, error: %@", error);
      complete(error);
    });
  });
}

- (void)downloadSongDataWithSongPlay:(GBSongPlay *)songPlay complete:(void (^)(NSError * _Nonnull))complete {
  [self downloadSongDataInBatchesWithSongPlays:@[songPlay] complete:complete];
}

#pragma mark - Private
- (void)downloadMediaResourceWithSongPlays:(NSArray<GBSongPlay *> *)songPlays complete:(void (^)(NSError * _Nullable))complete {
  GB_LOG_D(@"[SONG_LIST] Download media resource in batches, song count: %lu", (unsigned long)songPlays.count);
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    dispatch_group_t group = dispatch_group_create();
    __block NSError *err = nil;
    
    [songPlays enumerateObjectsUsingBlock:^(GBSongPlay * _Nonnull songPlay, NSUInteger idx, BOOL * _Nonnull stop) {
      dispatch_group_enter(group);
      
      GBSong *cacheSong = [self.resourceCache getSongBySongID:songPlay.songID];
      if (!cacheSong ||
          !(cacheSong.resourceID.length > 0) ||
          cacheSong.downloadState == GBSongDownloadStateDownloaded ||
          cacheSong.downloadState == GBSongDownloadStateDownloading) {
        dispatch_group_leave(group);
        return;
      }
      cacheSong.downloadState = GBSongDownloadStateDownloading;
      [[GBExpress shared] downloadResource:cacheSong.resourceID callback:^(NSError *error, CGFloat progress) {
        if (error) {
          err = error;
        }else {
          if (progress >= 1) {
            cacheSong.downloadState = GBSongDownloadStateDownloaded;
            dispatch_group_leave(group);
          }
        }
      }];
    }];
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
      GB_LOG_D(@"[SONG_LIST][CB] Download media resource in batches callback, error: %@", err);
      complete(err);
    });
  });
}

- (void)downloadLyricInfoWithSongPlays:(NSArray<GBSongPlay *> *)songPlays complete:(void (^)(NSError * _Nullable))complete {
  GB_LOG_D(@"[SONG_LIST] Download lyric info in batches, song count: %lu", (unsigned long)songPlays.count);
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    dispatch_group_t group = dispatch_group_create();
    __block NSError *err = nil;
    
    [songPlays enumerateObjectsUsingBlock:^(GBSongPlay * _Nonnull songPlay, NSUInteger idx, BOOL * _Nonnull stop) {
      dispatch_group_enter(group);
      GBSong *cacheSong = [self.resourceCache getSongBySongID:songPlay.songID];
      if (!cacheSong ||
          !(cacheSong.krcToken.length > 0) ||
          cacheSong.lyricJson) {
        dispatch_group_leave(group);
        return;
      }
      [[GBExpress shared] requestSongLyricWithKrcToken:cacheSong.krcToken complete:^(NSError * _Nonnull error, NSString * _Nonnull lyric) {
        if (error) {
          err = error;
        }else {
          cacheSong.lyricJson = lyric;
        }
        dispatch_group_leave(group);
      }];
    }];
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
      GB_LOG_D(@"[SONG_LIST][CB] Download lyric info in batches callback, error: %@", err);
      complete(err);
    });
  });
}

- (void)downloadPitchInfoWithSongPlays:(NSArray<GBSongPlay *> *)songPlays complete:(void (^)(NSError * _Nullable))complete {
  GB_LOG_D(@"[SONG_LIST] Download pitch info in batches, song count: %lu", (unsigned long)songPlays.count);
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    dispatch_group_t group = dispatch_group_create();
    __block NSError *err = nil;
    
    [songPlays enumerateObjectsUsingBlock:^(GBSongPlay * _Nonnull songPlay, NSUInteger idx, BOOL * _Nonnull stop) {
      dispatch_group_enter(group);
      GBSong *cacheSong = [self.resourceCache getSongBySongID:songPlay.songID];
      if (!cacheSong ||
          !(cacheSong.resourceID.length > 0) ||
          cacheSong.pitchJson) {
        dispatch_group_leave(group);
        return;
      }
      [[GBExpress shared] requestPitchWithResourceID:cacheSong.resourceID complete:^(NSError * _Nonnull error, NSString * _Nonnull pitchJson) {
        if (error) {
          err = error;
        }else {
          cacheSong.pitchJson = pitchJson;
        }
        dispatch_group_leave(group);
      }];
    }];
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
      GB_LOG_D(@"[SONG_LIST][CB] Download pitch info in batches callback, error: %@", err);
      complete(err);
    });
  });
}

@end
