//
//  GBUserGrabbedInfoView.m
//  KTVGrab
//
//  Created by Vic on 2022/2/23.
//

#import "GBUserGrabbedInfoView.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>
#import "GBImage.h"
#import "GBUser.h"

@interface GBUserGrabbedInfoView ()

@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UIImageView *grabbedImageView;

@property (nonatomic, strong) CAShapeLayer *strokeLayer;

@end

@implementation GBUserGrabbedInfoView

- (void)layoutSubviews {
  
  CGFloat avatarEdgeLength = 50;
  CGFloat avatarY = round(63.0 / 235.0 * CGRectGetHeight(self.bounds));
  
  [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.height.mas_equalTo(avatarEdgeLength);
  }];
  
  [self.grabbedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(74, 25));
  }];
  
  [self.stackView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self);
    make.top.equalTo(self).offset(avatarY);
    make.left.equalTo(self).offset(10);
    make.right.equalTo(self).inset(10);
  }];
  
  self.avatarImageView.layer.cornerRadius = 0.5 * avatarEdgeLength;
  self.avatarImageView.layer.masksToBounds = YES;
  
  // 提前定位红圈位置并绘制
  CGFloat avatarX = 0.5 * (CGRectGetWidth(self.bounds) - avatarEdgeLength);
  CGRect imageFrame = CGRectMake(avatarX, avatarY, avatarEdgeLength, avatarEdgeLength);
  
  CGRect strokerFrame = CGRectMake(CGRectGetMinX(imageFrame) - 1,
                                   CGRectGetMinY(imageFrame) - 1,
                                   CGRectGetWidth(imageFrame) + 2,
                                   CGRectGetHeight(imageFrame) + 2);
  UIBezierPath *roundPath = [UIBezierPath bezierPathWithOvalInRect:strokerFrame];
  self.strokeLayer.path = roundPath.CGPath;
}

- (UIStackView *)stackView {
  if (!_stackView) {
    _stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
      self.avatarImageView,
      self.userNameLabel,
      self.grabbedImageView,
    ]];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.alignment = UIStackViewAlignmentCenter;
    _stackView.spacing = 8;
    if (@available(iOS 11.0, *)) {
      [_stackView setCustomSpacing:10 afterView:self.avatarImageView];
    }
    [self addSubview:_stackView];
  }
  return _stackView;
}

- (UIImageView *)avatarImageView {
  if (!_avatarImageView) {
    _avatarImageView = [[UIImageView alloc] init];
    _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
  }
  return _avatarImageView;
}

- (UILabel *)userNameLabel {
  if (!_userNameLabel) {
    _userNameLabel = [[UILabel alloc] init];
    _userNameLabel.textColor = [UIColor whiteColor];
    _userNameLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
//    _userNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
  }
  return _userNameLabel;
}

- (UIImageView *)grabbedImageView {
  if (!_grabbedImageView) {
    _grabbedImageView = [[UIImageView alloc] init];
    _grabbedImageView.contentMode = UIViewContentModeScaleAspectFit;
    _grabbedImageView.image = [GBImage imageNamed:@"gb_info_board_text_grabbed"];
  }
  return _grabbedImageView;
}

- (CAShapeLayer *)strokeLayer {
  if (!_strokeLayer) {
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.lineWidth = 1.5;
    layer.strokeColor = [UIColor colorWithHexString:@"#FF1F40FF"].CGColor;
    layer.fillColor = UIColor.clearColor.CGColor;
    [self.layer addSublayer:layer];
    _strokeLayer = layer;
  }
  return _strokeLayer;
}

#pragma mark - Public
- (void)setGrabUser:(GBUser *)user {
  self.avatarImageView.imageURL = [NSURL URLWithString:user.avatarURLString];
  self.userNameLabel.text = user.userName;
}

@end
