//
//  GBSeatPlaceView.m
//  KTVGrab
//
//  Created by Vic on 2022/3/25.
//

#import "GBSeatAvatarContainerView.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>

#import "GBSeatBackgroundView.h"
#import "GBSeatMicOffMask.h"
#import "GBSoundLevelView.h"
#import "GBSeatAvatarView.h"


@interface GBSeatAvatarContainerView ()

@property (nonatomic, strong) GBSeatBackgroundView *bgView;
@property (nonatomic, strong) GBSeatAvatarView *avatarView;
@property (nonatomic, strong) GBSeatMicOffMask *micOffMask;
@property (nonatomic, strong) GBSoundLevelView *soundLevelView;

@end

@implementation GBSeatAvatarContainerView

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
  [self addSubview:self.bgView];
  [self addSubview:self.avatarView];
  [self addSubview:self.micOffMask];
  [self addSubview:self.soundLevelView];
}

- (void)updateConstraints {
  [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.width.height.mas_equalTo(50);
    make.center.equalTo(self);
  }];

  [self.avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.bgView).insets(UIEdgeInsetsMake(2, 2, 2, 2));
  }];

  [self.micOffMask mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.bgView);
  }];

  [self.soundLevelView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.top.bottom.equalTo(self);
    make.center.equalTo(self.bgView);
  }];
  
  [super updateConstraints];
}

- (GBSeatBackgroundView *)bgView {
  if (!_bgView) {
    _bgView = [[GBSeatBackgroundView alloc] init];
  }
  return _bgView;
}

- (GBSeatAvatarView *)avatarView {
  if (!_avatarView) {
    _avatarView = [[GBSeatAvatarView alloc] init];
  }
  return _avatarView;
}

- (GBSeatMicOffMask *)micOffMask {
  if (!_micOffMask) {
    _micOffMask = [[GBSeatMicOffMask alloc] init];
  }
  return _micOffMask;
}

- (GBSoundLevelView *)soundLevelView {
  if (!_soundLevelView) {
    _soundLevelView = [[GBSoundLevelView alloc] init];
    [_soundLevelView setInnerRadius:25];
    _soundLevelView.hidden = YES;
  }
  return _soundLevelView;
}

#pragma mark -
- (void)setAvatarURLString:(NSString *)urlString {
  [self.avatarView setAvatarURLString:urlString];
}

- (void)setSoundLevel:(CGFloat)soundLevel {
  [self.soundLevelView setSoundLevel:soundLevel];
}

- (void)setMute:(BOOL)mute {
  if (mute) {
    self.micOffMask.hidden = NO;
    [self.bgView setPlusVisible:NO];
    self.soundLevelView.hidden = YES;
  }else {
    self.micOffMask.hidden = YES;
    [self.bgView setPlusVisible:YES];
    self.soundLevelView.hidden = NO;
  }
}

- (void)setCellVM:(GBSeatCellVM *)cellVM {
  _cellVM = cellVM;
  if (cellVM.empty) {
    self.micOffMask.hidden = YES;
    [self.bgView setPlusVisible:YES];
    self.avatarView.hidden = YES;
    self.soundLevelView.hidden = YES;
  }else {
    self.micOffMask.hidden = NO;
    [self.bgView setPlusVisible:NO];
    self.avatarView.hidden = NO;
    self.soundLevelView.hidden = NO;
    
    [self setMute:cellVM.mute];
    [self setAvatarURLString:cellVM.avatarURLString];
    [self setSoundLevel:cellVM.soundLevel];
  }
}

@end
