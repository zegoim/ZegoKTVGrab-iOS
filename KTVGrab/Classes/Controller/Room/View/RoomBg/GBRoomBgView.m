//
//  GBRoomBgView.m
//  AFNetworking
//
//  Created by Vic on 2022/2/24.
//

#import "GBRoomBgView.h"
#import <YYKit/YYKit.h>

@interface GBRoomBgView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation GBRoomBgView

- (void)layoutSubviews {
  [super layoutSubviews];
  self.gradientLayer.frame = self.bounds;
}

- (CAGradientLayer *)gradientLayer {
  if (!_gradientLayer) {
    _gradientLayer = [[CAGradientLayer alloc] init];
    UIColor *topColor = [UIColor colorWithHexString:@"#220027FF"];
    UIColor *bottomColor = [UIColor colorWithHexString:@"#230038FF"];
    
    _gradientLayer.colors = @[(__bridge id)topColor.CGColor,
                             (__bridge id)bottomColor.CGColor];
    _gradientLayer.locations = @[@(0), @(1.0f)];
    _gradientLayer.startPoint = CGPointMake(0.5, 0);
    _gradientLayer.endPoint = CGPointMake(0.5, 1);
    [self.layer insertSublayer:_gradientLayer atIndex:0];
  }
  return _gradientLayer;
}

@end
