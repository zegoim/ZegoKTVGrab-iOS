//
//  GBBoardContainerView.m
//  KTVGrab
//
//  Created by Vic on 2022/2/22.
//

#import "GBBoardContainerView.h"
#import "GBGameWaitingView.h"
#import "GBGameInfoBarView.h"
#import "GBPureImageBoard.h"
#import "GBPureTextBoard.h"
#import "GBUserGrabbedInfoView.h"
#import "GBChallengeResultBoard.h"
#import "GBLyricAndPitchContainer.h"
#import <KTVGrab/KTVGrab-Swift.h>

#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>
#import "NSBundle+KTVGrab.h"
#import "GBImage.h"
#import "GBSong.h"
#import "GBUser.h"
#import "GBRoomInfo.h"

#import "GBRoomManager.h"

@interface GBBoardContainerView ()

@property (nonatomic, strong) GBRoomInfo *roomInfo;
@property (nonatomic, strong) GBSong *song;
@property (nonatomic, assign) BOOL checkSong; //TODO: 从代码架构角度检查是否需要这个参数, 因为已经有了 curSong, 可以自己判断.
@property (nonatomic, strong) GBUser *grabUser;

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) GBLottieView *soundwaveEffectView;
@property (nonatomic, strong) GBGameInfoBarView *barView;
@property (nonatomic, strong) GBGameWaitingView *waitingView;
@property (nonatomic, strong) GBPureImageBoard *imageBoard;
@property (nonatomic, strong) GBPureTextBoard *textBoard;
@property (nonatomic, strong) GBUserGrabbedInfoView *userGrabbedView;
@property (nonatomic, strong) GBChallengeResultBoard *challengeResultBoard;
@property (nonatomic, strong) GBLyricAndPitchContainer *lyricPitchContainer;

@property (nonatomic, assign) BOOL pitchViewVisible;

@end

@implementation GBBoardContainerView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  [self setupSubviews];
}

- (void)setupSubviews {
  [self addSubview:self.bgImageView];
  [self addSubview:self.soundwaveEffectView];
  [self addSubview:self.userGrabbedView];
  [self addSubview:self.textBoard];
  [self addSubview:self.imageBoard];
  [self addSubview:self.lyricPitchContainer];
  [self addSubview:self.challengeResultBoard];
  [self addSubview:self.waitingView];
  [self addSubview:self.barView];
}

- (void)layoutSubviews {
  
  UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);
  
  [self.bgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self);
  }];

  [self.soundwaveEffectView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.bgImageView).insets(padding);
  }];
  
  [self.waitingView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.bgImageView).insets(padding);
  }];

  [self.userGrabbedView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.bgImageView).insets(padding);
  }];

  [self.textBoard mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.bgImageView).insets(padding);
  }];

  [self.imageBoard mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.bgImageView).insets(padding);
  }];

  [self.barView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self).offset(24);
    make.right.equalTo(self).inset(24);
    make.top.equalTo(self).offset(31);
  }];
  
  [self.lyricPitchContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
    if (self.pitchViewVisible) {
      make.top.equalTo(self.barView.mas_bottom).offset(15);
    }else {
      make.centerY.equalTo(self);
    }
    make.left.equalTo(self).offset(12);
    make.right.equalTo(self).inset(12);
    make.bottom.equalTo(self).inset(20);
  }];
  
  [self.challengeResultBoard mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.bgImageView).insets(padding);
  }];

  [self layoutSubviewsByRoomInfo:self.roomInfo checkSong:self.checkSong];
}

