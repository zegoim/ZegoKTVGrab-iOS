//
//  GBSeatBackgroundView.m
//  KTVGrab
//
//  Created by Vic on 2022/3/25.
//

#import "GBSeatBackgroundView.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>
#import "GBImage.h"

@interface GBSeatBackgroundView ()

@property (nonatomic, strong) UIImageView *plusImageView;
@property (nonatomic, strong) CAGradientLayer *fillGradientLayer;
@property (nonatomic, strong) CAShapeLayer *ringLayer;

@end


@implementation GBSeatBackgroundView

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
  [self.layer addSublayer:self.fillGradientLayer];
  [self.layer addSublayer:self.ringLayer];
  [self addSubview:self.plusImageView];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  [self.plusImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.width.height.mas_equalTo(16);
    make.center.equalTo(self);
  }];
  
  self.fillGradientLayer.frame = self.bounds;
  self.fillGradientLayer.cornerRadius = CGRectGetWidth(self.bounds) * 0.5;
  self.fillGradientLayer.masksToBounds = YES;
  
  UIBezierPath * path = [self ringPath];
  self.ringLayer.path = path.CGPath;
}

- (UIBezierPath *)ringPath {
  CGRect selfBounds = self.bounds;
  return [UIBezierPath bezierPathWithArcCenter:CGPointMake(selfBounds.size.width * 0.5,
                                                           selfBounds.size.height* 0.5)
                                        radius:selfBounds.size.height / 2
                                    startAngle:-M_PI_2
                                      endAngle:M_PI * 3 / 2
                                     clockwise:1];
}

- (UIImageView *)plusImageView {
  if (!_plusImageView) {
    _plusImageView = [[UIImageView alloc] init];
    _plusImageView.contentMode = UIViewContentModeScaleAspectFit;
    _plusImageView.image = [GBImage imageNamed:@"ktv_mic_join"];
  }
  return _plusImageView;
}

- (CAShapeLayer *)ringLayer {
  if (!_ringLayer) {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.lineWidth = 1.5;
    layer.strokeColor = UIColorHex(#5E15C299).CGColor;
    layer.fillColor = UIColor.clearColor.CGColor;
    _ringLayer = layer;
  }
  return _ringLayer;
}

- (CAGradientLayer *)fillGradientLayer {
  if (!_fillGradientLayer) {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    
    UIColor *leftColor = UIColorHex(#4F0CA8FF);
    UIColor *rightColor = UIColorHex(#481190FF);
    
    gradientLayer.colors = @[(__bridge id)leftColor.CGColor,
                             (__bridge id)rightColor.CGColor];
    gradientLayer.locations = @[@0.0, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.opacity = 0.5;
    _fillGradientLayer = gradientLayer;
  }
  return _fillGradientLayer;
}

- (void)setPlusVisible:(BOOL)visible {
  self.plusImageView.hidden = !visible;
}

@end
