//
//  ZGKTVSongBasicInfoView.m
//  GoChat
//
//  Created by Vic on 2021/12/5.
//  Copyright © 2021 zego. All rights reserved.
//

#import "GBSongInfoView.h"
#import <Masonry/Masonry.h>
#import "GBImage.h"
#import "GBSong.h"

@interface GBSongInfoView ()

@property (nonatomic, strong) UIImageView *noteImageView;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UILabel *songNameLabel;
@property (nonatomic, strong) UILabel *progressLabel;

@property (nonatomic, copy) NSString *durationString;
@property (nonatomic, copy) NSString *progressString;

@property (nonatomic, assign) NSInteger duration;

@end

@implementation GBSongInfoView

- (instancetype)init {
  self = [super init];
  if (self) {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self reset];
  }
  return self;
}

- (void)updateConstraints {
  [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.right.top.equalTo(self);
    make.bottom.equalTo(self);
  }];
  
  [self.noteImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.width.height.mas_equalTo(10);
    make.right.equalTo(self.stackView.mas_left).inset(7.5);
    make.left.equalTo(self);
    make.centerY.equalTo(self.songNameLabel);
  }];
  
  [super updateConstraints];
}

- (UIImageView *)noteImageView {
  if (!_noteImageView) {
    _noteImageView = [[UIImageView alloc] init];
    _noteImageView.contentMode = UIViewContentModeScaleAspectFit;
    _noteImageView.image = [GBImage imageNamed:@"gb_info_bar_note"];
    [self addSubview:_noteImageView];
  }
  return _noteImageView;
}

- (UILabel *)songNameLabel {
  if (!_songNameLabel) {
    _songNameLabel = [[UILabel alloc] init];
    _songNameLabel.textColor = [UIColor whiteColor];
    _songNameLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:_songNameLabel];
  }
  return _songNameLabel;
}

- (UILabel *)progressLabel {
  if (!_progressLabel) {
    _progressLabel = [[UILabel alloc] init];
    _progressLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
    _progressLabel.font = [UIFont systemFontOfSize:10];
    [self addSubview:_progressLabel];
  }
  return _progressLabel;
}

- (UIStackView *)stackView {
  if (!_stackView) {
    _stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.songNameLabel, self.progressLabel]];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.spacing = 1;
    [self addSubview:_stackView];
  }
  return _stackView;
}

#pragma mark - Public
- (void)setProgressVisible:(BOOL)progressVisible {
  _progressVisible = progressVisible;
  self.progressLabel.hidden = !progressVisible;
}

- (void)setProgress:(NSInteger)progress {
  if (progress > self.duration) {
    return;
  }
  _progress = progress;
  NSString *string = [self stringFromMilliseconds:progress];
  self.progressString = string;
  [self setProgressWithProgressString:string durationString:self.durationString];
}

- (void)setDuration:(NSInteger)duration {
  if (_duration == duration) {
    return;
  }
  _duration = duration;
  NSString *string = [self stringFromMilliseconds:duration];
  self.durationString = string;
  [self setProgressWithProgressString:self.progressString durationString:string];
}

- (void)setSong:(GBSong *)song {
  _song = song;
  [self setSongName:song.songName singerName:song.singerName];
  [self setDuration:song.duration];
}

#pragma mark - Private
- (void)setSongName:(NSString *)songName singerName:(NSString *)singerName {
  songName = songName ?: @"";
  singerName = singerName ?: @"";
  self.songNameLabel.text = [NSString stringWithFormat:@"%@《%@》", singerName, songName];
}

- (void)setProgressWithProgressString:(NSString *)progressString durationString:(NSString *)durationString {
  self.progressLabel.text = [NSString stringWithFormat:@"%@ / %@", progressString, durationString];
}

- (NSString *)stringFromMilliseconds:(NSInteger)milliSeconds {
  NSInteger second = milliSeconds / 1000;
  return [self stringFromSeconds:second];;
}

- (NSString *)stringFromSeconds:(NSInteger)totalSec {
  NSInteger minute = totalSec / 60;
  NSInteger second = totalSec - minute * 60;
  
  NSString *minuteStr = [NSString stringWithFormat:@"%ld", minute];
  if (minute < 10) {
    minuteStr = [NSString stringWithFormat:@"0%ld", minute];
  }
  
  NSString *secondStr = [NSString stringWithFormat:@"%ld", second];
  if (second < 10) {
    secondStr = [NSString stringWithFormat:@"0%ld", second];
  }
  
  NSString *ret = [NSString stringWithFormat:@"%@:%@", minuteStr, secondStr];
  return ret;
}

- (void)reset {
  self.progressString = @"00:00";
  self.durationString = @"00:00";
  self.progress = 0;
  self.duration = 0;
}

@end
