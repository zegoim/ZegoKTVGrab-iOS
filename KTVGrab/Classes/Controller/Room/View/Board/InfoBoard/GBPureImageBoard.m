//
//  GBPureImageBoard.m
//  KTVGrab
//
//  Created by Vic on 2022/2/22.
//

#import "GBPureImageBoard.h"
#import <Masonry/Masonry.h>

@interface GBPureImageBoard ()

@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;

@property (nonatomic, copy) NSString *text;

@end

@implementation GBPureImageBoard

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = UIColor.clearColor;
  }
  return self;
}

- (void)layoutSubviews {
  [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.right.equalTo(self);
    make.bottom.lessThanOrEqualTo(self);
    make.center.equalTo(self);
  }];
}

- (void)setImage:(UIImage *)image {
  [self setImage:image descText:nil];
}

- (void)setImage:(UIImage *)image descText:(NSString *)text {
  _text = text;
  self.label.hidden = !text;
  self.imageView.image = image;
  self.label.text = text;
}

- (UIImageView *)imageView {
  if (!_imageView) {
    _imageView = [[UIImageView alloc] init];
  }
  return _imageView;
}

- (UILabel *)label {
  if (!_label) {
    _label = [[UILabel alloc] init];
    _label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    _label.textColor = [UIColor whiteColor];
    _label.alpha = 0.5;
  }
  return _label;
}

- (UIStackView *)stackView {
  if (!_stackView) {
    _stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
      self.label,
      self.imageView,
    ]];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.spacing = 8;
    _stackView.alignment = UIStackViewAlignmentCenter;
    _stackView.distribution = UIStackViewDistributionFill;
    [self addSubview:_stackView];
  }
  return _stackView;
}

@end
