//
//  GBCountdownRingView.m
//  KTVGrab
//
//  Created by Vic on 2022/3/24.
//

#import "GBCountdownRingView.h"

@interface GBCountdownRingView ()<CAAnimationDelegate>

/// 倒计时圆环 layer
@property (nonatomic, strong) CAShapeLayer *animateRingLayer;

/// 倒计时动画
@property (nonatomic, strong) CABasicAnimation *animation;

@end

@implementation GBCountdownRingView

- (instancetype)init {
  self = [super init];
  if (self) {
    _lineWidth = 5.0f;
    _lineColor = UIColor.whiteColor;
    _dashed = NO;
    _duration = 5;
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];

  UIBezierPath *animateRingPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width * 0.5,
                                                                                    self.frame.size.height* 0.5)
                                                                 radius:self.frame.size.height / 2
                                                             startAngle:-M_PI_2
                                                               endAngle:M_PI * 3 / 2
                                                              clockwise:1];
  
  self.animateRingLayer.path = animateRingPath.CGPath;
}

- (CAShapeLayer *)animateRingLayer {
  if (!_animateRingLayer) {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = self.bounds;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineWidth = self.lineWidth;
    layer.strokeColor = self.lineColor.CGColor;
    
    if (self.dashed) {
      //每条虚线长度为2，间隔为3
      layer.lineDashPattern = @[@2, @3];
    }
    _animateRingLayer = layer;
    [self.layer addSublayer:layer];
  }
  return _animateRingLayer;
}

#pragma mark - Public
- (void)start {
  CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
  anim.delegate = self;
  anim.duration = self.duration;
  anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
  anim.fromValue = @1;
  anim.toValue = @0;
  anim.fillMode = kCAFillModeForwards;
  anim.removedOnCompletion = NO;
  [self.animateRingLayer addAnimation:anim forKey:@"strokeEndAnimation"];
  self.animation = anim;
}

- (void)stop {
  CFTimeInterval mediaTime = CACurrentMediaTime();
  CFTimeInterval pausedTime = [self.animateRingLayer convertTime:mediaTime fromLayer:nil];
  // 下面两行先后顺序不可调换
  self.animateRingLayer.speed = 0.0;
  self.animateRingLayer.timeOffset = pausedTime;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  if (flag == YES) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      self.onCountdownRingFinished();
    });
  }
}

@end
