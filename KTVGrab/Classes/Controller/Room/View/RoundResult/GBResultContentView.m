//
//  GBResultContentView.m
//  KTVGrab
//
//  Created by Vic on 2022/3/17.
//

#import "GBResultContentView.h"
#import "GBRoundGradeView.h"
#import "GBRingImageView.h"
#import "GBRoundResultRuleView.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>
#import "GBUser.h"

@interface GBResultContentView ()

/// 背景
@property (nonatomic, strong) CAGradientLayer *bgLayer;

/// 用户头像
@property (nonatomic, strong) GBRingImageView *avatarImageView;

/// 用户名
@property (nonatomic, strong) UILabel *userNameLabel;

/// 战绩
@property (nonatomic, strong) GBRoundGradeView *gradeView;

/// 未参与游戏的没有分数, 仅展示抢唱规则
@property (nonatomic, strong) GBRoundResultRuleView *ruleView;

/// 描述文字
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation GBResultContentView


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
  [self.layer insertSublayer:self.bgLayer atIndex:0];
  [self addSubview:self.avatarImageView];
  [self addSubview:self.userNameLabel];
  [self addSubview:self.gradeView];
  [self addSubview:self.textLabel];
  [self addSubview:self.ruleView];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.bgLayer.frame = self.bounds;
}

- (void)updateConstraints {
  
  BOOL textLabelVisible = self.textLabel.text.length > 0;
  
  BOOL gradeVisible = ({
    BOOL visible = YES;
    if (self.spectatorMode) {
      visible = NO;
    }else {
      if ([[GBUserAccount shared] getMyAuthority].canSeeRoundGrade) {
        visible = YES;
      }else {
        visible = NO;
      }
    }
    visible;
  });
  
  BOOL ruleViewVisible = ({
    BOOL visible = NO;
    if (self.spectatorMode) {
      visible = YES;
    }
    visible;
  });
  
  BOOL avatarVisible = ({
    BOOL visible = YES;
    if (self.spectatorMode) {
      visible = NO;
    }
    visible;
  });
  
  BOOL userNameVisible = avatarVisible;
  
  self.gradeView.hidden = !gradeVisible;
  self.ruleView.hidden = !ruleViewVisible;
  self.avatarImageView.hidden = !avatarVisible;
  self.userNameLabel.hidden = !userNameVisible;
  self.textLabel.hidden = !textLabelVisible;
  
  [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    if (!avatarVisible) {
      return;
    }
    make.width.height.mas_equalTo(69);
    make.centerX.equalTo(self);
    make.top.equalTo(self).offset(42);
  }];

  [self.userNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    if (!userNameVisible) {
      return;
    }
    make.top.equalTo(_avatarImageView.mas_bottom).offset(8);
    make.centerX.equalTo(self);
  }];
  
  
  [self.gradeView mas_remakeConstraints:^(MASConstraintMaker *make) {
    if (!gradeVisible) {
      return;
    }
    make.left.equalTo(self).offset(24);
    make.centerX.equalTo(self);
    if ([[GBUserAccount shared] getMyAuthority].canSeeRoundGrade) {
      make.top.equalTo(self.userNameLabel.mas_bottom).offset(20);
      make.height.mas_equalTo(113);
    }else {
      make.top.equalTo(self.userNameLabel.mas_bottom);
      make.height.mas_equalTo(0);
    }
    if (textLabelVisible) {
      make.bottom.equalTo(self.textLabel.mas_top).inset(20);
    }else {
      make.bottom.equalTo(self).inset(28);
    }
  }];
  
  [self.ruleView mas_remakeConstraints:^(MASConstraintMaker *make) {
    if (!ruleViewVisible) {
      return;
    }
    make.left.equalTo(self).offset(24);
    make.right.equalTo(self).inset(24);
    make.top.equalTo(self).offset(65);
//    make.height.mas_equalTo(95);
    if (textLabelVisible) {
      make.bottom.equalTo(self.textLabel.mas_top).inset(20);
    }else {
      make.bottom.equalTo(self).inset(28);
    }
  }];
  
  if (textLabelVisible) {
    [self.textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.bottom.equalTo(self).inset(28);
      make.centerX.equalTo(self);
    }];
  }

  [super updateConstraints];
}

#pragma mark - View
- (CAGradientLayer *)bgLayer {
  if (!_bgLayer) {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    
    UIColor *leftColor = [UIColor colorWithHexString:@"#7700E7FF"];
    UIColor *rightColor = [UIColor colorWithHexString:@"#2E22B1FF"];
    
    gradientLayer.colors = @[(__bridge id)leftColor.CGColor,
                             (__bridge id)rightColor.CGColor];
    gradientLayer.locations = @[@0.3, @1.0];
    gradientLayer.startPoint = CGPointMake(0.5, 0);
    gradientLayer.endPoint = CGPointMake(0.5, 1);
    
    _bgLayer = gradientLayer;
  }
  return _bgLayer;
}

- (GBRingImageView *)avatarImageView {
  if (!_avatarImageView) {
    _avatarImageView = [[GBRingImageView alloc] init];
  }
  return _avatarImageView;
}

- (UILabel *)userNameLabel {
  if (!_userNameLabel) {
    _userNameLabel = [[UILabel alloc] init];
    _userNameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    _userNameLabel.textColor = [UIColor whiteColor];
  }
  return _userNameLabel;
}

- (GBRoundGradeView *)gradeView {
  if (!_gradeView) {
    _gradeView = [[GBRoundGradeView alloc] init];
    _gradeView.layer.cornerRadius = 12;
  }
  return _gradeView;
}

- (UILabel *)textLabel {
  if (!_textLabel) {
    UILabel *view = [[UILabel alloc] init];
    view.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    view.textColor = [UIColor whiteColor];
    _textLabel = view;
  }
  return _textLabel;
}

- (GBRoundResultRuleView *)ruleView {
  if (!_ruleView) {
    _ruleView = [[GBRoundResultRuleView alloc] init];
  }
  return _ruleView;
}

#pragma mark - Setter & Getter
- (void)setUser:(GBUser *)user {
  _user = user;
  self.userNameLabel.text = user.userName;
  self.avatarImageView.imageURLString = user.avatarURLString;
}

- (void)setGrade:(GBRoundGrade *)grade {
  _grade = grade;
  self.gradeView.grade = grade;
}

- (void)setText:(NSString *)text {
  self.textLabel.text = text;
  [self setNeedsUpdateConstraints];
}

@end
