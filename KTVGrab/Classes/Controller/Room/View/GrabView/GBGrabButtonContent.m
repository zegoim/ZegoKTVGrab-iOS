//
//  GBGrabButtonContent.m
//  KTVGrab
//
//  Created by Vic on 2022/3/24.
//

#import "GBGrabButtonContent.h"
#import "GBImage.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>

@interface GBGrabButtonContent ()

@property (nonatomic, strong) UILabel *countDownNumberLabel;

@property (nonatomic, strong) UIImageView *grabImageView;

@property (nonatomic, strong) UILabel *grabTitleLabel;

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end


@implementation GBGrabButtonContent

- (instancetype)init {
  self = [super init];
  if (self) {
    [self setGrabState:0];
  }
  return self;
}

- (void)setGrabState:(NSUInteger)grabState {
  if (grabState == 0) {
    self.countDownNumberLabel.hidden = NO;
    self.grabImageView.hidden = YES;
    self.grabTitleLabel.hidden = YES;
  }else {
    self.countDownNumberLabel.hidden = YES;
    self.grabImageView.hidden = NO;
    self.grabTitleLabel.hidden = NO;
  }
}


- (void)layoutSubviews {
  [super layoutSubviews];
  
  self.gradientLayer.frame = self.bounds;
}

- (void)updateConstraints {
  [self.countDownNumberLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self);
  }];
  
  [self.grabImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.width.height.mas_equalTo(36);
    make.centerX.equalTo(self);
    make.top.equalTo(self).offset(7.5);
  }];
  
  [self.grabTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self);
    make.bottom.equalTo(self).inset(7.5);
  }];
  
  [super updateConstraints];
}

- (void)setNumber:(int)number {
  self.countDownNumberLabel.text = [@(number) stringValue];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  self.onTouch();
}

#pragma mark -
- (UILabel *)countDownNumberLabel {
  if (!_countDownNumberLabel) {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"Poppins-SemiBold" size:45];
    label.textColor = UIColor.whiteColor;
    [self addSubview:label];
    _countDownNumberLabel = label;
  }
  return _countDownNumberLabel;
}

- (UIImageView *)grabImageView {
  if (!_grabImageView) {
    UIImageView *view = [[UIImageView alloc] init];
    view.contentMode = UIViewContentModeScaleAspectFit;
    view.image = [GBImage imageNamed:@"gb_grab_trigger"];
    [self addSubview:view];
    _grabImageView = view;
  }
  return _grabImageView;
}

- (UILabel *)grabTitleLabel {
  if (!_grabTitleLabel) {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"抢唱";
    [self addSubview:label];
    _grabTitleLabel = label;
  }
  return _grabTitleLabel;
}

- (CAGradientLayer *)gradientLayer {
  if (!_gradientLayer) {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    
    UIColor *beginColor = UIColorHex(#FF3772);
    UIColor *endColor = UIColorHex(#FF5940);
    
    gradientLayer.colors = @[(__bridge id)beginColor.CGColor,
                             (__bridge id)endColor.CGColor];
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.startPoint = CGPointMake(1, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    [self.layer insertSublayer:gradientLayer atIndex:0];
    
    _gradientLayer = gradientLayer;
  }
  return _gradientLayer;
}

@end
