//
//  GBSongResourceService.m
//  KTVGrab
//
//  Created by Vic on 2022/3/21.
//

#import "GBSongResourceProvider.h"
#import <YYKit/YYKit.h>
#import "GBSong.h"
#import "GBSongPlay.h"
#import "GBSongResourceCache.h"
#import "GBSongResourceDownloader.h"
#import "GBSEIModel.h"
#import "GBExpress.h"

@interface GBSongResourceProvider ()

@property (nonatomic, weak) id<GBSongResourceDownloadListener> listener;
@property (nonatomic, strong) GBSongResourceDownloader *resourceDownloader;
@property (nonatomic, strong) GBSongResourceCache *resourceCache;

@end

@implementation GBSongResourceProvider

- (instancetype)init {
  self = [super init];
  if (self) {
    _resourceCache = [[GBSongResourceCache alloc] init];
    _resourceDownloader = [[GBSongResourceDownloader alloc] initWithResourceCache:_resourceCache];
  }
  return self;
}

- (GBSong *)getSongBySongID:(NSString *)songID {
  return [self.resourceCache getSongBySongID:songID];
}

- (GBSongPlay *)getSongPlayBySongID:(NSString *)songID {
  return [self.resourceCache getSongPlayBySongID:songID];;
}

- (BOOL)validateSongWithSongID:(NSString *)songID {
  GBSong *song = [self getSongBySongID:songID];
  if (!song) {
    return NO;
  }
  if (![song validateIntegrity]) {
    return NO;
  };
  return YES;
}

- (BOOL)validateLyricWithSongID:(NSString *)songID {
  GBSong *song = [self getSongBySongID:songID];
  if (!song) {
    return NO;
  }
  return [song validateLyric];
}

- (void)prepareSongPlaysInBatches:(NSArray<GBSongPlay *> *)songPlays inRound:(NSUInteger)round {
  GB_LOG_D(@"[SONG_LIST] Prepare song list in batches, in round: %lu", (unsigned long)round);
  
  @weakify(self);
  [self.resourceDownloader getResourceInfoInBatchesWithSongPlays:songPlays complete:^(NSError * _Nonnull error, NSArray<GBSongPlay *> * _Nonnull songPlaysWithCR, NSArray<GBSongPlay *> * _Nonnull songPlaysWithoutCR) {
    @strongify(self);
    if (error) {
      [self.listener resourceProvider:self onPreparingCompleteInBatchesWithSongPlays:songPlaysWithCR invalidSongPlays:songPlaysWithoutCR inRound:round error:error];
      return;
    }
    [self.resourceDownloader downloadSongDataInBatchesWithSongPlays:songPlaysWithCR complete:^(NSError * _Nonnull error) {
      @strongify(self);
      [self.listener resourceProvider:self onPreparingCompleteInBatchesWithSongPlays:songPlaysWithCR invalidSongPlays:songPlaysWithoutCR inRound:round error:error];
    }];
  }];
}

- (void)prepareSongPlaysInSequence:(NSArray<GBSongPlay *> *)songPlays inRound:(NSUInteger)round {
  GB_LOG_D(@"[SONG_LIST] Prepare song list in sequence, in round: %lu", (unsigned long)round);
  [songPlays enumerateObjectsUsingBlock:^(GBSongPlay * _Nonnull songPlay, NSUInteger idx, BOOL * _Nonnull stop) {
    @weakify(self);
    [self.resourceDownloader getResourceInfoWithSongPlay:songPlay complete:^(NSError * _Nonnull error) {
      @strongify(self);
      if (error || !songPlay) {
        [self.listener resourceProvider:self onPreparingCompleteInSequenceWithSongPlay:songPlay inRound:round error:error];
        return;
      }
      [self.resourceDownloader downloadSongDataWithSongPlay:songPlay complete:^(NSError * _Nonnull error) {
        @strongify(self);
        [self.listener resourceProvider:self onPreparingCompleteInSequenceWithSongPlay:songPlay inRound:round error:error];
      }];
    }];
  }];
}

#pragma mark - GBRoomUserSEIListener
- (void)userService:(GBRoomUserService *)service onReceiveSEI:(GBSEIModel *)model {
  [self.resourceCache updateSongDuration:model.duration forSongID:model.songID];
}

@end
