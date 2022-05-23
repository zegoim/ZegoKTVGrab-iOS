//
//  GBRipplesLayer.m
//  KTVGrab
//
//  Created by Vic on 2022/3/24.
//

#import "GBRipplesLayer.h"

@interface GBRipplesLayer ()
/**
 *  涟漪圈
 */
@property (nonatomic, strong) CALayer *roundLayer;

/**
 *  动画组
 */
@property (nonatomic, strong) CAAnimationGroup *ripplesAnimationGroup;

/**
 *  涟漪圈半径的初始值
 */
@property (nonatomic, assign) CGFloat fromValueForRadius;

/**
 *  涟漪圈Alpha初始值
 */
@property (nonatomic, assign) CGFloat fromValueForAlpha;

@end


@implementation GBRipplesLayer

- (instancetype)init{
  if (self = [super init]) {
    [self setup];
  }
  return self;
}


#pragma mark - Public Methods

- (void)startAnimation{
  [self setupConfiguration];
  [self setupAnimation];
  [self.roundLayer addAnimation:self.ripplesAnimationGroup forKey:@"ripples"];
}


#pragma mark - Private Methods

- (void)setup {
  self.rippleBorderColor = [UIColor greenColor];
  self.rippleBackgroundColor = [UIColor clearColor];
  self.radius = 50;
  self.animationDuration = 1;
  self.fromValueForAlpha = 0;
  self.fromValueForRadius = 0;
  
  // 必须 CAReplicatorLayer的重要特性
  self.repeatCount = INFINITY;
  self.instanceCount = 3;
  self.instanceDelay = 0.2;
}

- (void)setupConfiguration {
  self.roundLayer.backgroundColor = self.rippleBackgroundColor.CGColor;
  self.roundLayer.borderColor = self.rippleBorderColor.CGColor;
  self.roundLayer.borderWidth = 2;
}

- (void)setupAnimation{
  
  self.ripplesAnimationGroup.duration = self.animationDuration;
  self.ripplesAnimationGroup.repeatCount = self.repeatCount;
  
  // 动画曲线，使用默认
  self.ripplesAnimationGroup.timingFunction =  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];;
  
  // 圆圈放大
  CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
  scaleAnimation.fromValue = @(self.fromValueForRadius);
  scaleAnimation.toValue = @1.0;
  scaleAnimation.duration = self.animationDuration;
  
  // 改变 alpha (关键帧动画)
  CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
  opacityAnimation.values = @[@(self.fromValueForAlpha), @0.5, @0];
  opacityAnimation.keyTimes = @[@0, @(0.4), @1];
  opacityAnimation.duration = self.animationDuration;
  
  self.ripplesAnimationGroup.animations = @[scaleAnimation, opacityAnimation];
}


#pragma mark - setter

- (void)setRadius:(CGFloat)radius{
  _radius = radius;
  CGFloat roundW = radius * 2;
  self.roundLayer.bounds = CGRectMake(0, 0, roundW, roundW);
  self.roundLayer.cornerRadius = radius;
}

#pragma mark - getter

- (CALayer *)roundLayer{
  if (!_roundLayer) {
    _roundLayer = [CALayer layer];
    // 适应屏幕分辨率
    _roundLayer.contentsScale = [UIScreen mainScreen].scale;
    _roundLayer.opacity = 0;
    [self addSublayer:_roundLayer];
  }
  return _roundLayer;
}

- (CAAnimationGroup *)ripplesAnimationGroup{
  if (!_ripplesAnimationGroup) {
    _ripplesAnimationGroup = [CAAnimationGroup animation];
  }
  return _ripplesAnimationGroup;
}

@end
