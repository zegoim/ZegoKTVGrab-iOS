//
//  GBLyricAndPitchContainer.m
//  AFNetworking
//
//  Created by Vic on 2022/3/22.
//

#import "GBLyricAndPitchContainer.h"
#import <ZegoLyricView/ZegoLyricView.h>
#import <ZegoPitchView/ZegoPitchView.h>
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>
#import "GBExpress.h"
#import "GBSong.h"

@interface GBLyricAndPitchContainer ()<ZegoLyricViewProtocol>

@property (nonatomic, strong) ZegoLyricView *lyricView;
@property (nonatomic, strong) ZegoPitchView *pitchView;
@property (nonatomic, strong) GBSong *curSong;
@property (nonatomic, strong) ZegoLyricModel *lyricModel;

@end


@implementation GBLyricAndPitchContainer

- (instancetype)init {
  self = [super init];
  if (self) {
    _pitchViewVisible = YES;
    self.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return self;
}

- (void)setSong:(GBSong *)song {
  _curSong = song;
  [self setupLyric:song.lyricJson];
  [self setupPitch:song.pitchJson];
}

- (void)setupLyric:(NSString *)lyric {
  ZegoLyricModel *lyricModel = [ZegoLyricModel analyzeLyricData:lyric trim:NO];
  self.lyricModel = lyricModel;
  [self.lyricView setupMusicDataSource:lyricModel beginTime:self.curSong.segBegin + self.curSong.preludeDuration endTime:self.curSong.segEnd];
}

- (void)setupPitch:(NSString *)pitch {
  if (!pitch) {
    return;
  }
  NSInteger beginTime = self.curSong.segBegin + self.curSong.preludeDuration;
  NSInteger endTime = self.curSong.segEnd;
  
  NSArray *pitchModels = [ZegoPitchModel analyzePitchData:pitch beginTime:beginTime endTime:endTime krcFormatOffset:self.lyricModel.krcFormatOffset];

  GB_LOG_D(@"[SCORE] Pitch models: %ld", pitchModels.count);
  
  [self.pitchView setStandardPitchModels:pitchModels];
}

- (void)reset {
//  [self.lyricView reset];
}

- (void)setProgress:(NSInteger)progress pitch:(int)pitch {
  [self.lyricView setProgress:progress];
  [self.pitchView setCurrentSongProgress:(int)progress pitch:pitch];
}

- (void)setPitchViewVisible:(BOOL)pitchViewVisible {
  if (_pitchViewVisible == pitchViewVisible) {
    return;
  }
  _pitchViewVisible = pitchViewVisible;
  if (!pitchViewVisible) {
    [self.pitchView setStandardPitchModels:nil];
  }
  [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
  if (self.pitchViewVisible) {
    self.pitchView.hidden = NO;
    [self.pitchView mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.top.left.right.equalTo(self);
      make.height.mas_equalTo(70);
    }];
    
    [self.lyricView mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.pitchView.mas_bottom).offset(8);
      make.left.right.bottom.equalTo(self);
    }];
  }
  else {
    self.pitchView.hidden = YES;
    [self.lyricView mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.height.mas_equalTo(50);
      make.left.right.equalTo(self);
      make.centerY.equalTo(self);
    }];
  }
  
  [super updateConstraints];
}

- (ZegoLyricView *)lyricView {
  if (!_lyricView) {
    ZegoLyricViewConfig *config = [ZegoLyricViewConfig new];
    config.playingFont = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
    config.playingColor = UIColorHex(0xFF3571);
    config.normalColor = [UIColor whiteColor];
    
    ZegoLyricView *view = [[ZegoLyricView alloc] initWithFrame:CGRectZero config:config];
    view.lyricDelegate = self;
    view.separatorStyle = UITableViewCellSeparatorStyleNone;
    view.backgroundColor = [UIColor clearColor];
    view.userInteractionEnabled = NO;
    view.tableFooterView = [[UIView alloc] init];
    [self addSubview:view];
    _lyricView = view;
  }
  return _lyricView;
}

- (ZegoPitchView *)pitchView {
  if (!_pitchView) {
    ZegoPitchView *view = [[ZegoPitchView alloc] init];
    [view setConfig:[ZegoPitchViewConfig defaultConfig]];
    [self addSubview:view];
    _pitchView = view;
  }
  return _pitchView;
}

#pragma mark - Protocol
- (void)lyricView:(ZegoLyricView *)lyricView didFinishLineWithModel:(ZegoLyricLineModel *)lineModel lineIndex:(NSInteger)index {
  int score = [[GBExpress shared] getPrevScore:self.curSong.resourceID];
  [self.pitchView addScore:score];
}

@end
