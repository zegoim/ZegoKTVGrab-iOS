//
//  GBMediaPlayer.m
//  KTVGrab
//
//  Created by Vic on 2022/3/22.
//

#import "GBMediaPlayer.h"
#import "GBExpress.h"
#import "GBSong.h"
#import <YYKit/YYKit.h>

@interface GBMediaPlayer ()<GBRTCMediaEventListener>

@property (nonatomic, strong) NSPointerArray *eventListeners;
@property (nonatomic,  weak ) id<GBMediaPlayerProgressListener> progressListener;
@property (nonatomic,  weak ) id<GBSongScoreEventListener> scoreEventListener;
@property (nonatomic, strong) GBSong *curPlayingSong;

@end

@implementation GBMediaPlayer

- (void)dealloc {
  GB_LOG_D(@"[DEALLOC]%@ dealloc", NSStringFromClass(self.class));
  [self stopPlaying];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _eventListeners = [NSPointerArray weakObjectsPointerArray];
    [[GBExpress shared] setMediaEventListener:self];
  }
  return self;
}

- (void)appendEventListener:(id<GBMediaPlayerStateListener>)listener {
  [self.eventListeners addPointer:(__bridge void * _Nullable)(listener)];
}

- (void)startPlayingSong:(GBSong *)song prelude:(int)preludeMs {
  self.curPlayingSong = song;
  
  NSInteger climaxStart = song.preludeDuration;
  climaxStart = MAX(climaxStart - preludeMs, 0);
  [[GBExpress shared] startPlayingCopyrightResource:song.resourceID atProgress:climaxStart];
}

- (void)stopPlaying {
  [[GBExpress shared] stopPlayingMedia];
}

- (void)setSoundTrackAsOriginal:(BOOL)original {
  [[GBExpress shared] setAudioTrackAsOriginal:original];
}

#pragma mark -
- (void)onMediaPlayerProgressUpdate:(NSInteger)progress {
  [self.progressListener mediaPlayer:self onProgressUpdate:progress];
}

- (void)onMediaPlayerStateUpdate:(ZegoMediaPlayerState)state {
  for (id<GBMediaPlayerStateListener> listener in self.eventListeners) {
    [listener mediaPlayer:self onStateUpdate:(GBMediaPlayerState)state playingSong:self.curPlayingSong];
  }
}

- (void)onCopyrightSongResource:(NSString *)resourceID pitchUpdate:(int)pitch atProgress:(NSInteger)progress {
  if (![resourceID isEqualToString:self.curPlayingSong.resourceID]) {
    return;
  }
  [self.scoreEventListener mediaPlayer:self onSong:self.curPlayingSong pitchUpdate:pitch atProgress:progress];
}

@end
