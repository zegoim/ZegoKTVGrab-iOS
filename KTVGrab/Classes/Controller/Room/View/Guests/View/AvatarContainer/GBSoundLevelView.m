//
//  ZGKTVSoundLayerView.m
//  GoChat
//
//  Created by Vic on 2021/10/25.
//  Copyright © 2021 zego. All rights reserved.
//

#import "GBSoundLevelView.h"
#import <YYKit/YYKit.h>

@interface GBSoundLevelView ()

@property (nonatomic, strong) CAShapeLayer *silentLayer;
@property (nonatomic, strong) CAShapeLayer *lowSoundLayer;
@property (nonatomic, strong) CAShapeLayer *midSoundLayer;
@property (nonatomic, strong) CAShapeLayer *highSoundLayer;

@property (nonatomic, assign) CGFloat innerRadius;

@end

@implementation GBSoundLevelView

- (instancetype)init {
  self = [super init];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
    
    //TODO: 确认是否需要 silentLayer
//    [self.layer addSublayer:self.silentLayer];
    [self.layer addSublayer:self.lowSoundLayer];
    [self.layer addSublayer:self.midSoundLayer];
    [self.layer addSublayer:self.highSoundLayer];
    
    self.innerRadius = 22;
  }
  return self;
}

- (void)muteAll {
  self.lowSoundLayer.hidden = NO;
  self.midSoundLayer.hidden = YES;
  self.highSoundLayer.hidden = YES;
}

- (void)setSoundLevel:(CGFloat)level {
  if (level <= 5) {
    [self muteAll];
  }
  else if (level < 10) {
    self.lowSoundLayer.hidden = NO;
    self.midSoundLayer.hidden = YES;
    self.highSoundLayer.hidden = YES;
  }
  else if (level < 30) {
    self.lowSoundLayer.hidden = NO;
    self.midSoundLayer.hidden = NO;
    self.highSoundLayer.hidden = YES;
  }
  else if (level >= 30) {
    self.lowSoundLayer.hidden = NO;
    self.midSoundLayer.hidden = NO;
    self.highSoundLayer.hidden = NO;
  }
}


#pragma mark - Private
- (void)layoutSubviews {
  [self layoutLayers];
}

- (void)layoutLayers {
  CGFloat silentRadius = self.innerRadius;
  CGFloat lowRadius = silentRadius + 0;
  CGFloat midRadius = silentRadius + 3;
  CGFloat highRadius = silentRadius + 6;
  
  CGPoint center = CGPointMake(CGRectGetWidth(self.bounds)* 0.5, CGRectGetHeight(self.bounds)* 0.5);
  
//  self.silentLayer.path = [self soundLevelPathWithCenter:center radius:silentRadius].CGPath;
  self.lowSoundLayer.path = [self soundLevelPathWithCenter:center radius:lowRadius].CGPath;
  self.midSoundLayer.path = [self soundLevelPathWithCenter:center radius:midRadius].CGPath;
  self.highSoundLayer.path = [self soundLevelPathWithCenter:center radius:highRadius].CGPath;
}

- (UIBezierPath *)soundLevelPathWithCenter:(CGPoint)center radius:(CGFloat)radius {
  return [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:-M_PI_2 endAngle:M_PI * 3 / 2 clockwise:YES];
}

- (CAShapeLayer *)silentLayer {
  if (!_silentLayer) {
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.lineWidth = 3;
    layer.strokeColor = [UIColor colorWithHexString:@"#FF1F40"].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    _silentLayer = layer;
  }
  return _silentLayer;
}

- (CAShapeLayer *)lowSoundLayer {
  if (!_lowSoundLayer) {
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.lineWidth = 2;
    layer.strokeColor = [UIColor colorWithHexString:@"#FE1F59FF"].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    _lowSoundLayer = layer;
  }
  return _lowSoundLayer;
}

- (CAShapeLayer *)midSoundLayer {
  if (!_midSoundLayer) {
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.lineWidth = 1;
    layer.strokeColor = [UIColor colorWithHexString:@"#FE1F59FF"].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    _midSoundLayer = layer;
  }
  return _midSoundLayer;
}

- (CAShapeLayer *)highSoundLayer {
  if (!_highSoundLayer) {
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.lineWidth = 0.5;
    layer.strokeColor = [UIColor colorWithHexString:@"#FE1F59FF"].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    _highSoundLayer = layer;
  }
  return _highSoundLayer;
}

@end