- (void)layoutSubviewsByRoomInfo:(GBRoomInfo *)roomInfo checkSong:(BOOL)checkSong {
  BOOL hasLyric = [[GBRoomManager shared].runningRoomService.songResourceProvider validateLyricWithSongID:self.song.songID];
  
  [self hideAll];
  [self setIndex:roomInfo.curSongIndex];
  [self setTotalCount:roomInfo.songsThisRound];
  [self.soundwaveEffectView stop];
  [self.barView setSong:self.song];
  
  switch (roomInfo.roomState) {
    case GBRoomStateUnknown:
      break;
      
    case GBRoomStateGameWaiting:
    {
      [self showWaitingView];
    }
      break;
      
    case GBRoomStateRoundPreparing:
    {
      [self showGameStartPrompt];
    }
      break;
      
    case GBRoomStateGrabWaiting:
    {
      //展示歌词等信息
      if (hasLyric) {
        [self setPitchViewVisible:NO];
        self.lyricPitchContainer.hidden = NO;
      }
      [self.lyricPitchContainer setSong:self.song];
      [self showComingSoon:!hasLyric];
      self.barView.hidden = NO;
      [self.barView setProgressVisible:NO];
      [self.soundwaveEffectView play];
    }
      break;
      
    case GBRoomStateGrabSuccessfully:
    {
      //展示某人成功抢到
      self.userGrabbedView.hidden = NO;
      self.barView.hidden = NO;
      [self.barView setProgressVisible:NO];
    }
      break;
      
    case GBRoomStateGrabUnsuccessfully:
    {
      [self noOneGrabbed];
    }
      break;
      
    case GBRoomStateSinging:
    {
      if (checkSong) {
        self.lyricPitchContainer.hidden = NO;
      }
      [self.soundwaveEffectView play];
      //展示歌词等信息
      [self.barView setProgressVisible:YES];
      self.barView.hidden = NO;
      [self.lyricPitchContainer setSong:self.song];
      if ([self.grabUser.userID isEqualToString:self.myself.userID]) {
        /**
         * 自己抢到了歌, 需要判定歌曲所有资源是否准备完毕
         */
        [self setPitchViewVisible:YES];
        [self showComingSoon:!checkSong];
      }else {
        [self setPitchViewVisible:NO];
        [self showComingSoon:!hasLyric];
      }
    }
      break;
      
    case GBRoomStateAIScoring:
    {
      [self showAIScoringView];
      break;
    }
      
    case GBRoomStateSongEnd:
    {
      [self showSingleChallengeResult];
    }
      break;
      
    case GBRoomStateRoundEnd:
    {
      [self showWaitingView];
    }
      break;
      
    case GBRoomStateNextSongPreparing:
    {
      [self showNextSong];
    }
      break;
      
    case GBRoomStateRoomExit:
    {
      
    }
      break;
  }
}

- (void)hideAll {
  self.waitingView.hidden = YES;
  self.userGrabbedView.hidden = YES;
  self.textBoard.hidden = YES;
  self.imageBoard.hidden = YES;
  self.barView.hidden = YES;
  self.challengeResultBoard.hidden = YES;
  self.lyricPitchContainer.hidden = YES;
  
  [self.lyricPitchContainer reset];
}

- (void)showComingSoon:(BOOL)visible {
  if (visible) {
    [self.barView setProgressVisible:NO];
  }
  self.textBoard.hidden = !visible;
  [self.textBoard setText:self.song.songName descText:@"即将播放"];
}

- (void)showWaitingView {
  self.waitingView.hidden = NO;
  self.waitingView.role = self.myself.roleType;
}

- (void)showGameStartPrompt {
  self.imageBoard.hidden = NO;
  [self.imageBoard setImage:[GBImage imageNamed:@"gb_info_board_text_game_start"]];
}

- (void)noOneGrabbed {
  self.imageBoard.hidden = NO;
  [self.imageBoard setImage:[GBImage imageNamed:@"gb_info_board_not_grabbed"]];
}

- (void)showNextSong {
  self.imageBoard.hidden = NO;
  [self.imageBoard setImage:[GBImage imageNamed:@"gb_info_board_text_next_song"]];
}

- (void)showSingleChallengeResult {
  self.challengeResultBoard.hidden = NO;
  [self.challengeResultBoard setChallengeResult:self.roomInfo.isSingerPass];
  [self.challengeResultBoard setChallengeScore:self.roomInfo.singScore];
}

