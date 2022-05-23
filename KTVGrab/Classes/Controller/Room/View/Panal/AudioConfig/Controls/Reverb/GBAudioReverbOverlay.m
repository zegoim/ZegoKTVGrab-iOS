//
//  GBAudioReverbOverlay.m
//  KTVGrab
//
//  Created by Vic on 2022/4/15.
//

#import "GBAudioReverbOverlay.h"
#import <YYKit/YYKit.h>

@interface GBAudioReverbOverlay ()

@property (nonatomic, strong) CAShapeLayer *overlay;

@end

@implementation GBAudioReverbOverlay

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGRect roundRect = CGRectMake(CGRectGetMinX(self.bounds) + 1,
                                CGRectGetMinY(self.bounds) + 1,
                                CGRectGetWidth(self.bounds) - 2,
                                CGRectGetHeight(self.bounds) - 2);
  UIBezierPath *roundPath = [UIBezierPath bezierPathWithOvalInRect:roundRect];
  self.overlay.path = roundPath.CGPath;
}

- (CAShapeLayer *)overlay {
  if (!_overlay) {
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.lineWidth = 2;
    layer.strokeColor = [UIColor colorWithHexString:@"0xFC524B"].CGColor;
    layer.fillColor = UIColor.clearColor.CGColor;
    _overlay = layer;
    [self.layer addSublayer:layer];
  }
  return _overlay;
}

@end
