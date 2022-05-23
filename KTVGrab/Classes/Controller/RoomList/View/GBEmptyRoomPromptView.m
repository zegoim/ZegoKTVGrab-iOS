//
//  GBNoRoomPromptView.m
//  KTVGrab
//
//  Created by Vic on 2022/3/7.
//

#import "GBEmptyRoomPromptView.h"
#import <Masonry/Masonry.h>

@interface GBEmptyRoomPromptView ()

@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation GBEmptyRoomPromptView

- (instancetype)init {
  self = [super init];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
    self.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return self;
}

- (void)updateConstraints {
  [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self);
  }];
  [super updateConstraints];
}

- (UILabel *)titleLabel {
  if (!_titleLabel) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = @"暂无房间";
  }
  return _titleLabel;
}

- (UILabel *)descLabel {
  if (!_descLabel) {
    _descLabel = [[UILabel alloc] init];
    _descLabel.alpha = 0.7;
    _descLabel.font = [UIFont systemFontOfSize:12];
    _descLabel.textColor = [UIColor whiteColor];
    _descLabel.text = @"点击下方按钮创建房间吧";
  }
  return _descLabel;
}

- (UIStackView *)stackView {
  if (!_stackView) {
    _stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
      self.titleLabel,
      self.descLabel
    ]];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.spacing = 7;
    _stackView.alignment = UIStackViewAlignmentCenter;
    [self addSubview:_stackView];
  }
  return _stackView;
}

@end