- (void)showAIScoringView {
  self.imageBoard.hidden = NO;
  UIImage *imageName = [GBImage imageNamed:@"gb_info_board_text_ai"];
  [self.imageBoard setImage:imageName descText:@"演唱结束"];
}

- (void)hideAIIdentifying {
  self.imageBoard.hidden = YES;
}

#pragma mark - Setter & Getter
- (void)setPitchViewVisible:(BOOL)pitchViewVisible {
  _pitchViewVisible = pitchViewVisible;
  self.lyricPitchContainer.pitchViewVisible = pitchViewVisible;
  [self setNeedsLayout];
}

- (GBGameWaitingView *)waitingView {
  if (!_waitingView) {
    _waitingView = [[GBGameWaitingView alloc] init];
    
    @weakify(self);
    _waitingView.onClickStartGameButton = ^{
      @strongify(self);
      self.onClickStartGameButton();
    };
  }
  return _waitingView;
}

- (UIImageView *)bgImageView {
  if (!_bgImageView) {
    _bgImageView = [[UIImageView alloc] init];
    _bgImageView.contentMode = UIViewContentModeScaleAspectFit;
    _bgImageView.image = [GBImage imageNamed:@"gb_info_board_bg_border"];
  }
  return _bgImageView;
}

- (GBGameInfoBarView *)barView {
  if (!_barView) {
    _barView = [[GBGameInfoBarView alloc] init];
  }
  return _barView;
}

- (GBPureImageBoard *)imageBoard {
  if (!_imageBoard) {
    _imageBoard = [[GBPureImageBoard alloc] init];
  }
  return _imageBoard;
}

- (GBPureTextBoard *)textBoard {
  if (!_textBoard) {
    _textBoard = [[GBPureTextBoard alloc] init];
  }
  return _textBoard;
}

- (GBUserGrabbedInfoView *)userGrabbedView {
  if (!_userGrabbedView) {
    _userGrabbedView = [[GBUserGrabbedInfoView alloc] init];
  }
  return _userGrabbedView;
}

- (GBChallengeResultBoard *)challengeResultBoard {
  if (!_challengeResultBoard) {
    _challengeResultBoard = [[GBChallengeResultBoard alloc] init];
  }
  return _challengeResultBoard;
}

- (GBLyricAndPitchContainer *)lyricPitchContainer {
  if (!_lyricPitchContainer) {
    _lyricPitchContainer = [[GBLyricAndPitchContainer alloc] init];
  }
  return _lyricPitchContainer;
}

- (GBLottieView *)soundwaveEffectView {
  if (!_soundwaveEffectView) {
    GBLottieView *view = [[GBLottieView alloc] init];
    [view namedWithName:@"yinlang" bundle:[NSBundle GB_bundle]];
    _soundwaveEffectView = view;
  }
  return _soundwaveEffectView;
}

#pragma mark - Public
- (void)setRoomInfo:(GBRoomInfo *)roomInfo checkSong:(BOOL)checkSong {
  _roomInfo = roomInfo;
  _checkSong = checkSong;
  [self layoutSubviewsByRoomInfo:roomInfo checkSong:checkSong];
}

//- (void)setSong:(GBSong *)song {
//  _song = song;
//  if (!song) {
//    return;
//  }
//  [self.lyricPitchContainer setSong:song];
//  [self.barView setSong:song];
//}

- (void)setGrabUser:(GBUser *)user {
  _grabUser = user;
  [self.userGrabbedView setGrabUser:user];
}

- (void)setIndex:(NSInteger)index {
  [self.barView setIndex:index];
}

- (void)setTotalCount:(NSInteger)totalCount {
  [self.barView setTotalCount:totalCount];
}

- (void)setProgress:(NSInteger)progress pitch:(int)pitch {
  [self.barView setProgress:progress];
  [self.lyricPitchContainer setProgress:progress + self.song.segBegin pitch:pitch];
}

@end
