//
//  GBRoundResultView.m
//  KTVGrab
//
//  Created by Vic on 2022/3/17.
//

#import "GBRoundResultView.h"

//View
#import "GBResultContentView.h"
#import "GoGradientButton.h"

//Util
#import "GBImage.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>

//Model
#import "GBRoundGrade.h"
#import "GBUser.h"

@interface GBRoundResultView ()

/// 背景
@property (nonatomic, strong) UIView *bgView;

/// "我的战绩"图片
@property (nonatomic, strong) UIImageView *titleImageView;

/// 战绩内容
@property (nonatomic, strong) GBResultContentView *resultContentView;

/// 用于管理按钮布局的 StackView
@property (nonatomic, strong) UIStackView *buttonStackView;

/// 再来一局按钮
@property (nonatomic, strong) GoGradientButton *anotherRoundButton;

/// 退出房间按钮
@property (nonatomic, strong) GoGradientButton *leaveRoomButton;

/// 底部描述文本
@property (nonatomic, copy) NSString *descText;

@end


@implementation GBRoundResultView

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
  [self addSubview:self.bgView];
  [self addSubview:self.resultContentView];
  [self addSubview:self.titleImageView];
  [self addSubview:self.buttonStackView];
}

- (void)updateConstraints {
  
  if (self.spectatorMode) {
    self.titleImageView.image = [GBImage imageNamed:@"gb_round_end_rule_deco"];
  }else {
    self.titleImageView.image = [GBImage imageNamed:@"gb_round_end_result_deco"];
  }
  
  [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self);
  }];
  
  [self.resultContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self).offset(30);
    make.centerX.equalTo(self);
    make.top.equalTo(self).offset(130);
//    make.height.mas_equalTo(self.descText.length > 0 ? 341 : 305);
  }];
  
  [self.titleImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self);
    make.bottom.equalTo(self.resultContentView.mas_top).offset(30);
  }];

  [self.buttonStackView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.resultContentView.mas_bottom).offset(35);
    make.height.mas_equalTo(44);
    make.centerX.equalTo(self);
  }];
  
  [self.anotherRoundButton mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.height.mas_equalTo(44);
  }];
  
  [self.leaveRoomButton mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.height.mas_equalTo(44);
  }];
  
  if (self.user.roleType == GBUserRoleTypeHost && self.hasAnotherRound) {
    self.anotherRoundButton.hidden = NO;
    [self setButtonGradientGray:self.leaveRoomButton];
    [self.buttonStackView mas_updateConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self).offset(44);
    }];
    
  }else {
    self.anotherRoundButton.hidden = YES;
    [self setButtonGradientRed:self.leaveRoomButton];
    [self.buttonStackView mas_updateConstraints:^(MASConstraintMaker *make) {
      make.width.mas_equalTo(133.5);
    }];
  }
  
  [super updateConstraints];
}

#pragma mark - View
- (UIView *)bgView {
  if (!_bgView) {
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor colorWithHexString:@"#06021AFF"];
  }
  return _bgView;
}

- (UIImageView *)titleImageView {
  if (!_titleImageView) {
    _titleImageView = [[UIImageView alloc] init];
    _titleImageView.image = [GBImage imageNamed:@"gb_round_end_result_deco"];
    _titleImageView.contentMode = UIViewContentModeScaleAspectFit;
  }
  return _titleImageView;
}

- (UIStackView *)buttonStackView {
  if (!_buttonStackView) {
    _buttonStackView = [[UIStackView alloc] initWithArrangedSubviews:@[
      self.anotherRoundButton,
      self.leaveRoomButton
    ]];
    _buttonStackView.alignment = UIStackViewAlignmentCenter;
    _buttonStackView.spacing = 16;
    _buttonStackView.distribution = UIStackViewDistributionFillEqually;
  }
  return _buttonStackView;
}

- (GBResultContentView *)resultContentView {
  if (!_resultContentView) {
    _resultContentView = [[GBResultContentView alloc] init];
    _resultContentView.layer.cornerRadius = 16;
    _resultContentView.layer.masksToBounds = YES;
  }
  return _resultContentView;
}

- (GoGradientButton *)anotherRoundButton {
  if (!_anotherRoundButton) {
    GoGradientButton *btn = [[GoGradientButton alloc] init];
    btn.layer.cornerRadius = 22;
    btn.layer.masksToBounds = YES;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"再来一局" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(anotherRoundAction) forControlEvents:UIControlEventTouchUpInside];
    _anotherRoundButton = btn;
  }
  return _anotherRoundButton;
}

- (GoGradientButton *)leaveRoomButton {
  if (!_leaveRoomButton) {
    GoGradientButton *btn = [[GoGradientButton alloc] init];
    btn.layer.cornerRadius = 22;
    btn.layer.masksToBounds = YES;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"退出房间" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(leaveRoomAction) forControlEvents:UIControlEventTouchUpInside];
    _leaveRoomButton = btn;
  }
  return _leaveRoomButton;
}

#pragma mark - Action
- (void)anotherRoundAction {
  if (self.onClickAnotherRound) {
    self.onClickAnotherRound();
  }
}

- (void)leaveRoomAction {
  if (self.onClickLeaveRoom) {
    self.onClickLeaveRoom();
  }
}

#pragma mark - Setter & Getter
- (void)setSpectatorMode:(BOOL)spectatorMode {
  _spectatorMode = spectatorMode;
  self.resultContentView.spectatorMode = spectatorMode;
}

- (void)setGrade:(GBRoundGrade *)grade {
  _grade = grade;
  self.resultContentView.grade = grade;
}

- (void)setUser:(GBUser *)user {
  _user = user;
  self.resultContentView.user = user;
  [self setNeedsUpdateConstraints];
}

- (void)setHasAnotherRound:(BOOL)hasAnotherRound {
  _hasAnotherRound = hasAnotherRound;
  [self setNeedsUpdateConstraints];
}

- (void)setText:(NSString *)text {
  _descText = text;
  [self.resultContentView setText:text];
  [self setNeedsUpdateConstraints];
}

- (void)setButtonGradientGray:(GoGradientButton *)button {
  button.beginColor = [UIColor colorWithHexString:@"#FFFFFF1A"];
  button.endColor = [UIColor colorWithHexString:@"#FFFFFF1A"];
}

- (void)setButtonGradientRed:(GoGradientButton *)button {
  button.beginColor = [UIColor colorWithHexString:@"#FF5940FF"];
  button.endColor = [UIColor colorWithHexString:@"#FF3772FF"];
}
  
@end
