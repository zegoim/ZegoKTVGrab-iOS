//
//  ZGKTVSlider.m
//  GoChat
//
//  Created by zegomjf on 2021/11/10.
//  Copyright © 2021 zego. All rights reserved.
//

#import "GBSlider.h"
#define thumbBound_x 10
#define thumbBound_y 20

@interface GBSlider ()

@property (nonatomic, assign) CGRect lastBounds;

@end

@implementation GBSlider

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//  if (!self.userInteractionEnabled) {
//    return nil;
//  }
//
//  UIView *result = [super hitTest:point withEvent:event];
//  if (point.x < 0 || point.x > self.bounds.size.width){
//    return result;
//  }
//
//  if ((point.y >= -thumbBound_y) && (point.y < lastBounds.size.height + thumbBound_y)) {
//    float value = 0.0;
//    value = point.x - self.bounds.origin.x;
//    value = value/self.bounds.size.width;
//
//    value = MIN(MAX(value, 0), 1);
//
//    value = value * (self.maximumValue - self.minimumValue) + self.minimumValue;
//    [self setValue:value animated:YES];
//  }
//
//  return result;
//}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
  BOOL result = [super pointInside:point withEvent:event];
  if (!result && point.y > -10) {
    if ((point.x >= self.lastBounds.origin.x - thumbBound_x) && (point.x <= (self.lastBounds.origin.x + self.lastBounds.size.width + thumbBound_x)) && (point.y < (self.lastBounds.size.height + thumbBound_y))) {
      result = YES;
    }
  }
  return result;
}

/// 设置track（滑条）尺寸
- (CGRect)trackRectForBounds:(CGRect)bounds {
  // 将滑条置于 view 的中间位置
  CGFloat height = 3;
  CGFloat y = CGRectGetMidY(bounds) - 0.5 * height;
  return CGRectMake(0, y, CGRectGetWidth(bounds), height);
}

/// 设置滑块尺寸
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
  CGRect result = [super thumbRectForBounds:bounds trackRect:rect value:value];
  
  CGFloat width = CGRectGetHeight(bounds) - 1;
  CGFloat height = width;
  CGFloat x = CGRectGetMidX(result) - 0.5 * width;
  CGFloat y = CGRectGetMidY(result) - 0.5 * height;
  
  CGRect r = CGRectMake(x, y, width, height);
  self.lastBounds = r;
  return r;
}

@end
