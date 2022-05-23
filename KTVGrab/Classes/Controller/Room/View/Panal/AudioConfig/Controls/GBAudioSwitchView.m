//
//  ZegoAudioSwitchView.m
//  HalfScreenTransitioning
//
//  Created by Vic on 2022/2/18.
//

#import "GBAudioSwitchView.h"
#import "GBAudioTitleLabel.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>

@interface GBAudioSwitchView ()

@property (nonatomic, strong) UISwitch *toggleSwitch;
@property (nonatomic, strong) GBAudioTitleLabel *titleLabel;
@property (nonatomic, strong) GBAudioTitleLabel *descLabel;

@end

@implementation GBAudioSwitchView

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
  [self addSubview:self.toggleSwitch];
  [self addSubview:self.titleLabel];
  [self addSubview:self.descLabel];
}

- (void)updateConstraints {
  [self.toggleSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self);
    make.right.equalTo(self).inset(16);
  }];
  
  [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self).offset(7);
    make.left.equalTo(self).offset(16);
  }];
  
  [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.titleLabel);
    make.bottom.equalTo(self).inset(8);
  }];
  
  [super updateConstraints];
}

- (UISwitch *)toggleSwitch {
  if (!_toggleSwitch) {
    UISwitch *view = [[UISwitch alloc] init];
    view.onTintColor = UIColorHex(FF3670);
    [view addTarget:self action:@selector(toggleAction) forControlEvents:UIControlEventValueChanged];
    _toggleSwitch = view;
  }
  return _toggleSwitch;
}

- (GBAudioTitleLabel *)titleLabel {
  if (!_titleLabel) {
    GBAudioTitleLabel *view = [[GBAudioTitleLabel alloc] init];
    _titleLabel = view;
  }
  return _titleLabel;
}

- (GBAudioTitleLabel *)descLabel {
  if (!_descLabel) {
    GBAudioTitleLabel *view = [[GBAudioTitleLabel alloc] init];
    view.font = [UIFont systemFontOfSize:10];
    _descLabel = view;
  }
  return _descLabel;
}

- (void)setEnable:(BOOL)enable {
  _enable = enable;
  if (self.audioSwitchUpdateBlock) {
    self.audioSwitchUpdateBlock(enable);
  }
  
  CGFloat alpha = 1;
  if (!enable) {
    alpha = 0.5;
  }
  self.toggleSwitch.alpha = alpha;
  self.titleLabel.alpha = alpha;
  self.descLabel.alpha = alpha;

  self.toggleSwitch.on = enable;
}

- (void)setTitleText:(NSString *)titleText {
  _titleText = titleText;
  self.titleLabel.text = titleText;
}

- (void)setDescText:(NSString *)descText {
  _descText = descText;
  self.descLabel.text = descText;
}

- (void)toggleAction {
  [self setEnable:self.toggleSwitch.isOn];
}

@end
