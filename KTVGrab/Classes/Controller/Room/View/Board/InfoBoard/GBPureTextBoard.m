//
//  GBPureTextBoard.m
//  KTVGrab
//
//  Created by Vic on 2022/2/22.
//

#import "GBPureTextBoard.h"
#import <Masonry/Masonry.h>

@interface GBPureTextBoard ()

@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *mainLabel;

@property (nonatomic, copy) NSString *descText;
@property (nonatomic, copy) NSString *text;

@end

@implementation GBPureTextBoard

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = UIColor.clearColor;
  }
  return self;
}

- (void)layoutSubviews {
  
  self.descLabel.hidden = !(self.descText.length > 0);
  
  [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self);
  }];
}

- (void)setText:(NSString *)text {
  [self setText:text descText:nil];
}

- (void)setText:(NSString *)text descText:(NSString *)descText {
  _text = text;
  _descText = descText;
  
  self.mainLabel.text = [NSString stringWithFormat:@"%@", text];
  self.descLabel.text = self.descText;
  
  [self setNeedsLayout];
}

- (UILabel *)mainLabel {
  if (!_mainLabel) {
    _mainLabel = [[UILabel alloc] init];
    _mainLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    _mainLabel.textColor = UIColor.whiteColor;
  }
  return _mainLabel;
}

- (UILabel *)descLabel {
  if (!_descLabel) {
    _descLabel = [[UILabel alloc] init];
    _descLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    _descLabel.textColor = UIColor.whiteColor;
    _descLabel.alpha = 0.5;
  }
  return _descLabel;
}

- (UIStackView *)stackView {
  if (!_stackView) {
    _stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
      self.descLabel,
      self.mainLabel
    ]];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.alignment = UIStackViewAlignmentCenter;
    _stackView.spacing = 8;
    [self addSubview:_stackView];
  }
  return _stackView;
}

@end
