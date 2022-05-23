//
//  GBSeatBottomView.m
//  KTVGrab
//
//  Created by Vic on 2022/3/28.
//

#import "GBSeatBottomView.h"
#import <Masonry/Masonry.h>


@interface GBSeatBottomView ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation GBSeatBottomView

- (void)updateConstraints {
  
  CGFloat padding = 5;
  
  [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self).offset(padding);
    make.centerY.equalTo(self);
    if (!self.imageView.image) {
      make.centerX.equalTo(self);
    }
  }];
  
  [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    if (!self.imageView.image) {
      return;
    }
    make.left.equalTo(self.label.mas_right).offset(3);
    make.centerY.equalTo(self);
    make.right.equalTo(self).inset(padding);
    make.width.height.mas_greaterThanOrEqualTo(7);
  }];
  
  [super updateConstraints];
}

- (UILabel *)label {
  if (!_label) {
    UILabel *view = [[UILabel alloc] init];
    view.textColor = UIColor.whiteColor;
    view.font = [UIFont systemFontOfSize:10];
    view.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self addSubview:view];
    _label = view;
  }
  return _label;
}

- (UIImageView *)imageView {
  if (!_imageView) {
    UIImageView *view = [[UIImageView alloc] init];
    view.contentMode = UIViewContentModeScaleAspectFit;
    _imageView = view;
    [self addSubview:view];
  }
  return _imageView;
}

#pragma mark - Public
- (void)setText:(NSString *)text {
  self.label.text = text;
  if (![self.label.text isEqualToString:text]) {  
    // 更新 label 约束
    GB_LOG_D(@"[SEAT]Seat bottom view update constraints by text change: %@", text);
    [self setNeedsUpdateConstraints];
  }
}

- (void)setImage:(UIImage *)image {
  UIImage *lastImage = self.imageView.image;
  self.imageView.image = image;
  
  if (lastImage && image) return;
  if (!lastImage && !image) return;
  // 如果这一次设置的 image 和上一次设置的 image 有一次 为 nil, 则需要重绘
  GB_LOG_D(@"[SEAT]Seat bottom view update constraints by image change: %@", image);
  [self setNeedsUpdateConstraints];
}

@end
