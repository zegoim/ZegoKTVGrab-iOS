//
//  GBGameInfoBarView.m
//  KTVGrab
//
//  Created by Vic on 2022/2/22.
//

#import "GBGameInfoBarView.h"
#import "GBGameRoundInfoView.h"
#import "GBSongInfoView.h"
#import <Masonry/Masonry.h>
#import "GBSong.h"

@interface GBGameInfoBarView ()

@property (nonatomic, strong) GBSongInfoView *songInfoView;
@property (nonatomic, strong) GBGameRoundInfoView *roundInfoView;

@end

@implementation GBGameInfoBarView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  self.translatesAutoresizingMaskIntoConstraints = NO;
  [self setupSubviews];
}

- (void)setupSubviews {
  
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  [self.roundInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self);
    make.right.equalTo(self);
    make.size.mas_equalTo(CGSizeMake(40, 22));
    make.centerY.equalTo(self);
  }];
  
  [self.songInfoView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self);
    make.centerY.equalTo(self);
    make.right.lessThanOrEqualTo(self.roundInfoView.mas_left).inset(10);
  }];
}

- (GBSongInfoView *)songInfoView {
  if (!_songInfoView) {
    _songInfoView = [[GBSongInfoView alloc] init];
    [self addSubview:_songInfoView];
  }
  return _songInfoView;
}

- (GBGameRoundInfoView *)roundInfoView {
  if (!_roundInfoView) {
    _roundInfoView = [[GBGameRoundInfoView alloc] init];
    [self addSubview:_roundInfoView];
  }
  return _roundInfoView;
}

#pragma mark - Public
- (void)setIndex:(NSInteger)index {
  self.roundInfoView.index = index;
}

- (void)setTotalCount:(NSInteger)totalCount {
  self.roundInfoView.totalCount = totalCount;
}

- (void)setProgress:(NSInteger)progress {
  self.songInfoView.progress = progress;
}

- (void)setProgressVisible:(BOOL)visible {
  self.songInfoView.progressVisible = visible;
}

- (void)setSong:(GBSong *)song {
  [self.songInfoView setSong:song];
}

@end
