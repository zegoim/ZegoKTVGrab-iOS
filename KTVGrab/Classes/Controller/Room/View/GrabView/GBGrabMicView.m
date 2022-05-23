//
//  GBGrabMicView.m
//  KTVGrab
//
//  Created by Vic on 2022/3/24.
//

#import "GBGrabMicView.h"
#import "GBGrabButtonView.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>

@interface GBGrabMicView ()

@property (nonatomic, strong) CAGradientLayer *bottomGradientlayer;
@property (nonatomic, strong) GBGrabButtonView *grabButton;
@property (nonatomic, strong) GBEmptyBlock grabTriggeredBlock;

@end

@implementation GBGrabMicView

- (instancetype)initWithGrabDuration:(CGFloat)grabDuration grabTriggerBlock:(GBEmptyBlock)block {
  if (self = [super init]) {
    _grabTriggeredBlock = block;
    [self.grabButton setGrabDuration:grabDuration];
  }
  return self;
}

- (void)layoutSubviews {
  CGFloat height = 253;
  self.bottomGradientlayer.frame = CGRectMake(0,
                                              CGRectGetHeight(self.bounds) - height,
                                              CGRectGetWidth(self.bounds),
                                              height);
  
  CGFloat buttonLength = 105;
  
  [self.grabButton mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self);
    make.bottom.equalTo(self).inset(0.5 * (height - buttonLength));
    make.width.height.mas_equalTo(buttonLength);
  }];
}

- (GBGrabButtonView *)grabButton {
  if (!_grabButton) {
    GBGrabButtonView *button = [[GBGrabButtonView alloc] init];
    @weakify(self);
    button.onClick = ^{
      @strongify(self);
      self.grabTriggeredBlock();
      [self removeFromSuperview];
    };
    button.onGrabbingTimeout = ^{
      
    };
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [button start];
    });
    [self addSubview:button];
    _grabButton = button;
  }
  return _grabButton;
}

- (CAGradientLayer *)bottomGradientlayer {
  if (!_bottomGradientlayer) {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    
    UIColor *beginColor = [UIColor colorWithWhite:0 alpha:0];
    UIColor *midColor = [UIColor colorWithHexString:@"#1E032D4D"];
    UIColor *endColor = [UIColor colorWithHexString:@"#230038FF"];
    
    gradientLayer.colors = @[
      (__bridge id)beginColor.CGColor,
      (__bridge id)midColor.CGColor,
      (__bridge id)endColor.CGColor
    ];
    gradientLayer.locations = @[@0, @0.3, @1.0];
    gradientLayer.startPoint = CGPointMake(0.5, 0);
    gradientLayer.endPoint = CGPointMake(0.5, 1);
    [self.layer insertSublayer:gradientLayer atIndex:0];
    _bottomGradientlayer = gradientLayer;
  }
  return _bottomGradientlayer;
}

@end
