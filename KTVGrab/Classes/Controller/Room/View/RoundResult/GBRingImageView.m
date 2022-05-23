//
//  GBRingImageView.m
//  KTVGrab
//
//  Created by Vic on 2022/3/17.
//

#import "GBRingImageView.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>


@interface GBRingImageView ()

/// 头像
@property (nonatomic, strong) UIImageView *imgView;

/// 用户头像装饰圆环
@property (nonatomic, strong) CAShapeLayer *whiteRingLayer;

@end

@implementation GBRingImageView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  self.backgroundColor = UIColor.redColor;
  [self setupSubviews];
}

- (void)setupSubviews {
  [self addSubview:self.imgView];
  [self.layer addSublayer:self.whiteRingLayer];
}


- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat halfEdgeLength = 0.5 * CGRectGetWidth(self.bounds);
  
  self.layer.cornerRadius = halfEdgeLength;
  self.layer.masksToBounds = YES;
  
  CGFloat radius = 0.5 * CGRectGetWidth(self.bounds) - 1.5;
  UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(halfEdgeLength, halfEdgeLength) radius:radius startAngle:0 endAngle:2.0f * M_PI clockwise:YES];
  self.whiteRingLayer.path = path.CGPath;
}

- (void)updateConstraints {
  [self.imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self).offset(2);
  }];
  
  [super updateConstraints];
}


- (UIImageView *)imgView {
  if (!_imgView) {
    _imgView = [[UIImageView alloc] init];
  }
  return _imgView;
}

- (CAShapeLayer *)whiteRingLayer {
  if (!_whiteRingLayer) {
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.lineWidth = 3;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    _whiteRingLayer = layer;
  }
  return _whiteRingLayer;
}

- (void)setImageURLString:(NSString *)imageURLString {
  self.imgView.imageURL = [NSURL URLWithString:imageURLString];
}

@end
