//
//  ZGKTVNetworkPromptView.m
//  GoChat
//
//  Created by Vic on 2021/10/24.
//  Copyright © 2021 zego. All rights reserved.
//

#import "GBNetIndicatorView.h"
#import "GBImage.h"

@interface GBNetIndicatorView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) GBNetQuality networkQuality;
 
@end

@implementation GBNetIndicatorView

- (instancetype)init {
  self = [super init];
  if (self) {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
  self.layer.cornerRadius = 11;
  
  [self setNetworkQuality:GBNetQualityTesting];
}

- (void)updateConstraints {
  
  CGRect rect = [self.label.text boundingRectWithSize:CGSizeMake(200, CGRectGetHeight(self.bounds)) options:0 attributes:@{
    NSFontAttributeName: self.label.font,
  } context:nil];
  
  [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(7, 7));
    make.top.equalTo(self).offset(8);
    make.bottom.equalTo(self).inset(8);
    make.left.equalTo(self).offset(11);
  }];
  
  [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self);
    make.left.equalTo(self.imageView.mas_right).offset(6.5);
    make.right.equalTo(self).inset(10);
    make.width.mas_equalTo(rect.size.width + 1);
  }];
  
  [super updateConstraints];
}

- (UILabel *)label {
  if (!_label) {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:10];
    label.textColor = [UIColor whiteColor];
    [self addSubview:label];
    _label = label;
  }
  return _label;
}

- (UIImageView *)imageView {
  if (!_imageView) {
    UIImageView *view = [[UIImageView alloc] init];
    view.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:view];
    _imageView = view;
  }
  return _imageView;
}

- (void)setNetworkQuality:(GBNetQuality)quality {
  if (_networkQuality == quality) {
    return;
  }
  _networkQuality = quality;
  NSString *imageName = @"";
  NSString *prompt = @"";
  
  if (quality == GBNetQualityUnknown ||
      quality == GBNetQualityTesting) {
    imageName = @"ktv_network_testing";
    prompt = @"本机网络测速中...";
  }
  
  else if (quality == GBNetQualityBad) {
    imageName = @"ktv_network_bad";
    prompt = @"本机网络差";
  }
  
  else if (quality == GBNetQualityMedium) {
    imageName = @"ktv_network_normal";
    prompt = @"本机网络中";
  }
  
  else if (quality == GBNetQualityGood) {
    imageName = @"ktv_network_best";
    prompt = @"本机网络好";
  }

  self.imageView.image = [GBImage imageNamed:imageName];
  self.label.text = prompt;
  [self setNeedsUpdateConstraints];
}

@end
